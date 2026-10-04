using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Web.Script.Serialization;

namespace TripWay.Driver
{
    public partial class DashboardPage : Helper.ListPageBase
    {
        private int DriverId { get { return Helper.AuthHelper.GetAccountId(); } }

        /// <summary>
        /// Rendered state of the online switch. The checkbox posts back through
        /// lnkToggleOnline, and every path that ends in a redraw has to refresh this
        /// so the knob never drifts away from the value in the database.
        /// </summary>
        public bool IsOnlineNow { get; private set; }

        /// <summary>
        /// Resolved path to the driver's own profile photo, or "" when none was uploaded.
        /// The banner keeps the vehicle glyph in that case instead of showing a broken image.
        /// </summary>
        public string ProfilePhoto { get; private set; }

        // +6:30, so a trip booked late in the evening lands on the day the driver worked.
        // The two chart queries group by the same offset, and the stat tiles above already
        // use it, so every figure on this page agrees about which day a trip belongs to.
        private const int LocalOffsetMinutes = 390;

        private string _earnings7DayJson;
        private string _driverTodayTripsJson;

        /// <summary>Seven days of paid fares, oldest first. Drawn as the spline on the page.</summary>
        public string Earnings7DayJson
        {
            get
            {
                if (_earnings7DayJson == null) LoadEarnings7DayData();
                return _earnings7DayJson;
            }
        }

