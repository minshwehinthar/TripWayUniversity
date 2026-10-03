using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.Threading;
using System.Web;
using System.Web.SessionState;
using TripWay.Helper;

namespace TripWay.Handlers
{
    /// <summary>
    /// Live JSON API used by the Customer / Driver realtime pages:
    /// trip status polling, driver request broadcasting, atomic accept,
    /// driver GPS updates + en-route GPS logging, chat, payment settle, rating.
    /// Both GET and POST are supported; all actions require an active session.
    /// </summary>
    public class TripApi : IHttpHandler, IRequiresSessionState
    {
        /// <summary>Where ride-chat photos are written, relative to the site root.</summary>
        private const string ChatPhotoFolder = "Uploads/ChatPhotos";

        /// <summary>
        /// Server-side cap for a chat photo. The browser downscales to roughly 1/10th of this
        /// before uploading, so this only ever rejects a hand-crafted or non-browser client.
        /// Kept under the default 4 MB ASP.NET request limit.
        /// </summary>
        private const int MaxChatPhotoBytes = 3 * 1024 * 1024;

        public void ProcessRequest(HttpContext context)
        {
            context.Response.ContentType = "application/json";
            string action = (context.Request["action"] ?? "").ToLowerInvariant();

            if (!AuthHelper.IsLoggedIn())
            {
                WriteJson(context, Err("not_authenticated", "Please login first."));
                return;
            }

            TripHelper.EnsureTripStops();
            TripHelper.EnsureEtaColumns();

            string role = AuthHelper.GetRole();
            int accountId = AuthHelper.GetAccountId();

            try
            {
                switch (action)
                {
                    // ---------- CUSTOMER ----------
                    case "mytrip":
                        if (role != "Customer") { WriteJson(context, Err("forbidden", "")); return; }
                        WriteJson(context, CustomerTrip(accountId));
                        break;
                    case "canceltrip":
                        if (role != "Customer") { WriteJson(context, Err("forbidden", "")); return; }
                        CancelTrip(accountId, "Customer");
                        WriteJson(context, Ok());
                        break;

                    // ---------- DRIVER ----------
                    case "requests":
                        if (role != "Driver") { WriteJson(context, Err("forbidden", "")); return; }
                        WriteJson(context, DriverRequests(accountId));
                        break;
                    case "accept":
                        if (role != "Driver") { WriteJson(context, Err("forbidden", "")); return; }
                        WriteJson(context, DriverAccept(accountId));
                        break;
                    case "mydrivertrip":
                        if (role != "Driver") { WriteJson(context, Err("forbidden", "")); return; }
                        WriteJson(context, DriverTrip(accountId));
                        break;
                    case "arrived":
                        if (role != "Driver") { WriteJson(context, Err("forbidden", "")); return; }
                        WriteJson(context, AdvanceStatus(accountId, "Arrived"));
                        break;
                    case "start":
                        if (role != "Driver") { WriteJson(context, Err("forbidden", "")); return; }
                        WriteJson(context, AdvanceStatus(accountId, "Started"));
                        break;
                    case "end":
                        if (role != "Driver") { WriteJson(context, Err("forbidden", "")); return; }
                        WriteJson(context, AdvanceStatus(accountId, "Completed"));
                        break;
                    case "driverlocation":
                        if (role != "Driver") { WriteJson(context, Err("forbidden", "")); return; }
                        WriteJson(context, DriverLocation(context, accountId));
                        break;
                    case "setpayment":
                        if (role != "Driver") { WriteJson(context, Err("forbidden", "")); return; }
                        WriteJson(context, SetPayment(accountId));
                        break;

                    // ---------- SHARED ----------
                    case "chatget":
                        WriteJson(context, ChatGet(context, role, accountId));
                        break;
                    case "chatsend":
                        WriteJson(context, ChatSend(context, role, accountId));
                        break;
                    case "settle":
                        if (role != "Customer") { WriteJson(context, Err("forbidden", "")); return; }
                        WriteJson(context, Settle(context, accountId));
                        break;
                    case "rate":
                        if (role != "Customer") { WriteJson(context, Err("forbidden", "")); return; }
                        WriteJson(context, Rate(context, accountId));
                        break;
                    default:
                        WriteJson(context, Err("unknown_action", "Unknown API action."));
                        break;
                }
            }
            catch (ThreadAbortException)
            {
                throw;
            }
            catch (Exception ex)
            {
                AppLog.Error("TripApi " + action + " failed: " + ex.Message);
                WriteJson(context, Err("error", "Server error: " + ex.Message));
            }
        }

        // ---------------------------------------------------------------- helpers

        private static void WriteJson(HttpContext context, StringBuilder sb)
        {
            context.Response.Write(sb.ToString());
        }

        private static StringBuilder Ok()
        {
            return new StringBuilder("{ \"ok\": true }");
        }

