using System;
using System.Collections.Generic;
using System.Data;
using System.Globalization;
using System.Web.Script.Serialization;

namespace TripWay.Admin
{
    public partial class DashboardPage : Helper.ListPageBase
    {
        private string _driversOnlineJson;
        private string _revenue7DayJson;
        private string _adminTodayTripsJson;

        /// <summary>Share of the fleet currently on the road, drawn as the ring on the page.</summary>
        public string DriversOnlineJson
        {
            get { return _driversOnlineJson ?? string.Empty; }
        }

        /// <summary>Seven days of paid platform income, oldest first. Drawn as the spline.</summary>
        public string Revenue7DayJson
        {
            get { return _revenue7DayJson ?? string.Empty; }
        }

        /// <summary>Today's trips split by outcome, for the ring on the page.</summary>
        public string AdminTodayTripsJson
        {
            get { return _adminTodayTripsJson ?? string.Empty; }
        }

        // +6:30, the same offset the counters above use, so the ring and the tiles agree about
        // which day "now" falls on.
        private const int LocalOffsetMinutes = 390;

        protected void Page_Load(object sender, EventArgs e)
        {
            Helper.AuthHelper.RequireAdmin(this);
            if (IsPostBack) return;

            lblToday.Text = Helper.TripHelper.FormatMyanmarTime(DateTime.UtcNow, "dd MMM yyyy");

            lblCustomers.Text = Helper.DBHelper.ExecuteScalar("SELECT COUNT(*) FROM Customers").ToString();
            lblDrivers.Text = Helper.DBHelper.ExecuteScalar("SELECT COUNT(*) FROM Drivers").ToString();
            lblTripsToday.Text = Helper.DBHelper.ExecuteScalar(
                "SELECT COUNT(*) FROM Trips WHERE CAST(DATEADD(MINUTE, 390, RequestedAt) AS DATE) = CAST(DATEADD(MINUTE, 390, SYSUTCDATETIME()) AS DATE)").ToString();
            /* Paid and completed, not merely "not cancelled". The old rule summed every trip that had not
               been cancelled, which swept in Accepted and Requested trips that are Unpaid and not
               finished, and the tile underneath was captioned "Completed trips" while showing
               them: 54,259 against 38,300 on the same day. That number is now the same rule the
               7-day income chart plots, so the tile is the chart's last point instead of a
               second, looser definition of income sitting next to it. */
            lblRevenueToday.Text = "MMK " + string.Format("{0:N0}",
                Convert.ToDecimal(Helper.DBHelper.ExecuteScalar(
                    "SELECT ISNULL(SUM(Fare),0) FROM Trips WHERE Status='Completed' AND PaymentStatus='Paid' " +
                    "AND CAST(DATEADD(MINUTE, 390, RequestedAt) AS DATE) = CAST(DATEADD(MINUTE, 390, SYSUTCDATETIME()) AS DATE)")));

            /* Both chart payloads are built here in Page_Load, not from a property getter. A getter
               first runs from the <%= %> during Render, after the response has begun flushing, so a
               query fault there truncates the page before the script tags carrying the data arrive:
               blank cards, headings stuck at zero, and an empty console. */
            LoadRevenue7DayData();
            LoadAdminTodayTripsData();

            lblWeekRevenue.Text = JsonLong(_revenue7DayJson, "total").ToString("N0");
            lblAdminTodayTotal.Text = JsonLong(_adminTodayTripsJson, "total") + " trips today";
            lblAdminTodayDate.Text = LocalToday().ToString("ddd dd MMM yyyy", CultureInfo.CurrentCulture);

            LoadDriversOnline();
        }

