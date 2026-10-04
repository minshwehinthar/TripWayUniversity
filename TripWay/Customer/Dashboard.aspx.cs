using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Web.Script.Serialization;

namespace TripWay.Customer
{
    public partial class DashboardPage : Helper.ListPageBase
    {
        private int CustomerId { get { return Helper.AuthHelper.GetAccountId(); } }

        protected void Page_Load(object sender, EventArgs e)
        {
            Helper.AuthHelper.RequireCustomer(this);
            if (IsPostBack) return;

            LoadData();
        }

        private void LoadData()
        {
            DataRow me = Helper.DBHelper.ExecuteQuery(
                "SELECT FullName, ProfilePhotoUrl FROM Customers WHERE CustomerID=@id",
                new SqlParameter("@id", CustomerId)).Rows[0];
            lblName.Text = me["FullName"].ToString();
            ShowPhoto(me["ProfilePhotoUrl"]);

            DataTable active = Helper.DBHelper.ExecuteQuery(
                "SELECT TOP 1 t.Status, s.Name AS ServiceName, d.FullName AS DriverName " +
                "FROM Trips t " +
                "INNER JOIN ServiceTypes s ON t.ServiceTypeID = s.ServiceTypeID " +
                "LEFT JOIN Drivers d ON t.DriverID = d.DriverID " +
                "WHERE t.CustomerID=@id AND t.Status IN ('Requested','Accepted','Arrived','Started') ORDER BY t.TripID DESC",
                new SqlParameter("@id", CustomerId));
            if (active.Rows.Count > 0)
            {
                pnlActiveBanner.Visible = true;
                lblActiveService.Text = active.Rows[0]["ServiceName"].ToString();
                lblActiveStatus.Text = "You have an " + active.Rows[0]["Status"] + " trip in progress.";
                lblActiveDriver.Text = active.Rows[0]["DriverName"] == DBNull.Value
                    ? "Waiting for driver match…"
                    : "Driver: " + active.Rows[0]["DriverName"].ToString();
            }

            lblTotalTrips.Text = ScalarInt(
                "SELECT COUNT(*) FROM Trips WHERE CustomerID=@id",
                CustomerId).ToString("N0");
            lblMonthTrips.Text = ScalarInt(
                "SELECT COUNT(*) FROM Trips WHERE CustomerID=@id AND Status='Completed' AND DATEADD(MINUTE, 390, RequestedAt) >= DATEFROMPARTS(YEAR(DATEADD(MINUTE, 390, SYSUTCDATETIME())), MONTH(DATEADD(MINUTE, 390, SYSUTCDATETIME())), 1)",
                CustomerId).ToString("N0");
            lblTotalSpent.Text = ScalarInt(
                "SELECT ISNULL(SUM(Fare),0) FROM Trips WHERE CustomerID=@id AND PaymentStatus='Paid'",
                CustomerId).ToString("N0");

            object fav = Helper.DBHelper.ExecuteScalar(
                "SELECT TOP 1 v.Name FROM Trips t INNER JOIN VehicleTypes v ON t.VehicleTypeID=v.VehicleTypeID " +
                "WHERE t.CustomerID=@id GROUP BY v.Name ORDER BY COUNT(*) DESC",
                new SqlParameter("@id", CustomerId));
            lblFavoriteVehicle.Text = fav == null ? "--" : fav.ToString();
        }

        /// <summary>
        /// Swaps the default avatar for the uploaded profile photo. ProfilePhotoUrl is NULL
        /// until the customer uploads one on Profile.aspx, so the avatar stays as the fallback.
        /// </summary>
        private void ShowPhoto(object storedPath)
        {
            string path = storedPath == null || storedPath == DBNull.Value ? "" : storedPath.ToString().Trim();
            if (path.Length == 0)
            {
                pnlPhoto.Visible = false;
                pnlAvatar.Visible = true;
                return;
            }

            if (path.StartsWith("http://") || path.StartsWith("https://") || path.StartsWith("/"))
                imgProfilePhoto.ImageUrl = path;
            else if (path.StartsWith("~/"))
                imgProfilePhoto.ImageUrl = ResolveUrl(path);
            else
                imgProfilePhoto.ImageUrl = ResolveUrl("~/" + path);

            pnlPhoto.Visible = true;
            pnlAvatar.Visible = false;
        }

        private int ScalarInt(string sql, int customerId)
        {
            object o = Helper.DBHelper.ExecuteScalar(sql, new SqlParameter("@id", customerId));
            return o == null || o == DBNull.Value ? 0 : Convert.ToInt32(o);
        }

        // RequestedAt is stored in UTC, and the rest of this page reads local dates by
        // shifting it forward, so the charts have to shift it the same way or a trip booked
        // late in the evening lands on the wrong day. 390 minutes is the +6:30 the existing
        // month query already uses.
        private const int LocalOffsetMinutes = 390;

        private string _income7DayJson;
        private string _todayTripsJson;

        /// <summary>
        /// Seven days of spend, oldest first, ending today. Drawn as the spline on the page.
        /// </summary>
        public string Income7DayJson
        {
            get
            {
                if (_income7DayJson == null) LoadIncome7DayData();
                return _income7DayJson;
            }
        }