        private static StringBuilder Err(string code, string message)
        {
            StringBuilder sb = new StringBuilder();
            sb.Append("{ \"ok\": false, \"error\": \"").Append(Esc(code))
              .Append("\", \"message\": \"").Append(Esc(message)).Append("\" }");
            return sb;
        }

        private static string Esc(string value)
        {
            if (value == null) return "";
            return value.Replace("\\", "\\\\").Replace("\"", "\\\"")
                        .Replace("\r", " ").Replace("\n", " ").Replace("\t", " ");
        }

        private static int TripIdOf(HttpContext context)
        {
            int id;
            int.TryParse(context.Request["trip"], out id);
            return id;
        }

        private static string GetActiveTripColumn(string role, int accountId, string column)
        {
            string col = role == "Driver" ? "DriverID" : "CustomerID";
            object o = DBHelper.ExecuteScalar(
                "SELECT " + column + " FROM Trips WHERE " + col + "=@id AND Status IN ('Requested','Accepted','Arrived','Started') ORDER BY TripID DESC",
                new SqlParameter("@id", accountId));
            return o == null || o == DBNull.Value ? "" : o.ToString();
        }

        // ---------------------------------------------------------------- customer

        private static StringBuilder CustomerTrip(int customerId)
        {
            DataTable t = DBHelper.ExecuteQuery(
                @"SELECT TOP 1 t.*, c.FullName AS CustomerName, v.Name AS VehicleName, s.Name AS ServiceName, p.Name AS PackageName,
                    d.FullName AS DriverName, d.VehiclePlateNumber, d.CurrentLat, d.CurrentLng, d.AverageRating, d.PhoneNumber AS DriverPhone
                  FROM Trips t
                  INNER JOIN Customers c ON t.CustomerID = c.CustomerID
                  INNER JOIN VehicleTypes v ON t.VehicleTypeID = v.VehicleTypeID
                  INNER JOIN ServiceTypes s ON t.ServiceTypeID = s.ServiceTypeID
                  LEFT JOIN Packages p ON t.PackageID = p.PackageID
                  LEFT JOIN Drivers d ON t.DriverID = d.DriverID
                  WHERE t.CustomerID = @id AND t.Status IN ('Requested','Accepted','Arrived','Started','Completed')
                  ORDER BY t.TripID DESC",
                new SqlParameter("@id", customerId));
            if (t.Rows.Count == 0)
            {
                return new StringBuilder("{ \"ok\": true, \"trip\": null }");
            }
            return TripJson(t.Rows[0], null);
        }

        // ---------------------------------------------------------------- driver requests (broadcast)

