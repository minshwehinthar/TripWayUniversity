using System;
using System.IO;
using System.Web;

namespace TripWay.Helper
{
    public static class AppLog
    {
        public static void Info(string message) { Write("INFO", message); }
        public static void Error(string message) { Write("ERROR", message); }

        private static void Write(string level, string message)
        {
            try
            {
                string log = Path.Combine(HttpRuntime.AppDomainAppPath, "App_Data", "Upgrade_log.txt");
                File.AppendAllText(log,
                    DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss") + " [" + level + "] " + message + Environment.NewLine);
            }
            catch { }
        }
    }
}
