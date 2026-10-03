using System;
using System.Collections.Generic;

namespace TripWay.Helper
{
    public static class SortHelper
    {
        public static string BuildOrderBy(string sortExpression, string sortDirection, Dictionary<string, string> allowedColumns)
        {
            if (string.IsNullOrEmpty(sortExpression) || allowedColumns == null || !allowedColumns.ContainsKey(sortExpression))
                return string.Empty;

            string column = allowedColumns[sortExpression];
            bool descending = string.Equals(sortDirection, "DESC", StringComparison.OrdinalIgnoreCase);
            return " ORDER BY " + column + (descending ? " DESC" : " ASC");
        }

        public static string NextDirection(string currentSort, string sortExpression, string currentDirection)
        {
            if (string.Equals(currentSort, sortExpression, StringComparison.OrdinalIgnoreCase))
                return string.Equals(currentDirection, "ASC", StringComparison.OrdinalIgnoreCase) ? "DESC" : "ASC";
            return "ASC";
        }
    }
}