        private static StringBuilder DriverRequests(int driverId)
        {
            object o = DBHelper.ExecuteScalar(
                "SELECT KYCStatus FROM Drivers WHERE DriverID=@id",
                new SqlParameter("@id", driverId));
            if (o == null || o.ToString() != "Approved")
            {
                return new StringBuilder("{ \"ok\": true, \"requests\": [], \"kyc\": \"Pending\" }");
            }
            int veh = TripHelper.GetDriverVehicleTypeId(driverId);
            DataTable t = DBHelper.ExecuteQuery(
                @"SELECT t.TripID, t.ServiceTypeID, s.Name AS ServiceName, v.Name AS VehicleName, p.Name AS PackageName,
                         t.PickupAddress, t.DropoffAddress, t.Fare, t.PickupLat, t.PickupLng, t.RequestedAt,
                         t.PaymentMethod, t.EstimatedKm,
                         c.FullName AS CustomerName, c.PhoneNumber AS CustomerPhone,
                         c.ProfilePhotoUrl AS CustomerPhoto, c.Gender AS CustomerGender,
                         c.CreatedAt AS CustomerSince
                  FROM Trips t
                  INNER JOIN ServiceTypes s ON t.ServiceTypeID = s.ServiceTypeID
                  INNER JOIN VehicleTypes v ON t.VehicleTypeID = v.VehicleTypeID
                  INNER JOIN Customers c ON t.CustomerID = c.CustomerID
                  LEFT JOIN Packages p ON t.PackageID = p.PackageID
                  WHERE t.Status = 'Requested' AND t.DriverID IS NULL AND t.VehicleTypeID = @veh
                  ORDER BY t.RequestedAt ASC",
                new SqlParameter("@veh", veh));
            double?[] driverLoc = TripHelper.GetDriverLocation(driverId);
            var stopCounts = new Dictionary<int, int>();
            if (TripHelper.TripStopsExists())
            {
                try
                {
                    DataTable cs = DBHelper.ExecuteQuery("SELECT TripID, COUNT(*) AS C FROM TripStops GROUP BY TripID");
                    foreach (DataRow cr in cs.Rows) stopCounts[Convert.ToInt32(cr["TripID"])] = Convert.ToInt32(cr["C"]);
                }
                catch (Exception ex) { AppLog.Error("Stop counts failed: " + ex.Message); }
            }
            StringBuilder sb = new StringBuilder();
            sb.Append("{ \"ok\": true, \"requests\": [");
            for (int i = 0; i < t.Rows.Count; i++)
            {
                DataRow r = t.Rows[i];
                int tripId = Convert.ToInt32(r["TripID"]);
                int sc;
                stopCounts.TryGetValue(tripId, out sc);
                if (i > 0) sb.Append(',');
                int etaSuggested = 0;
                if (driverLoc != null && r["PickupLat"] != DBNull.Value && r["PickupLng"] != DBNull.Value)
                {
                    etaSuggested = TripHelper.EstimateArrivalMinutes(
                        driverLoc[0].Value, driverLoc[1].Value,
                        Convert.ToDouble(r["PickupLat"]), Convert.ToDouble(r["PickupLng"]));
                }
                sb.Append("{ \"trip\": ").Append(tripId)
                  .Append(", \"service\": \"").Append(Esc(r["ServiceName"].ToString()))
                  .Append("\", \"vehicle\": \"").Append(Esc(r["VehicleName"].ToString()))
                  .Append("\", \"package\": \"").Append(Esc(r["PackageName"] == DBNull.Value ? "" : r["PackageName"].ToString()))
                  .Append("\", \"pickup\": \"").Append(Esc(r["PickupAddress"].ToString()))
                  .Append("\", \"dropoff\": \"").Append(Esc(r["DropoffAddress"].ToString()))
                  .Append("\", \"fare\": ").Append(r["Fare"])
                  .Append(", \"lat\": ").Append(r["PickupLat"])
                  .Append(", \"lng\": ").Append(r["PickupLng"])
                  .Append(", \"stops\": ").Append(sc)
                  .Append(", \"payment\": \"").Append(Esc(r["PaymentMethod"] == DBNull.Value ? "" : r["PaymentMethod"].ToString()))
                  .Append("\", \"tripKm\": ").Append(r["EstimatedKm"] == DBNull.Value ? "0" : r["EstimatedKm"].ToString())
                  .Append(", \"requestedAt\": \"").Append(Esc(TripHelper.ToMyanmarTime(r["RequestedAt"]).ToString("yyyy-MM-dd HH:mm:ss")))
                  .Append("\", \"requestedAgo\": \"").Append(Esc(AgoText(r["RequestedAt"])))
                  .Append("\", \"customer\": \"").Append(Esc(r["CustomerName"].ToString()))
                  .Append("\", \"customerPhone\": \"").Append(Esc(r["CustomerPhone"] == DBNull.Value ? "" : r["CustomerPhone"].ToString()))
                  .Append("\", \"customerPhoto\": \"").Append(Esc(PhotoUrl(r["CustomerPhoto"])))
                  .Append("\", \"customerGender\": \"").Append(Esc(r["CustomerGender"] == DBNull.Value ? "" : r["CustomerGender"].ToString()))
                  .Append("\", \"customerSince\": \"").Append(Esc(TripHelper.ToMyanmarTime(r["CustomerSince"]).ToString("yyyy-MM-dd")))
                  .Append("\", \"etaSuggested\": ").Append(etaSuggested)
                  .Append(" }");
            }
            sb.Append("] }");
            return sb;
        }

        /// <summary>
        /// Resolves a stored profile photo path (site relative) into a browser-usable
        /// absolute URL. Returns "" when the account has no photo.
        /// </summary>
        private static string PhotoUrl(object storedPath)
        {
            if (storedPath == null || storedPath == DBNull.Value) return "";
            string path = storedPath.ToString().Trim();
            if (path.Length == 0) return "";
            if (path.StartsWith("http://") || path.StartsWith("https://") || path.StartsWith("/"))
                return path;
            if (path.StartsWith("~/")) return VirtualPathUtility.ToAbsolute(path);
            return VirtualPathUtility.ToAbsolute("~/" + path);
        }

        // ---------------------------------------------------------------- atomic accept

        private static StringBuilder DriverAccept(int driverId)
        {
            int tripId = TripIdOf(HttpContext.Current);
            if (tripId == 0) return Err("bad_request", "Missing trip id.");

            int etaMinutes;
            if (!int.TryParse(HttpContext.Current.Request["eta"], out etaMinutes))
                return Err("bad_request", "Enter how many minutes you need to reach the pickup point.");

            string error;
            if (!TripHelper.TryAcceptTrip(driverId, tripId, etaMinutes, out error))
                return Err("taken", error);

            return Ok();
        }

        // ---------------------------------------------------------------- driver active trip

