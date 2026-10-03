using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;

namespace TripWay.Helper
{
    public static class DBHelper
    {
        private static string ConnectionString =>
            ConfigurationManager.ConnectionStrings["TripWayDB"].ConnectionString;

        public static SqlConnection GetConnection()
        {
            return new SqlConnection(ConnectionString);
        }

        private static SqlParameter[] Clone(SqlParameter[] parameters)
        {
            if (parameters == null || parameters.Length == 0) return parameters;
            SqlParameter[] cloned = new SqlParameter[parameters.Length];
            for (int i = 0; i < parameters.Length; i++)
                cloned[i] = (SqlParameter)((ICloneable)parameters[i]).Clone();
            return cloned;
        }

        public static DataTable ExecuteQuery(string query, params SqlParameter[] parameters)
        {
            DataTable dt = new DataTable();
            using (SqlConnection conn = GetConnection())
            {
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    if (parameters != null && parameters.Length > 0)
                        cmd.Parameters.AddRange(Clone(parameters));
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        da.Fill(dt);
                    }
                }
            }
            return dt;
        }

        public static int ExecuteNonQuery(string query, params SqlParameter[] parameters)
        {
            using (SqlConnection conn = GetConnection())
            {
                conn.Open();
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    if (parameters != null && parameters.Length > 0)
                        cmd.Parameters.AddRange(Clone(parameters));
                    return cmd.ExecuteNonQuery();
                }
            }
        }

        public static object ExecuteScalar(string query, params SqlParameter[] parameters)
        {
            using (SqlConnection conn = GetConnection())
            {
                conn.Open();
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    if (parameters != null && parameters.Length > 0)
                        cmd.Parameters.AddRange(Clone(parameters));
                    return cmd.ExecuteScalar();
                }
            }
        }

        public static int ExecuteNonQueryWithIdentity(string query, params SqlParameter[] parameters)
        {
            using (SqlConnection conn = GetConnection())
            {
                conn.Open();
                using (SqlCommand cmd = new SqlCommand(query + "; SELECT SCOPE_IDENTITY();", conn))
                {
                    if (parameters != null && parameters.Length > 0)
                        cmd.Parameters.AddRange(Clone(parameters));
                    object result = cmd.ExecuteScalar();
                    return Convert.ToInt32(result);
                }
            }
        }
    }
}