        /// <summary>
        /// Seven days of paid platform income, one entry per day oldest first, so the line has a
        /// point for every day instead of only the days somebody happened to book. A day with no
        /// paid trip is a zero, not a gap.
        ///
        /// Same Status and PaymentStatus rule as the Revenue Today tile and the driver's earnings
        /// chart: income is money that came in for a ride that finished.
        /// </summary>
        private void LoadRevenue7DayData()
        {
            if (_revenue7DayJson != null) return;

            DateTime from = LocalToday().AddDays(-6);

            DataTable rows = Helper.DBHelper.ExecuteQuery(
                "SELECT CAST(DATEADD(MINUTE, " + LocalOffsetMinutes + ", RequestedAt) AS DATE) AS D, " +
                "SUM(Fare) AS Total " +
                "FROM Trips WHERE Status='Completed' AND PaymentStatus='Paid' " +
                "AND DATEADD(MINUTE, " + LocalOffsetMinutes + ", RequestedAt) >= @from " +
                "GROUP BY CAST(DATEADD(MINUTE, " + LocalOffsetMinutes + ", RequestedAt) AS DATE)",
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

            _revenue7DayJson = new JavaScriptSerializer().Serialize(new
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
        /// Today's trips across the whole platform split by outcome, for the ring.
        ///
        /// The three buckets add up to the Trips Today tile above, because that tile counts every
        /// trip requested today whatever its status. Completed and Cancelled are matched by name
        /// and anything else is counted as in progress, so a status added to the database later
        /// shows up rather than quietly dropping out of the chart and leaving the ring short.
        /// </summary>
        private void LoadAdminTodayTripsData()
        {
            if (_adminTodayTripsJson != null) return;

            DataTable rows = Helper.DBHelper.ExecuteQuery(
                "SELECT Status, COUNT(*) AS C FROM Trips " +
                "WHERE CAST(DATEADD(MINUTE, " + LocalOffsetMinutes + ", RequestedAt) AS DATE) = @today " +
                "GROUP BY Status",
                new SqlParameter("@today", LocalToday()));

            int completed = 0, cancelled = 0, inProgress = 0;
            foreach (DataRow r in rows.Rows)
            {
                int c = Convert.ToInt32(r["C"]);
                switch ((r["Status"] == DBNull.Value ? "" : r["Status"].ToString()).Trim())
                {
                    case "Completed":
                        completed += c;
                        break;
                    case "Cancelled":
                        cancelled += c;
                        break;
                    case "Requested":
                    case "Accepted":
                    case "Arrived":
                    case "Started":
                        inProgress += c;
                        break;
                    default:
                        /* Still work sitting on today, so it counts as in progress rather than
                           falling out of the chart. */
                        inProgress += c;
                        break;
                }
            }

            _adminTodayTripsJson = new JavaScriptSerializer().Serialize(new
            {
                completed = completed,
                cancelled = cancelled,
                inProgress = inProgress,
                total = completed + cancelled + inProgress,
                date = LocalToday().ToString("ddd dd MMM yyyy", CultureInfo.CurrentCulture)
            });
        }

        /// <summary>
        /// Pulls one number back out of a payload we just serialized, so a heading can be filled in
        /// before any script runs. Returns 0 when there is no payload, which is the same value a
        /// failed load would have produced.
        /// </summary>
        private static long JsonLong(string json, string key)
        {
            if (string.IsNullOrEmpty(json)) return 0L;
            var parsed = new JavaScriptSerializer().Deserialize<Dictionary<string, object>>(json);
            return parsed != null && parsed.ContainsKey(key) && parsed[key] != null
                ? Convert.ToInt64(parsed[key], CultureInfo.InvariantCulture)
                : 0L;
        }

        /// <summary>
        /// How much of the fleet is available right now, which is what the ring shows, plus the
        /// list of who is online so an admin can still open a driver.
        ///
        /// Offline counts every driver who is not currently on the road, including any still
        /// waiting on KYC. That keeps the two slices adding up to the whole fleet, which is the
        /// whole point of a ring: "2 of 4 online" has to mean four drivers exist, not that two
        /// of them are hiding somewhere unaccounted for.
        ///
        /// The payload is built here in Page_Load rather than from a property getter. A getter
        /// would first run from the &lt;%= %&gt; in the markup during Render, once the response has
        /// started flushing, and a query fault at that point truncates the page so the script
        /// carrying the data never arrives and the card sits blank with nothing logged.
        /// </summary>
        private void LoadDriversOnline()
        {
            DataTable fleet = Helper.DBHelper.ExecuteQuery(
                "SELECT COUNT(*) AS Total, " +
                "SUM(CASE WHEN IsOnline = 1 AND KYCStatus = 'Approved' THEN 1 ELSE 0 END) AS OnlineCount " +
                "FROM Drivers");

            int total = Convert.ToInt32(fleet.Rows[0]["Total"]);
            int online = fleet.Rows[0]["OnlineCount"] == DBNull.Value
                ? 0
                : Convert.ToInt32(fleet.Rows[0]["OnlineCount"]);

            /* Online is the approved, on-the-road drivers; offline is every other driver on file,
               KYC-pending included, so the two figures always add up to the whole fleet. */
            int offline = total - online;

            _driversOnlineJson = new JavaScriptSerializer().Serialize(new
            {
                online = online,
                offline = offline,
                total = total,
                date = LocalToday().ToString("ddd dd MMM yyyy", CultureInfo.CurrentCulture)
            });

            /* Every figure on this card is written from the same numbers the ring plots, so they
               state the truth with scripting off or Chart.js missing, and the script cannot
               contradict them because it reads the same payload. Offline gets its own number
               rather than being left to subtract: "1 of 4 online" does not say how many are not,
               and that is the figure an admin is usually looking for. */
            lblOnlineCount.Text = online + " of " + total + " online";
            lblOnlineFigure.Text = online.ToString(CultureInfo.CurrentCulture);
            lblOfflineFigure.Text = offline.ToString(CultureInfo.CurrentCulture);
            lblFleetTotal.Text = total == 1
                ? "1 driver registered on the platform"
                : total + " drivers registered on the platform";
        }

        /// <summary>Today's date in the same local time the counters above group by.</summary>
        private static DateTime LocalToday()
        {
            return DateTime.UtcNow.AddMinutes(LocalOffsetMinutes).Date;
        }

    }
}