        private static StringBuilder DriverTrip(int driverId)
        {
            DataTable t = DBHelper.ExecuteQuery(
                @"SELECT TOP 1 t.*, c.FullName AS CustomerName, c.PhoneNumber AS CustomerPhone,
                    v.Name AS VehicleName, s.Name AS ServiceName, p.Name AS PackageName
                  FROM Trips t
                  INNER JOIN Customers c ON t.CustomerID = c.CustomerID
                  INNER JOIN VehicleTypes v ON t.VehicleTypeID = v.VehicleTypeID
                  INNER JOIN ServiceTypes s ON t.ServiceTypeID = s.ServiceTypeID
                  LEFT JOIN Packages p ON t.PackageID = p.PackageID
                  WHERE t.DriverID = @id AND t.Status IN ('Accepted','Arrived','Started')
                  ORDER BY t.TripID DESC",
                new SqlParameter("@id", driverId));
            if (t.Rows.Count == 0)
                return new StringBuilder("{ \"ok\": true, \"trip\": null }");
            return TripJson(t.Rows[0], "driver");
        }

        private static StringBuilder TripJson(DataRow r, string side)
        {
            bool driverSide = side == "driver";
            StringBuilder sb = new StringBuilder();
            sb.Append("{ \"ok\": true, \"trip\": { ")
              .Append("\"trip\": ").Append(r["TripID"])
              .Append(", \"status\": \"").Append(Esc(r["Status"].ToString()))
              .Append("\", \"service\": \"").Append(Esc(r["ServiceName"].ToString()))
              .Append("\", \"vehicle\": \"").Append(Esc(r["VehicleName"].ToString()))
              .Append("\", \"package\": \"").Append(Esc(r["PackageName"] == DBNull.Value ? "" : r["PackageName"].ToString()))
              .Append("\", \"fare\": ").Append(r["Fare"])
              .Append(", \"pickupLat\": ").Append(r["PickupLat"])
              .Append(", \"pickupLng\": ").Append(r["PickupLng"])
              .Append(", \"pickupAddress\": \"").Append(Esc(r["PickupAddress"].ToString()))
              .Append("\", \"dropoffLat\": ").Append(r["DropoffLat"] == DBNull.Value ? "0" : r["DropoffLat"].ToString())
              .Append(", \"dropoffLng\": ").Append(r["DropoffLng"] == DBNull.Value ? "0" : r["DropoffLng"].ToString())
              .Append(", \"dropoffAddress\": \"").Append(Esc(r["DropoffAddress"].ToString()))
              .Append("\", \"paymentMethod\": \"").Append(Esc(r["PaymentMethod"] == DBNull.Value ? "" : r["PaymentMethod"].ToString()))
              .Append("\", \"paymentStatus\": \"").Append(Esc(r["PaymentStatus"].ToString()))
              .Append("\", \"etaMinutes\": ").Append(EtaOf(r))
              .Append(", \"etaSetAt\": \"").Append(Esc(EtaSetAtIso(r)))
              .Append("\", \"etaArriveMs\": ").Append(EtaArrivalMs(r))
              .Append("\", \"requestedAt\": \"").Append(Esc(Helper.TripHelper.ToMyanmarTime(r["RequestedAt"]).ToString("yyyy-MM-dd HH:mm:ss")))
              .Append("\", \"acceptedAt\": \"").Append(Esc(r["AcceptedAt"] == DBNull.Value ? "" : Helper.TripHelper.ToMyanmarTime(r["AcceptedAt"]).ToString("yyyy-MM-dd HH:mm:ss")))
              .Append("\", \"arrivedAt\": \"").Append(Esc(r["ArrivedAt"] == DBNull.Value ? "" : Helper.TripHelper.ToMyanmarTime(r["ArrivedAt"]).ToString("yyyy-MM-dd HH:mm:ss")))
              .Append("\", \"startedAt\": \"").Append(Esc(r["StartedAt"] == DBNull.Value ? "" : Helper.TripHelper.ToMyanmarTime(r["StartedAt"]).ToString("yyyy-MM-dd HH:mm:ss")))
              .Append("\", \"completedAt\": \"").Append(Esc(r["CompletedAt"] == DBNull.Value ? "" : Helper.TripHelper.ToMyanmarTime(r["CompletedAt"]).ToString("yyyy-MM-dd HH:mm:ss")))
              .Append("\", \"customerName\": \"").Append(Esc(r["CustomerName"].ToString()))
              .Append("\", \"customerPhone\": \"").Append(Esc(r.ContainsColumn("CustomerPhone") && r["CustomerPhone"] != DBNull.Value ? r["CustomerPhone"].ToString() : ""))
              .Append("\", \"driverName\": \"").Append(Esc(r.ContainsColumn("DriverName") && r["DriverName"] != DBNull.Value ? r["DriverName"].ToString() : ""))
              .Append("\", \"plateNumber\": \"").Append(Esc(r.ContainsColumn("VehiclePlateNumber") && r["VehiclePlateNumber"] != DBNull.Value ? r["VehiclePlateNumber"].ToString() : ""))
              .Append("\", \"driverLat\": ").Append(r.ContainsColumn("CurrentLat") && r["CurrentLat"] != DBNull.Value ? r["CurrentLat"].ToString() : "0")
              .Append(", \"driverLng\": ").Append(r.ContainsColumn("CurrentLng") && r["CurrentLng"] != DBNull.Value ? r["CurrentLng"].ToString() : "0")
              .Append(", \"avgRating\": ").Append(r.ContainsColumn("AverageRating") && r["AverageRating"] != DBNull.Value ? r["AverageRating"].ToString() : "0")
              .Append(", \"driverPhone\": \"").Append(Esc(r.ContainsColumn("DriverPhone") && r["DriverPhone"] != DBNull.Value ? r["DriverPhone"].ToString() : ""))
              .Append(", \"stops\": ").Append(StopsJson(Convert.ToInt32(r["TripID"])))
              .Append(" } }");
            return sb;
        }