        /// <summary>
        /// Today's trips split by outcome, for the ring on the page.
        /// </summary>
        public string TodayTripsJson
        {
            get
            {
                if (_todayTripsJson == null) LoadTodayTripsData();
                return _todayTripsJson;
            }
        }

        /// <summary>
        /// Seven days of paid income, one entry per day oldest first, so the line has a point
        /// for every day rather than only for the days that happened to have a trip. A day
        /// with no paid trip is a zero, not a gap.
        ///
        /// The filter is PaymentStatus, not Status. A trip can be Completed and still Unpaid,
        /// and counting that as income would overstate what the customer has actually paid. It
        /// is also the same rule the Total Spent figure above uses, so the chart breaks down a
        /// number that is already on this page instead of quietly meaning something else.
        /// </summary>
        private void LoadIncome7DayData()
        {
            if (_income7DayJson != null) return;

            DateTime today = LocalToday();
            DateTime from = today.AddDays(-6);

            DataTable income = Helper.DBHelper.ExecuteQuery(
                "SELECT CAST(DATEADD(MINUTE, " + LocalOffsetMinutes + ", RequestedAt) AS DATE) AS D, " +
                "SUM(Fare) AS Total " +
                "FROM Trips WHERE CustomerID=@id AND PaymentStatus='Paid' " +
                "AND DATEADD(MINUTE, " + LocalOffsetMinutes + ", RequestedAt) >= @from " +
                "GROUP BY CAST(DATEADD(MINUTE, " + LocalOffsetMinutes + ", RequestedAt) AS DATE)",
                new SqlParameter("@id", CustomerId),
                new SqlParameter("@from", from));

            var byDay = new Dictionary<DateTime, long>();
            foreach (DataRow r in income.Rows)
            {
                if (r["D"] == DBNull.Value) continue;
                DateTime day = Convert.ToDateTime(r["D"]).Date;
                decimal amount = Convert.ToDecimal(r["Total"] == DBNull.Value ? 0m : r["Total"]);
                byDay[day] = (long)Math.Round(amount, MidpointRounding.AwayFromZero);
            }

            var labels = new List<string>(7);
            var values = new List<long>(7);
            var tips = new List<string>(7);
            long weekTotal = 0;
            long best = long.MinValue;
            int bestIndex = 0;

            for (int i = 0; i < 7; i++)
            {
                DateTime day = from.AddDays(i);
                long amount = byDay.ContainsKey(day) ? byDay[day] : 0L;
                if (amount > best) { best = amount; bestIndex = i; }
                weekTotal += amount;

                labels.Add(day.ToString("ddd dd", CultureInfo.CurrentCulture));
                values.Add(amount);
                tips.Add(day.ToString("ddd dd MMM yyyy", CultureInfo.CurrentCulture));
            }

            _income7DayJson = new JavaScriptSerializer().Serialize(new
            {
                labels = labels,
                values = values,
                tips = tips,
                total = weekTotal,
                best = best == long.MinValue ? 0L : best,
                bestIndex = bestIndex,
                currency = "MMK"
            });
        }

        /// <summary>
        /// Today's trips split by outcome, for the ring on the page.
        ///
        /// Only Completed and Cancelled are matched by name and everything else counts as in
        /// progress, so the slices add up to the trips actually requested today. A status
        /// added to the database later then shows up as in progress instead of quietly
        /// disappearing from the chart.
        /// </summary>
        private void LoadTodayTripsData()
        {
            if (_todayTripsJson != null) return;

            DateTime today = LocalToday();

            DataTable todayRows = Helper.DBHelper.ExecuteQuery(
                "SELECT Status, COUNT(*) AS C FROM Trips WHERE CustomerID=@id " +
                "AND CAST(DATEADD(MINUTE, " + LocalOffsetMinutes + ", RequestedAt) AS DATE) = @today " +
                "GROUP BY Status",
                new SqlParameter("@id", CustomerId),
                new SqlParameter("@today", today));

            int completed = 0, cancelled = 0, inProgress = 0;
            foreach (DataRow r in todayRows.Rows)
            {
                int c = Convert.ToInt32(r["C"]);
                string status = r["Status"] == DBNull.Value ? "" : r["Status"].ToString();
                if (status == "Completed") completed += c;
                else if (status == "Cancelled") cancelled += c;
                else inProgress += c;                  /* Requested, Accepted, Arrived, Started */
            }

            _todayTripsJson = new JavaScriptSerializer().Serialize(new
            {
                completed = completed,
                cancelled = cancelled,
                inProgress = inProgress,
                total = completed + cancelled + inProgress,
                date = today.ToString("ddd dd MMM yyyy", CultureInfo.CurrentCulture)
            });
        }

        /// <summary>
        /// Today's date in the same local time the SQL above groups by, taken from the clock
        /// rather than from the database so it cannot disagree with itself.
        /// </summary>
        private static DateTime LocalToday()
        {
            return DateTime.UtcNow.AddMinutes(LocalOffsetMinutes).Date;
        }

    }
}