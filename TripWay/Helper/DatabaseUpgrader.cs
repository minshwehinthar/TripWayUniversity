using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Text.RegularExpressions;
using System.Threading;
using System.Web;

namespace TripWay.Helper
{
    public static class DatabaseUpgrader
    {
        private const string LogFileName = "Upgrade_log.txt";
        private const int RetryIntervalSeconds = 30;
        private const int MaxRetries = 20;

        private static readonly object _lock = new object();
        private static Timer _retryTimer;
        private static int _retries;

        public static void ApplyUpgrades()
        {
            bool lockTaken = false;
            try
            {
                Monitor.TryEnter(_lock, ref lockTaken);
                if (!lockTaken) return;

                bool allOk = RunOnce();

                if (allOk)
                {
                    StopRetry();
                }
                else
                {
                    ScheduleRetry();
                }
            }
            finally
            {
                if (lockTaken) Monitor.Exit(_lock);
            }
        }

        private static bool RunOnce()
        {
            string connectionString = ConfigurationManager.ConnectionStrings["TripWayDB"] != null
                ? ConfigurationManager.ConnectionStrings["TripWayDB"].ConnectionString
                : null;

            if (string.IsNullOrEmpty(connectionString))
            {
                Log("Upgrade run aborted: connection string 'TripWayDB' not found.");
                return false;
            }

            if (!EnsureDatabaseExists(connectionString))
            {
                Log("Upgrade run deferred: could not ensure the database exists.");
                return false;
            }

            bool allOk = true;
            int appliedCount = 0;
            int failedCount = 0;
            int skippedCount = 0;

            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString + ";Connect Timeout=5"))
                {
                    try { conn.Open(); }
                    catch (Exception openEx)
                    {
                        Log("Database not reachable during upgrade run: " + openEx.Message);
                        return false;
                    }

                    EnsureTracker(conn);

                    string dir = Path.Combine(HttpRuntime.AppDomainAppPath, "App_Data");
                    var files = Directory.GetFiles(dir, "Upgrade_*.sql")
                                         .OrderBy(f => ParseNumber(Path.GetFileName(f)))
                                         .ToList();

                    foreach (string file in files)
                    {
                        string name = Path.GetFileName(file);
                        if (IsApplied(conn, name))
                        {
                            skippedCount++;
                            continue;
                        }

                        if (ApplyFile(conn, file, name))
                        {
                            MarkApplied(conn, name);
                            appliedCount++;
                        }
                        else
                        {
                            failedCount++;
                            allOk = false;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                Log("Upgrade run failed: " + ex.Message);
                return false;
            }

            Log("Upgrade run completed. Connected, skipped=" + skippedCount +
                ", applied=" + appliedCount + ", failed=" + failedCount + ".");
            return allOk;
        }

        /// <summary>
        /// Connects to the server's 'master' database using the configured admin login
        /// and creates the TripWayDB database if it does not exist yet. This avoids the
        /// "Cannot open database ... requested by the login" failure on first run.
        /// </summary>
        private static bool EnsureDatabaseExists(string connectionString)
        {
            string databaseName = "";
            try
            {
                var builder = new SqlConnectionStringBuilder(connectionString);
                databaseName = builder.InitialCatalog;
                builder.InitialCatalog = "master";
                builder.ConnectTimeout = 5;

                using (SqlConnection masterConn = new SqlConnection(builder.ConnectionString))
                {
                    masterConn.Open();
                    using (SqlCommand cmd = new SqlCommand(
                        "IF DB_ID(@db) IS NULL CREATE DATABASE [" + databaseName + "];", masterConn))
                    {
                        cmd.Parameters.AddWithValue("@db", databaseName);
                        cmd.ExecuteNonQuery();
                    }
                }
                Log("Database '" + databaseName + "' guaranteed to exist (created if missing).");
                return true;
            }
            catch (Exception ex)
            {
                Log("Could not ensure database '" + databaseName + "' exists: " + ex.Message);
                return false;
            }
        }

        private static void ScheduleRetry()
        {
            if (_retryTimer == null)
            {
                _retries = 0;
                _retryTimer = new Timer(RetryTick, null, TimeSpan.FromSeconds(RetryIntervalSeconds), TimeSpan.FromSeconds(RetryIntervalSeconds));
                Log("Scheduling upgrade retries every " + RetryIntervalSeconds + "s.");
            }
        }

        private static void RetryTick(object state)
        {
            if (++_retries > MaxRetries)
            {
                StopRetry();
                Log("Giving up upgrade retries after " + MaxRetries + " attempts.");
                return;
            }

            ApplyUpgrades();
        }

        private static void StopRetry()
        {
            if (_retryTimer != null)
            {
                _retryTimer.Dispose();
                _retryTimer = null;
            }
        }

        private static void EnsureTracker(SqlConnection conn)
        {
            using (SqlCommand cmd = new SqlCommand(
                "IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = '__SchemaUpgrades') " +
                "CREATE TABLE dbo.__SchemaUpgrades (FileName NVARCHAR(200) NOT NULL PRIMARY KEY, AppliedAt DATETIME NOT NULL DEFAULT GETDATE());",
                conn))
            {
                cmd.ExecuteNonQuery();
            }
        }

        private static bool IsApplied(SqlConnection conn, string name)
        {
            using (SqlCommand cmd = new SqlCommand("SELECT COUNT(*) FROM dbo.__SchemaUpgrades WHERE FileName = @n", conn))
            {
                cmd.Parameters.AddWithValue("@n", name);
                return Convert.ToInt32(cmd.ExecuteScalar()) > 0;
            }
        }

        private static void MarkApplied(SqlConnection conn, string name)
        {
            using (SqlCommand cmd = new SqlCommand("INSERT INTO dbo.__SchemaUpgrades (FileName) VALUES (@n)", conn))
            {
                cmd.Parameters.AddWithValue("@n", name);
                cmd.ExecuteNonQuery();
            }
        }

        private static bool ApplyFile(SqlConnection conn, string file, string name)
        {
            try
            {
                string script = File.ReadAllText(file);
                foreach (string batch in SplitBatches(script))
                {
                    if (string.IsNullOrWhiteSpace(batch)) continue;
                    using (SqlCommand cmd = new SqlCommand(batch, conn))
                    {
                        cmd.CommandTimeout = 120;
                        cmd.ExecuteNonQuery();
                    }
                }
                return true;
            }
            catch (Exception ex)
            {
                Log("FAILED " + name + ": " + ex.Message);
                return false;
            }
        }

        private static IEnumerable<string> SplitBatches(string script)
        {
            var lines = script.Split(new[] { "\r\n", "\n" }, StringSplitOptions.None);
            var batch = new List<string>();
            foreach (string line in lines)
            {
                if (line.Trim().Equals("GO", StringComparison.OrdinalIgnoreCase))
                {
                    if (batch.Count > 0)
                    {
                        yield return string.Join("\r\n", batch);
                        batch.Clear();
                    }
                }
                else
                {
                    batch.Add(line);
                }
            }
            if (batch.Count > 0)
                yield return string.Join("\r\n", batch);
        }

        private static int ParseNumber(string fileName)
        {
            Match m = Regex.Match(fileName, @"Upgrade_(\d+)\.sql");
            return m.Success ? int.Parse(m.Groups[1].Value) : int.MaxValue;
        }

        private static void Log(string message)
        {
            try
            {
                string log = Path.Combine(HttpRuntime.AppDomainAppPath, "App_Data", LogFileName);
                File.AppendAllText(log,
                    DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss") + " - " + message + Environment.NewLine);
            }
            catch { }
        }
    }
}