        // Arrival ETA given by the driver when accepting, as whole minutes (0 when never set).
        private static string EtaOf(DataRow r)
        {
            if (!r.ContainsColumn("EtaMinutes") || r["EtaMinutes"] == DBNull.Value) return "0";
            return Convert.ToInt32(r["EtaMinutes"]).ToString();
        }

        // When the ETA was given, in Myanmar time, as "yyyy-MM-dd HH:mm:ss" ("" when never set).
        private static string EtaSetAtIso(DataRow r)
        {
            if (!r.ContainsColumn("EtaSetAt") || r["EtaSetAt"] == DBNull.Value) return "";
            return TripHelper.ToMyanmarTime(r["EtaSetAt"]).ToString("yyyy-MM-dd HH:mm:ss");
        }

        // Promised arrival moment in epoch milliseconds (0 when the driver gave no ETA).
        private static string EtaArrivalMs(DataRow r)
        {
            if (!r.ContainsColumn("EtaMinutes") || r["EtaMinutes"] == DBNull.Value) return "0";
            long ms = TripHelper.EtaArrivalUnixMs(r["EtaSetAt"], Convert.ToInt32(r["EtaMinutes"]));
            return ms.ToString();
        }

        // "3 min ago" / "2 h ago" for a UTC timestamp, safe to render in any client clock zone.
        private static string AgoText(object utcValue)
        {
            if (utcValue == null || utcValue == DBNull.Value) return "";
            double minutes = (DateTime.UtcNow - TripHelper.AsUtcDateTime(utcValue)).TotalMinutes;
            if (minutes < 1) return "just now";
            if (minutes < 60) return ((int)minutes) + " min ago";
            if (minutes < 1440) return ((int)(minutes / 60)) + " h ago";
            return ((int)(minutes / 1440)) + " d ago";
        }

        // Ordered route points [lat, lng, address] from the trip; falls back to [] when none stored.
        private static string StopsJson(int tripId)
        {
            if (!TripHelper.TripStopsExists()) return "[]";
            try
            {
                DataTable st = DBHelper.ExecuteQuery(
                    "SELECT Lat, Lng, ISNULL(Address,'') AS A FROM TripStops WHERE TripID=@t ORDER BY OrderIndex",
                    new SqlParameter("@t", tripId));
                if (st.Rows.Count == 0) return "[]";
                var sb = new StringBuilder("[");
                bool first = true;
                foreach (DataRow s in st.Rows)
                {
                    if (!first) sb.Append(", ");
                    first = false;
                    sb.Append("[").Append(s["Lat"]).Append(", ").Append(s["Lng"]).Append(", \"")
                      .Append(Esc(s["A"].ToString())).Append("\"]");
                }
                sb.Append("]");
                return sb.ToString();
            }
            catch (Exception ex)
            {
                AppLog.Error("StopsJson failed for trip " + tripId + ": " + ex.Message);
                return "[]";
            }
        }

        private static StringBuilder AdvanceStatus(int driverId, string next)
        {
            int tripId = TripIdOf(HttpContext.Current);
            if (tripId == 0) return Err("bad_request", "Missing trip id.");

            string set = "";
            string whereStatus = "";
            switch (next)
            {
                case "Arrived":
                    set = "Status='Arrived', ArrivedAt=SYSUTCDATETIME()";
                    whereStatus = "AND Status='Accepted'";
                    break;
                case "Started":
                    set = "Status='Started', StartedAt=SYSUTCDATETIME(), PaymentStatus='Unpaid'";
                    whereStatus = "AND Status='Arrived'";
                    break;
                case "Completed":
                    set = "Status='Completed', CompletedAt=SYSUTCDATETIME()";
                    whereStatus = "AND Status='Started'";
                    break;
                default:
                    return Err("bad_request", "Unknown status.");
            }

            int rows;
            using (SqlConnection conn = DBHelper.GetConnection())
            {
                conn.Open();
                using (SqlCommand cmd = new SqlCommand(
                    "UPDATE Trips SET " + set + " WHERE TripID=@t AND DriverID=@d " + whereStatus, conn))
                {
                    cmd.Parameters.AddWithValue("@t", tripId);
                    cmd.Parameters.AddWithValue("@d", driverId);
                    rows = cmd.ExecuteNonQuery();
                }
            }
            if (rows == 0) return Err("state", "Trip is not in the correct state for this action.");
            TripHelper.LogActivity(next, tripId, "Driver " + driverId + " advanced trip to " + next + ".");
            return new StringBuilder("{ \"ok\": true, \"status\": \"" + next + "\" }");
        }