        /// <summary>Today's trips split by outcome, for the ring on the page.</summary>
        public string DriverTodayTripsJson
        {
            get
            {
                if (_driverTodayTripsJson == null) LoadDriverTodayTripsData();
                return _driverTodayTripsJson;
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            Helper.AuthHelper.RequireDriver(this);
            if (IsPostBack) return;

            LoadData();
        }

        private void LoadData()
        {
            DataTable me = Helper.DBHelper.ExecuteQuery(
                "SELECT d.FullName, d.KYCStatus, d.IsOnline, d.ProfilePhotoUrl, v.Name AS VehicleName " +
                "FROM Drivers d INNER JOIN VehicleTypes v ON d.VehicleTypeID = v.VehicleTypeID " +
                "WHERE d.DriverID=@id",
                new SqlParameter("@id", DriverId));
            if (me.Rows.Count == 0)
            {
                Helper.AuthHelper.Logout();
                Response.Redirect("~/Login.aspx");
                return;
            }

            DataRow r = me.Rows[0];
            lblName.Text = r["FullName"].ToString();
            lblSub.Text = "Driving a " + r["VehicleName"] + " · " + r["KYCStatus"].ToString() + " KYC";
            ProfilePhoto = DriverPhotoSrc(r["ProfilePhotoUrl"]);

            // Show the photo only when there is one to show. A driver who never uploaded a
            // picture keeps the vehicle glyph, which is a deliberate placeholder rather than
            // a photo-shaped hole in the banner.
            bool hasPhoto = !string.IsNullOrEmpty(ProfilePhoto);
            pnlPhoto.Visible = hasPhoto;
            pnlPhotoFallback.Visible = !hasPhoto;
            if (hasPhoto) imgDriverPhoto.ImageUrl = ProfilePhoto;

            bool approved = r["KYCStatus"].ToString() == "Approved";
            IsOnlineNow = r["IsOnline"] != DBNull.Value && Convert.ToBoolean(r["IsOnline"]);
            lblOnlineText.Text = IsOnlineNow ? "Online" : "Offline";

            if (!approved)
            {
                pnlKycBanner.Visible = true;
                lblKycState.Text = r["KYCStatus"].ToString();
            }

            DataTable active = Helper.DBHelper.ExecuteQuery(
                "SELECT TOP 1 t.Status, s.Name AS ServiceName " +
                "FROM Trips t INNER JOIN ServiceTypes s ON t.ServiceTypeID = s.ServiceTypeID " +
                "WHERE t.DriverID=@id AND t.Status IN ('Accepted','Arrived','Started') ORDER BY t.TripID DESC",
                new SqlParameter("@id", DriverId));
            if (active.Rows.Count > 0)
            {
                pnlActiveBanner.Visible = true;
                lblActiveService.Text = active.Rows[0]["ServiceName"].ToString();
                lblActiveStatus.Text = active.Rows[0]["Status"].ToString();
            }

            lblTodayEarnings.Text = ScalarInt(
                "SELECT ISNULL(SUM(Fare),0) FROM Trips WHERE DriverID=@id AND Status='Completed' AND PaymentStatus='Paid' AND DATEADD(MINUTE, 390, RequestedAt) >= DATEFROMPARTS(YEAR(DATEADD(MINUTE, 390, SYSUTCDATETIME())), MONTH(DATEADD(MINUTE, 390, SYSUTCDATETIME())), DAY(DATEADD(MINUTE, 390, SYSUTCDATETIME())))").ToString("N0");
            lblTodayTrips.Text = ScalarInt(
                "SELECT COUNT(*) FROM Trips WHERE DriverID=@id AND Status='Completed' AND DATEADD(MINUTE, 390, RequestedAt) >= DATEFROMPARTS(YEAR(DATEADD(MINUTE, 390, SYSUTCDATETIME())), MONTH(DATEADD(MINUTE, 390, SYSUTCDATETIME())), DAY(DATEADD(MINUTE, 390, SYSUTCDATETIME())))").ToString("N0");
            lblTotalTrips.Text = ScalarInt(
                "SELECT COUNT(*) FROM Trips WHERE DriverID=@id AND Status='Completed'").ToString("N0");

            object rating = Helper.DBHelper.ExecuteScalar(
                "SELECT AverageRating FROM Drivers WHERE DriverID=@id",
                new SqlParameter("@id", DriverId));
            lblRating.Text = rating == null || rating == DBNull.Value ? "New" : Convert.ToDecimal(rating).ToString("0.0") + " " + Helper.TripHelper.StarSvg(true, "size-4");
        }

        /// <summary>
        /// Seven days of paid fares, one entry per day oldest first, so the line has a point
        /// for every day rather than only for the days the driver happened to work. A day with
        /// no paid trip is a zero, not a gap.
        ///
        /// Both Status and PaymentStatus are filtered: the driver only earns once the ride is
        /// finished and the money has actually come in, and this is the same rule the Today's
        /// Earnings tile above already uses.
        /// </summary>
        private void LoadEarnings7DayData()
        {
            if (_earnings7DayJson != null) return;

            DateTime today = LocalToday();
            DateTime from = today.AddDays(-6);

            DataTable rows = Helper.DBHelper.ExecuteQuery(
                "SELECT CAST(DATEADD(MINUTE, " + LocalOffsetMinutes + ", RequestedAt) AS DATE) AS D, " +
                "SUM(Fare) AS Total " +
                "FROM Trips WHERE DriverID=@id AND Status='Completed' AND PaymentStatus='Paid' " +
                "AND DATEADD(MINUTE, " + LocalOffsetMinutes + ", RequestedAt) >= @from " +
                "GROUP BY CAST(DATEADD(MINUTE, " + LocalOffsetMinutes + ", RequestedAt) AS DATE)",
                new SqlParameter("@id", DriverId),
                new SqlParameter("@from", from));

            var byDay = new Dictionary<DateTime, long>();
            foreach (DataRow r in rows.Rows)
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

            _earnings7DayJson = new JavaScriptSerializer().Serialize(new
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
        /// progress, so the slices add up to the trips actually assigned today. A status added
        /// to the database later then shows up instead of dropping out of the chart.
        /// </summary>
        private void LoadDriverTodayTripsData()
        {
            if (_driverTodayTripsJson != null) return;

            DateTime today = LocalToday();

            DataTable rows = Helper.DBHelper.ExecuteQuery(
                "SELECT Status, COUNT(*) AS C FROM Trips WHERE DriverID=@id " +
                "AND CAST(DATEADD(MINUTE, " + LocalOffsetMinutes + ", RequestedAt) AS DATE) = @today " +
                "GROUP BY Status",
                new SqlParameter("@id", DriverId),
                new SqlParameter("@today", today));

            int completed = 0, cancelled = 0, inProgress = 0;
            foreach (DataRow r in rows.Rows)
            {
                int c = Convert.ToInt32(r["C"]);
                string status = r["Status"] == DBNull.Value ? "" : r["Status"].ToString();
                if (status == "Completed") completed += c;
                else if (status == "Cancelled") cancelled += c;
                else inProgress += c;                  /* Requested, Accepted, Arrived, Started */
            }

            _driverTodayTripsJson = new JavaScriptSerializer().Serialize(new
            {
                completed = completed,
                cancelled = cancelled,
                inProgress = inProgress,
                total = completed + cancelled + inProgress,
                date = today.ToString("ddd dd MMM yyyy", CultureInfo.CurrentCulture)
            });
        }

        /// <summary>Today's date in the same local time the queries above group by.</summary>
        private static DateTime LocalToday()
        {
            return DateTime.UtcNow.AddMinutes(LocalOffsetMinutes).Date;
        }

        /// <summary>Reloads the page data whenever the base class redraws this page.</summary>
        protected override void OnPageIndexNavigated()
        {
            LoadData();
        }

        protected void lnkToggleOnline_Click(object sender, EventArgs e)
        {
            DataRow r = Helper.DBHelper.ExecuteQuery(
                "SELECT KYCStatus, IsOnline FROM Drivers WHERE DriverID=@id",
                new SqlParameter("@id", DriverId)).Rows[0];

            bool currentlyOnline = r["IsOnline"] != DBNull.Value && Convert.ToBoolean(r["IsOnline"]);
            bool nowOnline = !currentlyOnline;

            if (r["KYCStatus"].ToString() != "Approved")
            {
                // The checkbox already moved client side, so redraw from the database to
                // snap it back to the stored value rather than leaving it lying.
                LoadData();
                return;
            }

            Helper.DBHelper.ExecuteNonQuery(
                "UPDATE Drivers SET IsOnline=@o WHERE DriverID=@id",
                new SqlParameter("@o", nowOnline),
                new SqlParameter("@id", DriverId));

            Helper.TripHelper.LogActivity(nowOnline ? "DriverOnline" : "DriverOffline", null,
                "Driver " + DriverId + " went " + (nowOnline ? "online" : "offline") + ".");

            LoadData();
        }

        private int ScalarInt(string sql)
        {
            object o = Helper.DBHelper.ExecuteScalar(sql, new SqlParameter("@id", DriverId));
            return o == null || o == DBNull.Value ? 0 : Convert.ToInt32(o);
        }
    }
}