        // Driver marks the fare paid / unpaid on their own (started or completed) trip.
        private static StringBuilder SetPayment(int driverId)
        {
            int tripId = TripIdOf(HttpContext.Current);
            if (tripId == 0) return Err("bad_request", "Missing trip id.");
            string next = (HttpContext.Current.Request["status"] ?? "").Trim();
            if (next != "Paid" && next != "Unpaid") return Err("bad_request", "Invalid payment status.");

            int rows;
            using (SqlConnection conn = DBHelper.GetConnection())
            {
                conn.Open();
                using (SqlCommand cmd = new SqlCommand(
                    // Started only. This previously also allowed 'Completed', which let a
                    // driver reopen the payment on a finished trip and flip it back to
                    // Unpaid after the fact. Once a trip is Completed its payment is
                    // settled: the driver collects it via btnMarkPaid_Click, or the
                    // customer settles it via the Settle action.
                    "UPDATE Trips SET PaymentStatus=@p WHERE TripID=@t AND DriverID=@d AND Status='Started'", conn))
                {
                    cmd.Parameters.AddWithValue("@p", next);
                    cmd.Parameters.AddWithValue("@t", tripId);
                    cmd.Parameters.AddWithValue("@d", driverId);
                    rows = cmd.ExecuteNonQuery();
                }
            }
            if (rows == 0) return Err("state", "Trip is not in the correct state for this action.");
            TripHelper.LogActivity("Payment", tripId, "Driver " + driverId + " set payment to " + next + ".");
            return new StringBuilder("{ \"ok\": true, \"paymentStatus\": \"" + next + "\" }");
        }

        // ---------------------------------------------------------------- driver GPS

        private static StringBuilder DriverLocation(HttpContext context, int driverId)
        {
            double lat, lng;
            bool okLat = double.TryParse(context.Request["lat"], out lat);
            bool okLng = double.TryParse(context.Request["lng"], out lng);
            bool valid = okLat && okLng;
            if (!valid) return Err("bad_request", "Invalid location.");

            int tripId = TripIdOf(context);

            DBHelper.ExecuteNonQuery(
                "UPDATE Drivers SET CurrentLat=@lat, CurrentLng=@lng WHERE DriverID=@id",
                new SqlParameter("@lat", lat), new SqlParameter("@lng", lng), new SqlParameter("@id", driverId));

            if (tripId > 0)
            {
                // Breadcrumb GPS every ~12s while the trip is started (or en-route).
                object o = DBHelper.ExecuteScalar(
                    "SELECT Status FROM Trips WHERE TripID=@t AND DriverID=@d",
                    new SqlParameter("@t", tripId), new SqlParameter("@d", driverId));
                if (o != null && (o.ToString() == "Started" || o.ToString() == "Accepted" || o.ToString() == "Arrived"))
                {
                    DBHelper.ExecuteNonQuery(
                        "INSERT INTO TripGPSLogs (TripID, Lat, Lng) VALUES (@t, @lat, @lng)",
                        new SqlParameter("@t", tripId), new SqlParameter("@lat", lat), new SqlParameter("@lng", lng));
                }
            }
            return Ok();
        }

        // ---------------------------------------------------------------- chat

        /// <summary>
        /// Authorisation and status in a single round trip. Returns false when the trip does
        /// not belong to this account; <paramref name="status"/> always receives the live status
        /// so the caller can decide whether chat is open.
        /// </summary>
        private static bool ChatAccessOk(int tripId, string role, int accountId, out string status)
        {
            string col = role == "Driver" ? "DriverID" : "CustomerID";
            object o = DBHelper.ExecuteScalar(
                "SELECT Status FROM Trips WHERE TripID=@t AND " + col + "=@id",
                new SqlParameter("@t", tripId), new SqlParameter("@id", accountId));
            status = o == null || o == DBNull.Value ? "" : o.ToString();
            return status.Length > 0;
        }

        /// <summary>
        /// Chat opens the moment the driver accepts the request and stays open for the whole
        /// ride (Arrived / Started), then locks for good on Completed or Cancelled.
        /// </summary>
        private static bool ChatIsOpen(string status)
        {
            return status == "Accepted" || status == "Arrived" || status == "Started";
        }

        /// <summary>Banner text the UI shows in place of the composer when chat is locked.</summary>
        private static string ChatClosedReason(string status)
        {
            if (ChatIsOpen(status)) return "";
            if (status == "Completed") return "This ride is completed. Chat is closed.";
            if (status == "Cancelled") return "This ride was cancelled. Chat is closed.";
            if (status == "Requested") return "Chat opens once the driver accepts the request.";
            return "Chat is closed for this ride.";
        }

        /// <summary>
        /// Chat timestamps are stored as UTC DATETIME2 with no offset, so the raw ToString() is
        /// ambiguous. Emit ISO-8601 UTC and let the browser render it in the viewer's zone.
        /// </summary>
        private static string UtcStamp(object value)
        {
            if (value == null || value == DBNull.Value) return "";
            return DateTime.SpecifyKind(Convert.ToDateTime(value), DateTimeKind.Utc).ToString("o");
        }

        private static StringBuilder ChatGet(HttpContext context, string role, int accountId)
        {
            int tripId = TripIdOf(context);
            string status;
            if (tripId == 0 || !ChatAccessOk(tripId, role, accountId, out status)) return Err("forbidden", "");

            // History stays readable after the ride ends; only sending is blocked. The payload
            // tells the client whether to render the composer or the closed banner.
            bool open = ChatIsOpen(status);
            DataTable t = DBHelper.ExecuteQuery(
                "SELECT MessageID, SenderType, SenderID, MessageText, PhotoUrl, SentAt FROM ChatMessages WHERE TripID=@t ORDER BY MessageID ASC",
                new SqlParameter("@t", tripId));
            StringBuilder sb = new StringBuilder();
            sb.Append("{ \"ok\": true, \"chatOpen\": ").Append(open ? "true" : "false")
              .Append(", \"tripStatus\": \"").Append(Esc(status)).Append('"')
              .Append(", \"chatClosedReason\": \"").Append(Esc(ChatClosedReason(status))).Append('"')
              .Append(", \"messages\": [");
            for (int i = 0; i < t.Rows.Count; i++)
            {
                if (i > 0) sb.Append(',');
                sb.Append("{ \"id\": ").Append(t.Rows[i]["MessageID"])
                  .Append(", \"senderType\": \"").Append(Esc(t.Rows[i]["SenderType"].ToString()))
                  .Append("\", \"senderId\": ").Append(t.Rows[i]["SenderID"])
                  .Append(", \"text\": \"").Append(Esc(t.Rows[i]["MessageText"] == DBNull.Value ? "" : t.Rows[i]["MessageText"].ToString()))
                  .Append("\", \"photo\": \"").Append(Esc(t.Rows[i]["PhotoUrl"] == DBNull.Value ? "" : t.Rows[i]["PhotoUrl"].ToString()))
                  .Append("\", \"sentAt\": \"").Append(UtcStamp(t.Rows[i]["SentAt"]))
                  .Append("\" }");
            }
            sb.Append("] }");
            return sb;
        }

        private static StringBuilder ChatSend(HttpContext context, string role, int accountId)
        {
            int tripId = TripIdOf(context);
            string status;
            if (tripId == 0 || !ChatAccessOk(tripId, role, accountId, out status)) return Err("forbidden", "");

            // Hard lock. The UI hides the composer, but this is the real guard: once the ride is
            // completed or cancelled neither party can append text or photos. The photo path
            // below sits behind this same check.
            if (!ChatIsOpen(status)) return Err("chat_closed", ChatClosedReason(status));

            string text = (context.Request["text"] ?? "").Trim();
            if (text.Length > 1000) return Err("bad_request", "Message is too long (1000 characters max).");

            // Optional photo. A message may be a photo on its own, so an empty body is only a
            // problem when there is nothing to show at all.
            HttpPostedFile file = context.Request.Files["photo"];
            string photoUrl = "";
            if (file != null && file.ContentLength > 0)
            {
                // Client-side canvas downscale keeps this well under the limit; the server cap is
                // the backstop for a hand-crafted request.
                if (file.ContentLength > MaxChatPhotoBytes)
                    return Err("bad_request", "Photo is too large (" + (MaxChatPhotoBytes / (1024 * 1024)) + " MB max).");

                try
                {
                    photoUrl = TripHelper.StoreImage(file, ChatPhotoFolder, "chat");
                }
                catch (Exception ex)
                {
                    AppLog.Error("TripApi chat photo store failed: " + ex.Message);
                    return Err("bad_request", "That photo could not be saved.");
                }

                if (string.IsNullOrEmpty(photoUrl))
                    return Err("bad_request", "Only JPG and PNG photos can be sent.");
            }

            if (text.Length == 0 && photoUrl.Length == 0)
                return Err("bad_request", "Message is empty.");

            DBHelper.ExecuteNonQuery(
                "INSERT INTO ChatMessages (TripID, SenderType, SenderID, MessageText, PhotoUrl) VALUES (@t, @st, @sid, @text, @photo)",
                new SqlParameter("@t", tripId),
                new SqlParameter("@st", role == "Driver" ? "Driver" : "Customer"),
                new SqlParameter("@sid", accountId),
                new SqlParameter("@text", text.Length == 0 ? (object)DBNull.Value : text),
                new SqlParameter("@photo", photoUrl.Length == 0 ? (object)DBNull.Value : photoUrl));
            return Ok();
        }

        // ---------------------------------------------------------------- payment + rating

        private static StringBuilder Settle(HttpContext context, int customerId)
        {
            int tripId = TripIdOf(context);
            string method = (context.Request["method"] ?? "").Trim();
            if (tripId == 0 || (method != "Cash" && method != "KPay" && method != "WavePay" && method != "InApp"))
                return Err("bad_request", "Invalid payment method.");

            string okFields;
            // Confirm the trip belongs to this customer and is completed & unpaid.
            using (SqlConnection conn = DBHelper.GetConnection())
            {
                conn.Open();
                using (SqlCommand cmd = new SqlCommand(
                    @"DECLARE @amount DECIMAL(12,2);
                      SELECT @amount = Fare FROM Trips
                       WHERE TripID=@t AND CustomerID=@c AND Status='Completed' AND PaymentStatus='Unpaid';
                      IF @amount IS NULL BEGIN SELECT 0 AS done; RETURN; END;
                      INSERT INTO Payments (TripID, Amount, Method, Status, PaidAt) VALUES (@t, @amount, @m, 'Paid', SYSUTCDATETIME());
                      UPDATE Trips SET PaymentMethod=@m, PaymentStatus='Paid' WHERE TripID=@t;
                      SELECT 1 AS done;", conn))
                {
                    cmd.Parameters.AddWithValue("@t", tripId);
                    cmd.Parameters.AddWithValue("@c", customerId);
                    cmd.Parameters.AddWithValue("@m", method);
                    object done = cmd.ExecuteScalar();
                    okFields = Convert.ToInt32(done) == 1 ? "done" : "noop";
                }
            }
            if (okFields == "noop") return Err("state", "Trip not eligible for settlement.");
            TripHelper.LogActivity("Payment", tripId, "Customer " + customerId + " settled via " + method + ".");
            return Ok();
        }

        private static StringBuilder Rate(HttpContext context, int customerId)
        {
            int tripId = TripIdOf(context);
            int score;
            bool okScore = int.TryParse(context.Request["score"], out score) && score >= 1 && score <= 5;
            if (tripId == 0 || !okScore) return Err("bad_request", "Rating must be 1-5.");

            object driverO = DBHelper.ExecuteScalar(
                "SELECT DriverID FROM Trips WHERE TripID=@t AND CustomerID=@c AND Status='Completed'",
                new SqlParameter("@t", tripId), new SqlParameter("@c", customerId));
            if (driverO == null || driverO == DBNull.Value) return Err("state", "Trip not eligible for rating.");

            string comment = context.Request["comment"] ?? "";
            if (comment.Length > 500) comment = comment.Substring(0, 500);

            int rows = DBHelper.ExecuteNonQuery(
                @"IF NOT EXISTS (SELECT 1 FROM Ratings WHERE TripID=@t)
                    INSERT INTO Ratings (TripID, CustomerID, DriverID, Score, Comment) VALUES (@t, @c, @d, @s, @cmt)",
                new SqlParameter("@t", tripId), new SqlParameter("@c", customerId),
                new SqlParameter("@d", driverO), new SqlParameter("@s", score),
                new SqlParameter("@cmt", (object)comment ?? DBNull.Value));
            if (rows == 0) return Err("exists", "Already rated this trip.");

            DBHelper.ExecuteNonQuery(
                "UPDATE Drivers SET AverageRating = (SELECT ROUND(AVG(CONVERT(DECIMAL(3,2), Score)), 2) FROM Ratings WHERE DriverID=@d) WHERE DriverID=@d",
                new SqlParameter("@d", driverO));
            TripHelper.LogActivity("Rated", tripId, "Customer " + customerId + " rated driver " + driverO + " = " + score + "/5");
            return Ok();
        }

        private static StringBuilder CancelTrip(int customerId, string role)
        {
            DataTable t = DBHelper.ExecuteQuery(
                "SELECT TOP 1 TripID, Status FROM Trips WHERE CustomerID=@id AND Status = 'Requested' ORDER BY TripID DESC",
                new SqlParameter("@id", customerId));
            if (t.Rows.Count == 0) return Err("state", "You can only cancel a trip before a driver accepts it.");
            int tripId = Convert.ToInt32(t.Rows[0]["TripID"]);
            DBHelper.ExecuteNonQuery(
                "UPDATE Trips SET Status='Cancelled' WHERE TripID=@t AND Status='Requested'",
                new SqlParameter("@t", tripId));
            TripHelper.LogActivity("Cancelled", tripId, "Customer " + customerId + " cancelled the trip.");
            return Ok();
        }

        public bool IsReusable { get { return false; } }
    }

    internal static class DataRowExtensions
    {
        public static bool ContainsColumn(this DataRow row, string column)
        {
            return row.Table.Columns.Contains(column);
        }
    }
}