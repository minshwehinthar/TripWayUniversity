using System;
using System.Collections.Generic;
using System.Data;
using System.Globalization;
using System.Text;
using System.Web;

namespace TripWay.Helper
{
    /// <summary>
    /// Business helpers shared by Customer / Driver / Admin pages.
    /// </summary>
    public static class TripHelper
    {
        public const string RoleCustomer = "Customer";
        public const string RoleDriver = "Driver";
        public const string RoleAdmin = "Admin";

        public class RoutePoint
        {
            public decimal Lat;
            public decimal Lng;
            public string Address;
        }

        private static readonly TimeSpan MyanmarOffset = new TimeSpan(6, 30, 0);

        /// <summary>
        /// Converts a UTC value (as stored by SYSUTCDATETIME) to Myanmar Standard Time (UTC+6:30).
        /// Returns DateTime.MinValue when the value is null / DBNull.
        /// </summary>
        public static DateTime ToMyanmarTime(object utcValue)
        {
            if (utcValue == null || utcValue == DBNull.Value)
                return DateTime.MinValue;
            return Convert.ToDateTime(utcValue).Add(MyanmarOffset);
        }

        /// <summary>
        /// Formats a UTC value in Myanmar Standard Time. Returns "" for null / DBNull values.
        /// </summary>
        public static string FormatMyanmarTime(object utcValue, string format)
        {
            if (utcValue == null || utcValue == DBNull.Value)
                return "";
            return ToMyanmarTime(utcValue).ToString(format);
        }

        private static bool? _tripStopsChecked;
        private static readonly object TripStopCheckLock = new object();

        /// <summary>
        /// True when the TripStops table exists. Cached so we don't hit sys.tables on every call.
        /// </summary>
        public static bool TripStopsExists()
        {
            if (_tripStopsChecked.HasValue) return _tripStopsChecked.Value;
            lock (TripStopCheckLock)
            {
                if (_tripStopsChecked.HasValue) return _tripStopsChecked.Value;
                try
                {
                    object o = DBHelper.ExecuteScalar("SELECT COUNT(*) FROM sys.tables WHERE name = 'TripStops'");
                    _tripStopsChecked = Convert.ToInt32(o) > 0;
                }
                catch
                {
                    _tripStopsChecked = false;
                }
                return _tripStopsChecked.Value;
            }
        }

        /// <summary>
        /// Adds Packages.CoverPhotoUrl and the PackagePhotos gallery table when the App_Data
        /// upgrade script has not run yet, so package pages never hard-fail.
        /// Idempotent and cached; safe to call on every request.
        /// </summary>
        public static void EnsurePackagePhotos()
        {
            if (_packagePhotosChecked.HasValue) return;
            lock (SchemaCheckLock)
            {
                if (_packagePhotosChecked.HasValue) return;
                try
                {
                    DBHelper.ExecuteNonQuery(
                        @"IF COL_LENGTH('dbo.Packages','CoverPhotoUrl') IS NULL
                              ALTER TABLE dbo.Packages ADD CoverPhotoUrl NVARCHAR(300) NULL;
                          IF OBJECT_ID('dbo.PackagePhotos','U') IS NULL
                          BEGIN
                              CREATE TABLE dbo.PackagePhotos (
                                  PackagePhotoID INT IDENTITY(1,1) PRIMARY KEY,
                                  PackageID INT NOT NULL CONSTRAINT FK_PackagePhotos_Packages FOREIGN KEY REFERENCES dbo.Packages(PackageID),
                                  PhotoUrl NVARCHAR(300) NOT NULL,
                                  SortOrder INT NOT NULL DEFAULT 0,
                                  CreatedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
                              );
                              CREATE INDEX IX_PackagePhotos_Package ON dbo.PackagePhotos(PackageID, SortOrder);
                          END");
                    _packagePhotosChecked = true;
                }
                catch
                {
                    _packagePhotosChecked = false;
                }
            }
        }

        private static bool? _packageActiveChecked;

        /// <summary>
        /// Adds Packages.IsActive when the App_Data upgrade script has not run yet, so the
        /// status column used by the admin list and the customer booking page is always there.
        /// Existing packages stay active, so nothing vanishes from the booking page.
        /// Idempotent and cached; safe to call on every request.
        /// </summary>
        public static void EnsurePackageActive()
        {
            if (_packageActiveChecked.HasValue) return;
            lock (SchemaCheckLock)
            {
                if (_packageActiveChecked.HasValue) return;
                try
                {
                    DBHelper.ExecuteNonQuery(
                        "IF COL_LENGTH('dbo.Packages','IsActive') IS NULL ALTER TABLE dbo.Packages ADD IsActive BIT NOT NULL DEFAULT 1;");
                    _packageActiveChecked = true;
                }
                catch
                {
                    _packageActiveChecked = false;
                }
            }
        }

        public const string HotelPhotoFolder = "Uploads/HotelPhotos";

        /// <summary>
        /// Adds the Hotels table and Trips.HotelID when the App_Data upgrade script has not run
        /// yet, so hotel and booking pages never hard-fail.
        /// Idempotent and cached; safe to call on every request.
        /// </summary>
        public static void EnsureHotels()
        {
            if (_hotelsChecked.HasValue) return;
            lock (SchemaCheckLock)
            {
                if (_hotelsChecked.HasValue) return;
                try
                {
                    DBHelper.ExecuteNonQuery(
                        @"IF OBJECT_ID('dbo.Hotels','U') IS NULL
                          BEGIN
                              CREATE TABLE dbo.Hotels (
                                  HotelID INT IDENTITY(1,1) PRIMARY KEY,
                                  Name NVARCHAR(150) NOT NULL,
                                  Address NVARCHAR(300) NULL,
                                  Phone NVARCHAR(40) NULL,
                                  Email NVARCHAR(150) NULL,
                                  LogoPhotoUrl NVARCHAR(300) NULL,
                                  Lat DECIMAL(9,6) NOT NULL,
                                  Lng DECIMAL(9,6) NOT NULL,
                                  IsActive BIT NOT NULL DEFAULT 1,
                                  CreatedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
                              );
                              CREATE INDEX IX_Hotels_Active ON dbo.Hotels(IsActive, Name);
                          END
                          IF COL_LENGTH('dbo.Trips','HotelID') IS NULL
                              ALTER TABLE dbo.Trips ADD HotelID INT NULL
                                  CONSTRAINT FK_Trips_Hotels FOREIGN KEY REFERENCES dbo.Hotels(HotelID);");
                    _hotelsChecked = true;
                }
                catch
                {
                    _hotelsChecked = false;
                }
            }
        }

        /// <summary>
        /// Page-relative URL for a stored hotel logo, or "" when there is none.
        /// Accepts values already starting with "/", "~/" or "http(s):".
        /// </summary>
        public static string HotelPhotoUrl(object storedPath)
        {
            if (storedPath == null || storedPath == DBNull.Value) return "";
            string path = storedPath.ToString().Trim();
            if (path.Length == 0) return "";
            if (path.StartsWith("http://") || path.StartsWith("https://")) return path;
            if (path.StartsWith("~/")) return path.Substring(2);
            return path.TrimStart('/');
        }

        /// <summary>
        /// Bookable hotels for the customer side: active only, ordered by name.
        /// </summary>
        public static DataTable GetActiveHotels()
        {
            EnsureHotels();
            return DBHelper.ExecuteQuery(
                @"SELECT HotelID, Name, Address, Phone, Email, LogoPhotoUrl, Lat, Lng
                  FROM Hotels WHERE IsActive = 1 ORDER BY Name, HotelID");
        }

        /// <summary>
        /// One bookable hotel by id, or null when it does not exist, is inactive, or has
        /// no usable coordinates. The booking page re-reads the row server-side because
        /// the posted HotelID is ordinary form input and may be stale or hand-crafted.
        /// </summary>
        public static DataRow GetBookableHotel(int hotelId)
        {
            EnsureHotels();
            DataTable dt = DBHelper.ExecuteQuery(
                @"SELECT HotelID, Name, Address, Lat, Lng
                  FROM Hotels WHERE HotelID = @h AND IsActive = 1",
                new System.Data.SqlClient.SqlParameter("@h", hotelId));

            if (dt == null || dt.Rows.Count == 0) return null;

            DataRow row = dt.Rows[0];
            double lat, lng;
            if (!TryCoordinates(row["Lat"], out lat) || !TryCoordinates(row["Lng"], out lng)) return null;

            return row;
        }

        /// <summary>
        /// Reads a coordinate column that may arrive as decimal, DBNull or null without
        /// throwing. A hotel that cannot be read here is treated as unusable.
        /// </summary>
        private static bool TryCoordinates(object value, out double result)
        {
            result = 0;
            if (value == null || value == DBNull.Value) return false;
            try
            {
                result = Convert.ToDouble(value, System.Globalization.CultureInfo.InvariantCulture);
            }
            catch
            {
                return false;
            }
            // A real coordinate in this app is never exactly on a null island, and
            // NaN/Infinity must never survive into a distance calculation.
            return !double.IsNaN(result) && !double.IsInfinity(result) && result != 0;
        }

        private static bool? _adminPhotoChecked;
        private static bool? _driverPhotoChecked;

        /// <summary>
        /// Adds Drivers.ProfilePhotoUrl on the fly so the public About Us page cannot be the
        /// thing that throws if Upgrade 6 has not run yet. Mirrors EnsureHotels().
        /// </summary>
        /// <summary>
        /// Admins carry a profile photo too, and the column was added after the table shipped, so
        /// an existing database still needs it. Same self-healing shape as the driver photo: run
        /// once per application, retried if it failed rather than remembered as done.
        /// </summary>
        public static void EnsureAdminProfilePhoto()
        {
            if (_adminPhotoChecked.HasValue) return;
            lock (SchemaCheckLock)
            {
                if (_adminPhotoChecked.HasValue) return;
                try
                {
                    DBHelper.ExecuteNonQuery(
                        "IF COL_LENGTH('dbo.Admins','ProfilePhotoUrl') IS NULL " +
                        "ALTER TABLE dbo.Admins ADD ProfilePhotoUrl NVARCHAR(300) NULL;");
                    _adminPhotoChecked = true;
                }
                catch
                {
                    _adminPhotoChecked = false;
                }
            }
        }

        public static void EnsureDriverProfilePhoto()
        {
            if (_driverPhotoChecked.HasValue) return;
            lock (SchemaCheckLock)
            {
                if (_driverPhotoChecked.HasValue) return;
                try
                {
                    DBHelper.ExecuteNonQuery(
                        "IF COL_LENGTH('dbo.Drivers','ProfilePhotoUrl') IS NULL " +
                        "ALTER TABLE dbo.Drivers ADD ProfilePhotoUrl NVARCHAR(300) NULL;");
                    _driverPhotoChecked = true;
                }
                catch
                {
                    _driverPhotoChecked = false;
                }
            }
        }

        /// <summary>
        /// Brand icon for a payment method, or "" when the method has no icon
        /// (for example the in-app wallet). Callers should hide the &lt;img&gt; when empty.
        /// </summary>
        public static string PaymentMethodIcon(string method)
        {
            if (string.IsNullOrEmpty(method)) return "";
            switch (method.Trim().ToLowerInvariant())
            {
                case "kpay": return "~/KPay.jpeg";
                case "wavepay":
                case "wave": return "~/Wavepay.jpeg";
                case "cash": return "~/Cash.png";
                default: return "";
            }
        }

        /// <summary>
        /// Where administrator avatars live. Kept apart from the customer folder so the two sets
        /// of files can be reasoned about, and cleared, separately.
        /// </summary>
        public const string AdminPhotoFolder = "Uploads/AdminPhotos";

        public const string DriverPhotoFolder = "Uploads/DriverPhotos";

        /// <summary>
        /// Where customer avatars live. Shared by the admin create/edit pages and by
        /// Customer/Profile.aspx, so all of them read and write the same folder.
        /// </summary>
        public const string CustomerPhotoFolder = "Uploads/ProfilePhotos";

        /// <summary>Max upload size for a stored image: 4 MB.</summary>
        public const int MaxImageBytes = 4 * 1024 * 1024;

        /// <summary>
        /// Drivers.ProfilePhotoUrl. A dedicated profile photo, kept separate from the
        /// KYC document photos (NRC / licence / registration) which are never published.
        /// Returns "" when the driver has no photo, so callers can fall back to initials.
        /// </summary>
        public static string DriverPhotoUrl(object storedPath)
        {
            return HotelPhotoUrl(storedPath);
        }

        public static string AdminPhotoUrl(object storedPath)
        {
            return HotelPhotoUrl(storedPath);
        }

        /// <summary>
        /// Streams an uploaded file through ViewFile.ashx, which sends
        /// Content-Disposition: inline so browsers render it in place rather than
        /// downloading it. This is the URL used by the shared appOpenImage lightbox.
        /// </summary>
        public static string FileViewerUrl(object storedPath)
        {
            string value = storedPath == null || storedPath == DBNull.Value
                ? "" : storedPath.ToString().Trim();
            if (value.Length == 0) return "";
            return VirtualPathUtility.ToAbsolute("~/Handlers/ViewFile.ashx?f=")
                 + HttpUtility.UrlEncode(value);
        }

        /// <summary>True when the stored path points at a file the browser can show inline.</summary>
        public static bool IsViewableImage(object storedPath)
        {
            string ext = FileExtension(storedPath);
            return ext == ".jpg" || ext == ".jpeg" || ext == ".png"
                || ext == ".gif" || ext == ".webp";
        }

        /// <summary>True for PDFs, which the lightbox renders in an iframe rather than an img.</summary>
        public static bool IsPdfFile(object storedPath)
        {
            return FileExtension(storedPath) == ".pdf";
        }

        private static string FileExtension(object storedPath)
        {
            string value = storedPath == null || storedPath == DBNull.Value
                ? "" : storedPath.ToString().Trim();
            if (value.Length == 0) return "";
            return (System.IO.Path.GetExtension(value) ?? "").ToLowerInvariant();
        }

        /// <summary>
        /// Renders the data-doc-* attributes that the delegated click handler in
        /// Site.Master uses to open the shared image lightbox. Attribute-encoded,
        /// because the result is interpolated inside a double-quoted attribute.
        /// </summary>
        public static string DocDataAttrs(object viewerUrl, object label, object fileName, bool isPdf)
        {
            return " data-doc-src=\"" + HttpUtility.HtmlAttributeEncode(Convert.ToString(viewerUrl))
                 + "\" data-doc-label=\"" + HttpUtility.HtmlAttributeEncode(Convert.ToString(label))
                 + "\" data-doc-name=\"" + HttpUtility.HtmlAttributeEncode(Convert.ToString(fileName))
                 + "\" data-doc-pdf=\"" + (isPdf ? "1" : "0") + "\"";
        }

        /// <summary>
        /// Customers.ProfilePhotoUrl, same rules as DriverPhotoUrl. Returns "" when the
        /// customer has no photo so callers can fall back to initials.
        /// </summary>
        public static string CustomerPhotoUrl(object storedPath)
        {
            return HotelPhotoUrl(storedPath);
        }

        /// <summary>
        /// Stores an uploaded image under the given folder and returns the relative path to
        /// persist in the database, or null when the file is not an acceptable image.
        /// </summary>
        public static string StoreImage(HttpPostedFile file, string folder, string prefix)
        {
            if (!IsAcceptedImage(file)) return null;

            string dir = HttpContext.Current.Server.MapPath("~/" + folder);
            if (!System.IO.Directory.Exists(dir)) System.IO.Directory.CreateDirectory(dir);

            string ext = System.IO.Path.GetExtension(file.FileName).ToLowerInvariant();
            if (ext != ".jpg" && ext != ".jpeg" && ext != ".png") return null;

            string name = prefix + "_" + DateTime.Now.Ticks + ext;
            file.SaveAs(System.IO.Path.Combine(dir, name));
            return folder + "/" + name;
        }

        /// <summary>
        /// Deletes a previously stored photo, but only if it really lives inside the expected
        /// upload folder, so a crafted database value cannot be used to delete other files.
        /// </summary>
        public static void DeleteStoredPhoto(string relativeUrl, string folder)
        {
            if (string.IsNullOrWhiteSpace(relativeUrl)) return;
            try
            {
                string root = HttpContext.Current.Server.MapPath("~/" + folder);
                string full = HttpContext.Current.Server.MapPath("~/" + relativeUrl);
                if (string.IsNullOrEmpty(full) || string.IsNullOrEmpty(root)) return;

                // Require the separator too, so "Uploads/DriverPhotosEvil" cannot pass.
                string prefix = root.EndsWith("/") || root.EndsWith("\\") ? root : root + "/";
                if (full.StartsWith(prefix, StringComparison.OrdinalIgnoreCase) && System.IO.File.Exists(full))
                    System.IO.File.Delete(full);
            }
            catch { }
        }

        private static bool IsAcceptedImage(HttpPostedFile file)
        {
            if (file == null || file.ContentLength <= 0 || file.ContentLength > MaxImageBytes) return false;
            string ext = System.IO.Path.GetExtension(file.FileName).ToLowerInvariant();
            return ext == ".jpg" || ext == ".jpeg" || ext == ".png";
        }

        public const string PackagePhotoFolder = "Uploads/PackagePhotos";
        /// <summary>
        /// Page-relative URL for a stored package photo, or "" when there is none.
        /// Accepts values already starting with "/", "~/" or "http(s):".
        /// </summary>
        public static string PackagePhotoUrl(object storedPath)
        {
            if (storedPath == null || storedPath == DBNull.Value) return "";
            string path = storedPath.ToString().Trim();
            if (path.Length == 0) return "";
            if (path.StartsWith("http://") || path.StartsWith("https://")) return path;
            if (path.StartsWith("~/")) return path.Substring(2);
            return path.TrimStart('/');
        }

        /// <summary>
        /// Gallery photos of a package, ordered for display.
        /// </summary>
        public static DataTable GetPackagePhotos(int packageId)
        {
            EnsurePackagePhotos();
            return DBHelper.ExecuteQuery(
                "SELECT PackagePhotoID, PhotoUrl, SortOrder FROM PackagePhotos WHERE PackageID=@id ORDER BY SortOrder, PackagePhotoID",
                new System.Data.SqlClient.SqlParameter("@id", packageId));
        }

        /// <summary>
        /// Creates TripStops if it is missing so route/stop queries never hard-fail before the
        /// App_Data upgrade script runs. Idempotent; safe to call on every request (cheap after first).
        /// </summary>
        public static void EnsureTripStops()
        {
            if (TripStopsExists()) return;
            try
            {
                DBHelper.ExecuteNonQuery(
                    @"IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'TripStops')
                      BEGIN
                          CREATE TABLE dbo.TripStops (
                              TripStopID INT IDENTITY(1,1) PRIMARY KEY,
                              TripID INT NOT NULL CONSTRAINT FK_TripStops_Trips FOREIGN KEY REFERENCES dbo.Trips(TripID),
                              Lat DECIMAL(9,6) NOT NULL,
                              Lng DECIMAL(9,6) NOT NULL,
                              Address NVARCHAR(300) NULL,
                              OrderIndex INT NOT NULL DEFAULT 0
                          );
                          CREATE INDEX IX_TripStops_TripID ON dbo.TripStops(TripID);
                      END");
                _tripStopsChecked = true;
            }
            catch
            {
                _tripStopsChecked = false;
            }
        }

        /// <summary>
        /// Package trips booked before the itinerary was stored have no TripStops at all, so
        /// their map showed nothing but the pickup pin. Fills the package places in once, for
        /// those trips only: a trip that already has stops keeps the route it was booked with.
        /// </summary>
        public static void EnsurePackageStops(int tripId, DataRow tripRow)
        {
            if (tripRow == null || tripId <= 0) return;
            if (!tripRow.Table.Columns.Contains("PackageID") || tripRow["PackageID"] == DBNull.Value) return;
            if (!TripStopsExists()) return;

            try
            {
                if (Convert.ToInt32(DBHelper.ExecuteScalar(
                    "SELECT COUNT(*) FROM TripStops WHERE TripID=@t",
                    new System.Data.SqlClient.SqlParameter("@t", tripId))) > 0) return;

                DataTable places = DBHelper.ExecuteQuery(
                    "SELECT PlaceName, Lat, Lng FROM PackagePlaces WHERE PackageID=@p ORDER BY OrderIndex, PackagePlaceID",
                    new System.Data.SqlClient.SqlParameter("@p", Convert.ToInt32(tripRow["PackageID"])));
                if (places.Rows.Count == 0) return;

                var points = new List<RoutePoint>
                {
                    new RoutePoint
                    {
                        Lat = Convert.ToDecimal(tripRow["PickupLat"]),
                        Lng = Convert.ToDecimal(tripRow["PickupLng"]),
                        Address = tripRow["PickupAddress"] == DBNull.Value ? "" : tripRow["PickupAddress"].ToString()
                    }
                };
                foreach (DataRow p in places.Rows)
                {
                    var point = new RoutePoint
                    {
                        Lat = Convert.ToDecimal(p["Lat"]),
                        Lng = Convert.ToDecimal(p["Lng"]),
                        Address = p["PlaceName"] == DBNull.Value ? "" : p["PlaceName"].ToString()
                    };
                    // The pickup may already be the first place; do not show it twice.
                    if (points.Count > 0 && SameSpot(points[0], point)) continue;
                    points.Add(point);
                }

                for (int i = 0; i < points.Count; i++)
                {
                    DBHelper.ExecuteNonQuery(
                        "INSERT INTO TripStops (TripID, Lat, Lng, Address, OrderIndex) VALUES (@t, @lat, @lng, @a, @o)",
                        new System.Data.SqlClient.SqlParameter("@t", tripId),
                        new System.Data.SqlClient.SqlParameter("@lat", points[i].Lat),
                        new System.Data.SqlClient.SqlParameter("@lng", points[i].Lng),
                        new System.Data.SqlClient.SqlParameter("@a", (object)points[i].Address ?? DBNull.Value),
                        new System.Data.SqlClient.SqlParameter("@o", i + 1));
                }

                // These trips were booked without a destination. The last place is where the
                // ride ends, so record it and the map can mark it.
                if (tripRow.Table.Columns.Contains("DropoffLat") && tripRow["DropoffLat"] == DBNull.Value)
                {
                    var end = points[points.Count - 1];
                    DBHelper.ExecuteNonQuery(
                        "UPDATE Trips SET DropoffLat=@lat, DropoffLng=@lng, DropoffAddress=@a WHERE TripID=@t",
                        new System.Data.SqlClient.SqlParameter("@t", tripId),
                        new System.Data.SqlClient.SqlParameter("@lat", end.Lat),
                        new System.Data.SqlClient.SqlParameter("@lng", end.Lng),
                        new System.Data.SqlClient.SqlParameter("@a", (object)end.Address ?? DBNull.Value));
                    tripRow["DropoffLat"] = end.Lat;
                    tripRow["DropoffLng"] = end.Lng;
                    if (tripRow.Table.Columns.Contains("DropoffAddress")) tripRow["DropoffAddress"] = end.Address;
                }
            }
            catch
            {
                // A trip without its itinerary is still readable, just with a shorter map.
            }
        }

        private static bool SameSpot(RoutePoint a, RoutePoint b)
        {
            return Math.Abs((double)a.Lat - (double)b.Lat) < 0.000001
                && Math.Abs((double)a.Lng - (double)b.Lng) < 0.000001;
        }

        /// <summary>
        /// Full ordered route (start point, interval points, end point) from TripStops,
        /// falling back to the trip's pickup/dropoff columns for trips created before stops existed.
        /// </summary>
        public static List<RoutePoint> GetOrderedStops(int tripId, DataRow tripRow)
        {
            EnsurePackageStops(tripId, tripRow);

            var list = new List<RoutePoint>();
            if (TripStopsExists())
            {
                DataTable st = DBHelper.ExecuteQuery(
                    "SELECT Lat, Lng, ISNULL(Address,'') AS A FROM TripStops WHERE TripID=@t ORDER BY OrderIndex",
                    new System.Data.SqlClient.SqlParameter("@t", tripId));
                foreach (DataRow s in st.Rows)
                {
                    list.Add(new RoutePoint
                    {
                        Lat = Convert.ToDecimal(s["Lat"]),
                        Lng = Convert.ToDecimal(s["Lng"]),
                        Address = s["A"].ToString()
                    });
                }
            }
            if (list.Count == 0 && tripRow != null)
            {
                list.Add(new RoutePoint
                {
                    Lat = Convert.ToDecimal(tripRow["PickupLat"]),
                    Lng = Convert.ToDecimal(tripRow["PickupLng"]),
                    Address = tripRow["PickupAddress"] == DBNull.Value ? "" : tripRow["PickupAddress"].ToString()
                });
                if (tripRow["DropoffLat"] != DBNull.Value)
                {
                    list.Add(new RoutePoint
                    {
                        Lat = Convert.ToDecimal(tripRow["DropoffLat"]),
                        Lng = Convert.ToDecimal(tripRow["DropoffLng"]),
                        Address = tripRow["DropoffAddress"] == DBNull.Value ? "" : tripRow["DropoffAddress"].ToString()
                    });
                }
            }
            return list;
        }

        /// <summary>
        /// Ordered route list HTML (green start, blue intervals, red end) for trip detail pages.
        /// Only the place text is shown: raw coordinates are noise for a customer or a driver,
        /// and the driver gets the real numbers in the address column anyway. A stop that was
        /// pinned without an address reads "Pinned point" rather than a pair of numbers.
        /// </summary>
        public static string RouteListHtml(int tripId, DataRow tripRow)
        {
            var points = GetOrderedStops(tripId, tripRow);
            if (points.Count == 0) return "";
            var sb = new StringBuilder();
            for (int i = 0; i < points.Count; i++)
            {
                string color = i == 0 ? "bg-emerald-500" : (i == points.Count - 1 ? "bg-rose-500" : "bg-blue-500");
                string label = points.Count == 2 ? (i == 0 ? "A" : "B") : (i + 1).ToString();
                string addr = string.IsNullOrWhiteSpace(points[i].Address) ? "Pinned point" : points[i].Address;
                sb.Append("<div class=\"flex items-start gap-2 py-1\">")
                  .Append("<span class=\"flex items-center justify-center size-5 rounded-full ").Append(color)
                  .Append(" text-white text-[10px] font-bold shrink-0 mt-0.5\">").Append(label).Append("</span>")
                  .Append("<span class=\"text-sm text-gray-600\">").Append(HttpUtility.HtmlEncode(addr)).Append("</span></div>");
            }
            return sb.ToString();
        }

        /// <summary>
        /// Detail-page map JSON: pickup/drop markers plus the full ordered "stops" array
        /// (start, intervals, end) and the live GPS path.
        /// </summary>
        public static string BuildDetailPathJson(int tripId, DataRow r)
        {
            var sb = new StringBuilder("{ \"pickup\": [");
            sb.Append(r["PickupLat"]).Append(", ").Append(r["PickupLng"]).Append("], \"drop\": ");
            if (r["DropoffLat"] == DBNull.Value) sb.Append("null");
            else sb.Append("[").Append(r["DropoffLat"]).Append(", ").Append(r["DropoffLng"]).Append("]");
            sb.Append(", \"stops\": [");
            var points = GetOrderedStops(tripId, r);
            for (int i = 0; i < points.Count; i++)
            {
                if (i > 0) sb.Append(", ");
                sb.Append("[").Append(points[i].Lat).Append(", ").Append(points[i].Lng).Append("]");
            }
            sb.Append("], \"path\": [");
            bool first = true;
            foreach (DataRow g in DBHelper.ExecuteQuery(
                "SELECT Lat, Lng FROM TripGPSLogs WHERE TripID=@t ORDER BY LogID ASC",
                new System.Data.SqlClient.SqlParameter("@t", tripId)).Rows)
            {
                if (!first) sb.Append(", ");
                first = false;
                sb.Append("[").Append(g["Lat"]).Append(", ").Append(g["Lng"]).Append("]");
            }
            sb.Append("] }");
            return sb.ToString();
        }

        public static bool IsDriverApproved(int driverId)
        {
            object o = DBHelper.ExecuteScalar(
                "SELECT COUNT(*) FROM Drivers WHERE DriverID=@id AND KYCStatus='Approved'",
                new System.Data.SqlClient.SqlParameter("@id", driverId));
            return Convert.ToInt32(o) > 0;
        }

        public static int GetDriverVehicleTypeId(int driverId)
        {
            object o = DBHelper.ExecuteScalar(
                "SELECT VehicleTypeID FROM Drivers WHERE DriverID=@id",
                new System.Data.SqlClient.SqlParameter("@id", driverId));
            return o == DBNull.Value || o == null ? 0 : Convert.ToInt32(o);
        }

        /// <summary>
        /// Records one audit row. The actor is taken from the signed-in session so callers do not
        /// have to repeat who they are, and it stays NULL for background or anonymous work, which
        /// the logs page shows as "System".
        /// </summary>
        public static void LogActivity(string eventType, int? tripId, string details)
        {
            int? actorId = null;
            string actorRole = null;

            try
            {
                /* Only a session carrying both halves is worth recording. GetAccountId answers 0
                   and GetRole answers "" when the session is half built or expired, and storing
                   those would leave rows pointing at a person who does not exist, which reads as
                   an unattributed entry anyway. */
                if (AuthHelper.IsLoggedIn())
                {
                    int id = AuthHelper.GetAccountId();
                    string role = AuthHelper.GetRole();
                    if (id > 0 && !string.IsNullOrEmpty(role))
                    {
                        actorId = id;
                        actorRole = role;
                    }
                }
            }
            catch
            {
                // No session to read, or an expired one. The entry is still worth keeping; it is
                // simply attributed to nobody.
            }

            WriteActivityLog(eventType, tripId, details, actorId, actorRole);
        }

        private static void WriteActivityLog(string eventType, int? tripId, string details,
            int? accountId, string role)
        {
            EnsureActivityLogActors();

            System.Data.SqlClient.SqlParameter tripParam = new System.Data.SqlClient.SqlParameter("@trip", (object)tripId ?? DBNull.Value);
            DBHelper.ExecuteNonQuery(
                @"INSERT INTO ActivityLogs (TripID, EventType, Details, CreatedByAccountId, CreatedByRole)
                  VALUES (@trip, @evt, @det, @who, @role)",
                tripParam,
                new System.Data.SqlClient.SqlParameter("@evt", eventType),
                new System.Data.SqlClient.SqlParameter("@det", (object)details ?? DBNull.Value),
                new System.Data.SqlClient.SqlParameter("@who", (object)accountId ?? DBNull.Value),
                new System.Data.SqlClient.SqlParameter("@role", (object)role ?? DBNull.Value));
        }

        public static decimal HaversineKm(double lat1, double lng1, double lat2, double lng2)
        {
            const double r = 6371.0;
            double dLat = ToRad(lat2 - lat1);
            double dLng = ToRad(lng2 - lng1);
            double a = Math.Sin(dLat / 2) * Math.Sin(dLat / 2)
                     + Math.Cos(ToRad(lat1)) * Math.Cos(ToRad(lat2))
                     * Math.Sin(dLng / 2) * Math.Sin(dLng / 2);
            double c = 2 * Math.Atan2(Math.Sqrt(a), Math.Sqrt(1 - a));
            return (decimal)(r * c);
        }

        private static double ToRad(double deg) { return deg * Math.PI / 180.0; }

        // ---------------------------------------------------------------------
        // Service area (Hpa-An town and its surroundings)
        //
        // This is the single source of truth: Customer/BookTrip.aspx emits these
        // values into its JavaScript so the client-side check and the server-side
        // check can never drift apart.
        //
        // The boundary is a circle around the Hpa-an city centre
        // (16.89056 N, 97.63333 E). It is deliberately the town plus its
        // attractions, NOT Hpa-an Township: the township covers 2,899 km2 and
        // would need a ~30 km radius, which would also swallow Thaton, Hlaingbwe
        // and the northern edge of Myawaddy, making the check meaningless.
        //
        // Measured distances from this centre, which is why the radius is 15 km:
        //   Shweyinhmyaw Pagoda ............  0.5 km
        //   Kan Thar Yar Lake ..............  0.9 km
        //   Bat Cave .......................  5.2 km
        //   Keinnara Hpa-An lodge ..........  7.5 km
        //   Kyauk Ka Lat / Kalap Pagoda ....  8.1 km
        //   Mount Zwegabin (summit) ........  8.3 km
        //   Kaw Goon Cave ..................  9.1 km
        //   Hpa-An Airport .................  9.2 km
        //   Lumbini Buddha Garden .......... 10.1 km   <-- was the last one cut off
        // The previous 10 km radius excluded Lumbini Buddha Garden by about 130 m,
        // which is what made well-known places look "outside the circle".
        // 15 km clears every one of the above with room to spare.
        // ---------------------------------------------------------------------
        public const double ServiceAreaLat = 16.89056;
        public const double ServiceAreaLng = 97.63333;
        public const double ServiceAreaRadiusKm = 15.0;
        public const string ServiceAreaMessage = "Service is not available in this area";

        /// <summary>
        /// True when the coordinate is inside the bookable Hpa-An area.
        /// Rejects NaN/infinity so malformed posted values can never pass.
        /// </summary>
        public static bool IsWithinServiceArea(double lat, double lng)
        {
            if (double.IsNaN(lat) || double.IsNaN(lng)) return false;
            if (double.IsInfinity(lat) || double.IsInfinity(lng)) return false;

            return (double)HaversineKm(ServiceAreaLat, ServiceAreaLng, lat, lng) <= ServiceAreaRadiusKm;
        }

        public const int MinEtaMinutes = 1;
        public const int MaxEtaMinutes = 180;
        public const double AverageCitySpeedKmh = 25.0;
        public const double RoadDistanceFactor = 1.3;

        private static bool? _etaColumnsChecked;
        private static bool? _packagePhotosChecked;
        private static bool? _hotelsChecked;
        private static bool? _logActorChecked;
        // Shared by the schema self-healing helpers (ETA columns, package photos).
        private static readonly object SchemaCheckLock = new object();

        /// <summary>
        /// Adds ActivityLogs.CreatedByAccountId / CreatedByRole so the log can say who caused an
        /// entry. The table originally stored no actor at all, only the event and a free-text
        /// sentence, which meant rows written by an admin, a customer and the trip API were
        /// indistinguishable. Rows that predate the columns keep NULL and read as "System".
        /// <para>
        /// CreatedByRole is stored alongside the id because the three account tables number their
        /// people independently: Admins, Customers and Drivers all start at 1, so the id alone
        /// cannot say which person it points at.
        /// </para>
        /// Idempotent and cached; safe to call on every request.
        /// </summary>
        public static void EnsureActivityLogActors()
        {
            if (_logActorChecked.HasValue) return;
            lock (SchemaCheckLock)
            {
                if (_logActorChecked.HasValue) return;
                try
                {
                    DBHelper.ExecuteNonQuery(
                        @"IF OBJECT_ID('dbo.ActivityLogs','U') IS NOT NULL
                            AND COL_LENGTH('dbo.ActivityLogs','CreatedByAccountId') IS NULL
                              ALTER TABLE dbo.ActivityLogs ADD CreatedByAccountId INT NULL;
                          IF OBJECT_ID('dbo.ActivityLogs','U') IS NOT NULL
                            AND COL_LENGTH('dbo.ActivityLogs','CreatedByRole') IS NULL
                              ALTER TABLE dbo.ActivityLogs ADD CreatedByRole NVARCHAR(20) NULL;");
                    _logActorChecked = true;
                }
                catch
                {
                    // Left unchecked so the next request tries again.
                    _logActorChecked = false;
                }
            }
        }

        /// <summary>
        /// Adds Trips.EtaMinutes / Trips.EtaSetAt when the App_Data upgrade script has not run yet
        /// so ETA queries never hard-fail. Idempotent and cached; safe to call on every request.
        /// </summary>
        public static void EnsureEtaColumns()
        {
            if (_etaColumnsChecked.HasValue) return;
            lock (SchemaCheckLock)
            {
                if (_etaColumnsChecked.HasValue) return;
                try
                {
                    DBHelper.ExecuteNonQuery(
                        @"IF COL_LENGTH('dbo.Trips','EtaMinutes') IS NULL ALTER TABLE dbo.Trips ADD EtaMinutes INT NULL;
                          IF COL_LENGTH('dbo.Trips','EtaSetAt') IS NULL ALTER TABLE dbo.Trips ADD EtaSetAt DATETIME2 NULL;");
                    _etaColumnsChecked = true;
                }
                catch
                {
                    _etaColumnsChecked = false;
                }
            }
        }

        /// <summary>
        /// Approximate road distance for a straight-line leg: the road-network factor converts
        /// the crow-flies value into what a driver actually drives, so both the km shown to the
        /// driver and the drive time come from the same number.
        /// </summary>
        public static decimal RoadDistanceKm(double straightKm)
        {
            double roadKm = straightKm * RoadDistanceFactor;
            return (decimal)Math.Round(roadKm, 1);
        }

        public static decimal? RoadDistanceKm(decimal? straightKm)
        {
            if (!straightKm.HasValue) return null;
            return RoadDistanceKm((double)straightKm.Value);
        }

        /// <summary>
        /// Drive time in whole minutes for a road distance, at the average city speed used for
        /// the ETA suggestion. Same clamps as EstimateArrivalMinutes.
        /// </summary>
        public static int DriveMinutesForRoadKm(double roadKm)
        {
            int minutes = (int)Math.Ceiling(roadKm / AverageCitySpeedKmh * 60.0);
            if (minutes < MinEtaMinutes) minutes = MinEtaMinutes;
            if (minutes > MaxEtaMinutes) minutes = MaxEtaMinutes;
            return minutes;
        }

        /// <summary>
        /// Human drive time, e.g. "24 min" or "1 h 5 min". Matches the browser-side
        /// formatter in RequestDetail.aspx so live GPS updates read the same.
        /// </summary>
        public static string FormatDriveTime(int minutes)
        {
            if (minutes <= 0) return "--";
            if (minutes < 60) return minutes + " min";
            int h = minutes / 60, m = minutes % 60;
            return m == 0 ? h + " h" : h + " h " + m + " min";
        }

        /// <summary>
        /// Suggested drive time in whole minutes from a driver position to the pickup point,
        /// from straight-line distance with a road factor and an average city driving speed.
        /// </summary>
        public static int EstimateArrivalMinutes(double fromLat, double fromLng, double toLat, double toLng)
        {
            return DriveMinutesForRoadKm((double)RoadDistanceKm((double)HaversineKm(fromLat, fromLng, toLat, toLng)));
        }

        public static bool IsValidEtaMinutes(int minutes)
        {
            return minutes >= MinEtaMinutes && minutes <= MaxEtaMinutes;
        }

        /// <summary>
        /// Last GPS position reported by the driver as [lat, lng], or null when none is known.
        /// </summary>
        public static double?[] GetDriverLocation(int driverId)
        {
            object lat = DBHelper.ExecuteScalar(
                "SELECT CurrentLat FROM Drivers WHERE DriverID=@id",
                new System.Data.SqlClient.SqlParameter("@id", driverId));
            object lng = DBHelper.ExecuteScalar(
                "SELECT CurrentLng FROM Drivers WHERE DriverID=@id",
                new System.Data.SqlClient.SqlParameter("@id", driverId));
            if (lat == null || lat == DBNull.Value || lng == null || lng == DBNull.Value) return null;
            return new double?[] { Convert.ToDouble(lat), Convert.ToDouble(lng) };
        }

        /// <summary>
        /// Atomically claims a Requested trip for the driver and stores the arrival estimate
        /// (minutes + the moment the estimate was given, used as the countdown anchor).
        /// Returns false with a reason when the trip was already taken, is no longer
        /// requestable, or the vehicle type does not match the driver's.
        /// </summary>
        public static bool TryAcceptTrip(int driverId, int tripId, int etaMinutes, out string error)
        {
            error = "";
            if (!IsValidEtaMinutes(etaMinutes))
            {
                error = "Arrival time must be between " + MinEtaMinutes + " and " + MaxEtaMinutes + " minutes.";
                return false;
            }

            int vehicleTypeId = GetDriverVehicleTypeId(driverId);
            int rows;
            using (System.Data.SqlClient.SqlConnection conn = DBHelper.GetConnection())
            {
                conn.Open();
                using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(
                    @"UPDATE Trips SET DriverID=@d, Status='Accepted', AcceptedAt=SYSUTCDATETIME(),
                             EtaMinutes=@eta, EtaSetAt=SYSUTCDATETIME()
                      WHERE TripID=@t AND Status='Requested' AND DriverID IS NULL AND VehicleTypeID=@v", conn))
                {
                    cmd.Parameters.AddWithValue("@d", driverId);
                    cmd.Parameters.AddWithValue("@t", tripId);
                    cmd.Parameters.AddWithValue("@v", vehicleTypeId);
                    cmd.Parameters.AddWithValue("@eta", etaMinutes);
                    rows = cmd.ExecuteNonQuery();
                }
            }

            if (rows == 0)
            {
                error = "This job is no longer available — it may have been taken by another driver.";
                return false;
            }

            LogActivity("Accepted", tripId,
                "Driver " + driverId + " accepted the trip with an ETA of " + etaMinutes + " min (first-accept wins).");
            return true;
        }

        /// <summary>
        /// Reads a timestamp column as UTC. SQL Server times here are written with
        /// SYSUTCDATETIME and come back with DateTimeKind.Unspecified, so the kind is
        /// pinned to Utc instead of relying on the machine time zone. (The
        /// Convert.ToDateTime(object, IFormatProvider, DateTimeStyles) overload only
        /// accepts strings, which is why this helper exists.)
        /// </summary>
        public static DateTime AsUtcDateTime(object value)
        {
            if (value == null || value == DBNull.Value) return DateTime.MinValue;
            DateTime dt = value is DateTime
                ? (DateTime)value
                : Convert.ToDateTime(value, CultureInfo.InvariantCulture);
            return DateTime.SpecifyKind(dt, DateTimeKind.Utc);
        }

        /// <summary>
        /// Absolute arrival moment (epoch milliseconds) promised by the driver ETA, or 0 when
        /// no estimate was given. The browser countdown uses this so it never depends on the
        /// client clock zone.
        /// </summary>
        public static long EtaArrivalUnixMs(object etaSetAtUtc, int etaMinutes)
        {
            if (etaSetAtUtc == null || etaSetAtUtc == DBNull.Value || etaMinutes <= 0) return 0;
            DateTime utc = AsUtcDateTime(etaSetAtUtc);
            long seconds = (long)(utc - new DateTime(1970, 1, 1, 0, 0, 0, DateTimeKind.Utc)).TotalSeconds;
            return seconds * 1000L + (long)etaMinutes * 60000L;
        }

        /// <summary>
        /// Live "Arriving in x min" chip for in-progress trips. initEtaCountdowns() in Site.Master
        /// keeps the text ticking and flips it to the done label once the moment passes.
        /// </summary>
        public static string EtaLiveChipHtml(int minutes, object etaSetAtUtc)
        {
            long arrive = EtaArrivalUnixMs(etaSetAtUtc, minutes);
            return "<span class=\"tw-eta inline-flex items-center gap-1 px-2 py-1 rounded-full text-xs font-semibold bg-blue-50 text-blue-600\""
                + " data-eta-arrive=\"" + arrive + "\""
                + " data-eta-done=\"Arriving now\""
                + " data-eta-template=\"Arriving in {0} min\">"
                + "Arriving in " + minutes + " min</span>";
        }

        /// <summary>
        /// Arrival block for the trip summary / status area. Shows the promised clock time next
        /// to the live countdown, so the customer sees both "how long" and "at what time".
        /// The countdown span is the same one Site.Master ticks, which is what turns the line
        /// into "Arriving now" the moment the promised moment passes.
        /// </summary>
        public static string EtaSummaryHtml(int minutes, object etaSetAtUtc, string status)
        {
            if (status == "Arrived" || status == "Started")
                return EtaDoneBlockHtml(status == "Started" ? "On the way" : "Arrived",
                    "The driver has reached your pickup point.");

            if (minutes <= 0 || etaSetAtUtc == null || etaSetAtUtc == DBNull.Value)
                return status == "Requested"
                    ? EtaDoneBlockHtml("Waiting for the driver", "The driver has not given an arrival estimate yet.")
                    : EtaDoneBlockHtml("No arrival estimate", "Ask the driver in the chat for an arrival time.");

            string when = EtaArrivalMyanmarText(etaSetAtUtc, minutes, "h:mm a");
            string sub = string.IsNullOrEmpty(when)
                ? "Promised by the driver: " + minutes + " min."
                : "Expected about <strong>" + HttpUtility.HtmlEncode(when) + "</strong> · promised " + minutes + " min.";

            return "<div class=\"rounded-xl bg-blue-50 border border-blue-100 px-3 py-2.5\">"
                + "<div class=\"flex items-center justify-between gap-2\">"
                + EtaLiveChipHtml(minutes, etaSetAtUtc)
                + (string.IsNullOrEmpty(when) ? "" :
                   "<span class=\"text-xs font-semibold text-blue-700 whitespace-nowrap\">" + HttpUtility.HtmlEncode(when) + "</span>")
                + "</div>"
                + "<div class=\"text-[11px] text-blue-700/80 mt-1\">" + sub + "</div>"
                + "</div>";
        }

        /// <summary>
        /// Arrival chip for a customer's own trip header, whatever state the trip is in:
        /// the live countdown while a driver is still on the way, a green "driver arrived"
        /// pill once they are at the pickup point, and a static promised-time pill after the
        /// trip is settled. A finished trip must not carry a countdown, so it never gets
        /// EtaLiveChipHtml. "" when the driver never gave an estimate.
        /// </summary>
        public static string EtaStatusChipHtml(int minutes, object etaSetAtUtc, string status)
        {
            if (minutes <= 0 || etaSetAtUtc == null || etaSetAtUtc == DBNull.Value) return "";

            if (status == "Arrived" || status == "Started")
            {
                return "<span class=\"inline-flex px-2 py-0.5 rounded-full text-xs font-semibold whitespace-nowrap bg-emerald-50 text-emerald-600\">"
                    + (status == "Started" ? "On the way" : "Driver arrived") + "</span>";
            }

            if (status == "Completed" || status == "Cancelled")
                return EtaHistoryChipHtml(minutes, etaSetAtUtc);

            return EtaLiveChipHtml(minutes, etaSetAtUtc);
        }

        /// <summary>Neutral arrival block for the states where there is no countdown to show.</summary>
        public static string EtaDoneBlockHtml(string title, string sub)
        {
            return "<div class=\"rounded-xl bg-gray-50 border border-gray-200 px-3 py-2.5\">"
                + "<div class=\"text-sm font-semibold text-gray-700\">" + HttpUtility.HtmlEncode(title) + "</div>"
                + "<div class=\"text-[11px] text-gray-500 mt-0.5\">" + HttpUtility.HtmlEncode(sub) + "</div>"
                + "</div>";
        }

        /// <summary>
        /// The driver-side twin of EtaSummaryHtml, for pages where the reader is the driver:
        /// same promise, but the wording is about what they told the customer rather than
        /// what the customer is waiting for. Shared by the driver's active and history pages.
        /// </summary>
        public static string DriverEtaSummaryHtml(DataRow r)
        {
            string status = r["Status"].ToString();
            if (status == "Arrived" || status == "Started")
                return EtaDoneBlockHtml(
                    status == "Started" ? "On the way" : "Arrived",
                    status == "Started" ? "The ride is in progress." : "You reached the pickup point.");

            if (r["EtaMinutes"] == DBNull.Value || Convert.ToInt32(r["EtaMinutes"]) <= 0)
                return EtaDoneBlockHtml("No promise yet",
                    "You have not given the customer an arrival estimate.");

            int minutes = Convert.ToInt32(r["EtaMinutes"]);
            string when = EtaArrivalMyanmarText(r["EtaSetAt"], minutes, "h:mm a");
            long arrive = EtaArrivalUnixMs(r["EtaSetAt"], minutes);

            // The "behind" line is left for Site.Master to fill in, so it counts up live
            // instead of freezing at whatever the driver saw when the page rendered.
            string late = arrive <= 0 ? "" :
                "<div class=\"hidden text-[11px] text-amber-700 font-semibold mt-1\""
                + " data-eta-late-arrive=\"" + arrive + "\""
                + " data-eta-late-template=\"Running {0} min behind the promise.\"></div>";

            return "<div class=\"rounded-xl bg-blue-50 border border-blue-100 px-3 py-2.5\">"
                + "<div class=\"flex items-center justify-between gap-2\">"
                + EtaLiveChipHtml(minutes, r["EtaSetAt"])
                + (string.IsNullOrEmpty(when) ? "" :
                   "<span class=\"text-xs font-semibold text-blue-700 whitespace-nowrap\">"
                   + HttpUtility.HtmlEncode(when) + "</span>")
                + "</div>"
                + "<div class=\"text-[11px] text-blue-700/80 mt-1\">You promised the customer "
                + minutes + " min.</div>" + late + "</div>";
        }

        /// <summary>
        /// Promised arrival clock time in Myanmar Standard Time ("dd MMM yyyy, HH:mm"),
        /// i.e. the moment the ETA was given plus the promised minutes. "" when unknown.
        /// </summary>
        public static string EtaArrivalMyanmarText(object etaSetAtUtc, int minutes, string format)
        {
            if (etaSetAtUtc == null || etaSetAtUtc == DBNull.Value || minutes <= 0) return "";
            return FormatMyanmarTime(Convert.ToDateTime(etaSetAtUtc).AddMinutes(minutes), format);
        }

        /// <summary>
        /// Static arrival chip for finished trips: the promised minutes plus the clock time the
        /// driver gave the estimate.
        /// </summary>
        public static string EtaHistoryChipHtml(int minutes, object etaSetAtUtc)
        {
            if (minutes <= 0) return "";
            string when = FormatMyanmarTime(etaSetAtUtc, "dd MMM, HH:mm");
            return "<span class=\"inline-flex px-2 py-0.5 rounded-full text-xs font-semibold whitespace-nowrap bg-gray-100 text-gray-600\">"
                + minutes + " min ETA" + (string.IsNullOrEmpty(when) ? "" : " · " + when) + "</span>";
        }

        /// <summary>
        /// Settled twin of DriverEtaSummaryHtml for a finished trip: what the driver promised,
        /// when the customer was actually reached, and whether the promise held. Deliberately
        /// static, because a closed trip must not carry the countdown Site.Master keeps ticking.
        /// </summary>
        public static string DriverEtaHistoryBlockHtml(DataRow r)
        {
            if (r["EtaMinutes"] == DBNull.Value || Convert.ToInt32(r["EtaMinutes"]) <= 0)
                return EtaDoneBlockHtml("No promise yet", "You did not give the customer an arrival estimate.");

            int minutes = Convert.ToInt32(r["EtaMinutes"]);
            object setAt = r["EtaSetAt"];
            string expected = EtaArrivalMyanmarText(setAt, minutes, "dd MMM, HH:mm");
            string given = FormatMyanmarTime(setAt, "dd MMM, HH:mm");

            string verdict;
            if (r["ArrivedAt"] == DBNull.Value || setAt == DBNull.Value)
            {
                verdict = "Pickup arrival was not recorded.";
            }
            else
            {
                int drift = (int)Math.Round(
                    (Convert.ToDateTime(r["ArrivedAt"]) - Convert.ToDateTime(setAt).AddMinutes(minutes)).TotalMinutes);
                verdict = drift <= 2
                    ? "You reached the pickup point on time."
                    : "You reached the pickup point " + drift + " min after the promise.";
            }

            return "<div class=\"rounded-xl bg-gray-50 border border-gray-200 px-3 py-2.5\">"
                + "<div class=\"flex items-center justify-between gap-2\">"
                + "<span class=\"text-sm font-semibold text-gray-700\">" + minutes + " min promised</span>"
                + (string.IsNullOrEmpty(expected) ? "" :
                   "<span class=\"text-xs font-semibold text-gray-600 whitespace-nowrap\">"
                   + HttpUtility.HtmlEncode(expected) + "</span>")
                + "</div>"
                + "<div class=\"text-[11px] text-gray-500 mt-0.5\">" + HttpUtility.HtmlEncode(verdict) + "</div>"
                + (string.IsNullOrEmpty(given) ? "" :
                   "<div class=\"text-[11px] text-gray-400 mt-0.5\">Estimate given at "
                   + HttpUtility.HtmlEncode(given) + "</div>")
                + "</div>";
        }

        /// <summary>
        /// Arrival block for the admin view of a trip: what was promised, when the driver was
        /// due, and when they actually turned up. Third person and static, because an admin is
        /// reading the record rather than waiting on it.
        /// </summary>
        public static string EtaFactBlockHtml(DataRow r)
        {
            if (r["EtaMinutes"] == DBNull.Value || Convert.ToInt32(r["EtaMinutes"]) <= 0)
                return EtaDoneBlockHtml("No arrival estimate", "No estimate was given for this trip.");

            int minutes = Convert.ToInt32(r["EtaMinutes"]);
            object setAt = r["EtaSetAt"];
            string expected = EtaArrivalMyanmarText(setAt, minutes, "dd MMM, HH:mm");
            string given = FormatMyanmarTime(setAt, "dd MMM, HH:mm");

            string actual;
            if (r["ArrivedAt"] == DBNull.Value || setAt == DBNull.Value)
            {
                actual = "Pickup arrival was not recorded.";
            }
            else
            {
                int drift = (int)Math.Round(
                    (Convert.ToDateTime(r["ArrivedAt"]) - Convert.ToDateTime(setAt).AddMinutes(minutes)).TotalMinutes);
                string clock = FormatMyanmarTime(r["ArrivedAt"], "dd MMM, HH:mm");
                string gap = drift <= -2 ? Math.Abs(drift) + " min early"
                          : drift >= 2 ? drift + " min late"
                          : "on time";
                actual = "Reached the pickup point at " + clock + " · " + gap + ".";
            }

            return "<div class=\"rounded-xl bg-gray-50 border border-gray-200 px-3 py-2.5\">"
                + "<div class=\"flex items-center justify-between gap-2\">"
                + "<span class=\"text-sm font-semibold text-gray-700\">" + minutes + " min promised</span>"
                + (string.IsNullOrEmpty(expected) ? "" :
                   "<span class=\"text-xs font-semibold text-gray-600 whitespace-nowrap\">"
                   + HttpUtility.HtmlEncode(expected) + "</span>")
                + "</div>"
                + "<div class=\"text-[11px] text-gray-500 mt-0.5\">" + HttpUtility.HtmlEncode(actual) + "</div>"
                + (string.IsNullOrEmpty(given) ? "" :
                   "<div class=\"text-[11px] text-gray-400 mt-0.5\">Estimate given at "
                   + HttpUtility.HtmlEncode(given) + "</div>")
                + "</div>";
        }

        /// <summary>
        /// Point-to-Point fare. There is no base fare and no minimum: the trip costs the
        /// per-km rate for the distance covered and nothing else.
        ///
        ///     fare = PerKmRate x road distance
        ///
        /// The 1.3 factor converts the straight line between two points into road distance,
        /// which is what the per-km rate is actually priced against. The caller passes the
        /// straight line distance, so the same figure has to be charged on the server and
        /// quoted on the page.
        /// </summary>
        public static decimal EstimateP2P(decimal perKm, decimal km)
        {
            return perKm * km * 1.3m;
        }

        /// <summary>
        /// Hourly fare. One flat rate for every hour, so there is no first-hour minimum and
        /// no higher rate for the hours after it.
        ///
        ///     fare = HourlyRate x hours
        ///
        /// Hours below one are treated as one, because a booking is never shorter than the
        /// smallest hour block the page sells.
        /// </summary>
        public static decimal EstimateHourly(decimal perHour, int hours)
        {
            if (hours < 1) hours = 1;
            return perHour * hours;
        }

        public static decimal RoundFare(decimal value)
        {
            return Math.Round((value / 100) * 100, 0, MidpointRounding.AwayFromZero);
        }

        public static string GetServiceName(int serviceTypeId)
        {
            object o = DBHelper.ExecuteScalar("SELECT Name FROM ServiceTypes WHERE ServiceTypeID=@id",
                new System.Data.SqlClient.SqlParameter("@id", serviceTypeId));
            return o == null ? "" : o.ToString();
        }

        public static string GetVehicleName(int vehicleTypeId)
        {
            object o = DBHelper.ExecuteScalar("SELECT Name FROM VehicleTypes WHERE VehicleTypeID=@id",
                new System.Data.SqlClient.SqlParameter("@id", vehicleTypeId));
            return o == null ? "" : o.ToString();
        }

        public static string FormatKm(decimal? km)
        {
            return (km ?? 0m) > 0 ? km.Value.ToString("0.0") + " km" : "--";
        }

        /// <summary>
        /// Reads a latitude or longitude typed by an admin. The map writes plain dot
        /// notation, so that is tried first, and the current culture second for a locale
        /// that uses a decimal comma. Returns false for anything unparsable or outside
        /// the valid range, so a stop is reported as needing attention instead of being
        /// written as a wrong coordinate or throwing out of the SQL call.
        /// Pass maxAbsolute as 90 for a latitude and 180 for a longitude.
        /// </summary>
        public static bool TryReadCoordinate(string text, out decimal value, decimal maxAbsolute = 180m)
        {
            value = 0m;
            string trimmed = (text ?? "").Trim();
            if (trimmed.Length == 0) return false;

            if (!decimal.TryParse(trimmed, NumberStyles.Float, System.Globalization.CultureInfo.InvariantCulture, out value)
                && !decimal.TryParse(trimmed, NumberStyles.Float, System.Globalization.CultureInfo.CurrentCulture, out value))
                return false;

            return value >= -maxAbsolute && value <= maxAbsolute;
        }

        public static string FormatMoney(decimal amount)
        {
            return amount.ToString("#,##0") + " Ks";
        }

        public static string GetCustomerName(int customerId)
        {
            object o = DBHelper.ExecuteScalar("SELECT FullName FROM Customers WHERE CustomerID=@id",
                new System.Data.SqlClient.SqlParameter("@id", customerId));
            return o == null ? "" : o.ToString();
        }

        public static string GetDriverName(int driverId)
        {
            object o = DBHelper.ExecuteScalar("SELECT FullName FROM Drivers WHERE DriverID=@id",
                new System.Data.SqlClient.SqlParameter("@id", driverId));
            return o == null ? "" : o.ToString();
        }

        public static string StatusPill(string status)
        {
            string css;
            switch (status)
            {
                case "Approved":
                case "Active":
                case "Completed":
                case "Paid":
                case "Accepted":
                    css = "bg-emerald-50 text-emerald-700";
                    break;
                case "Pending":
                case "Requested":
                case "Unpaid":
                    css = "bg-blue-50 text-blue-700";
                    break;
                case "Rejected":
                case "Cancelled":
                case "Failed":
                case "Suspended":
                    css = "bg-red-50 text-red-700";
                    break;
                case "Arrived":
                case "Started":
                    css = "bg-amber-50 text-amber-700";
                    break;
                default:
                    css = "bg-gray-100 text-gray-600";
                    break;
            }
            return "<span class=\"inline-flex px-2.5 py-1 rounded-full text-xs font-semibold whitespace-nowrap " + css + "\">"
                + HttpUtility.HtmlEncode(status) + "</span>";
        }

        /// <summary>
        /// JobConnect-style "View" lightbox body for a trip (used by list pages + dashboards).
        /// </summary>
        public static string BuildTripModalHtml(int tripId, string detailUrl)
        {
            DataTable t = DBHelper.ExecuteQuery(
                @"SELECT t.TripID, t.Status, t.PaymentStatus, t.Fare AS EstimatedFare, t.EstimatedKm AS DistanceKm,
                    t.PickupAddress, t.DropoffAddress, t.PickupLat, t.PickupLng, t.DropoffLat, t.DropoffLng,
                    t.RequestedAt, t.AcceptedAt, t.CompletedAt,
                    t.ServiceTypeID, t.VehicleTypeID, t.CustomerID, t.DriverID,
                    c.FullName AS CustomerName, c.PhoneNumber AS CustomerPhone
                  FROM Trips t
                  INNER JOIN Customers c ON t.CustomerID = c.CustomerID
                  WHERE t.TripID = @id",
                new System.Data.SqlClient.SqlParameter("@id", tripId));
            if (t.Rows.Count == 0)
                return "<div class=\"text-sm text-gray-500\">Trip not found.</div>";

            DataRow r = t.Rows[0];

            int stops = 0;
            if (TripStopsExists())
            {
                try
                {
                    stops = Convert.ToInt32(DBHelper.ExecuteScalar(
                        "SELECT COUNT(*) FROM TripStops WHERE TripID=@id",
                        new System.Data.SqlClient.SqlParameter("@id", tripId)));
                }
                catch { stops = 0; }
            }

            string when = r["RequestedAt"] == DBNull.Value
                ? ""
                : FormatMyanmarTime(r["RequestedAt"], "dd MMM yyyy, hh:mm tt");
            decimal fare = r["EstimatedFare"] == DBNull.Value ? 0m : Convert.ToDecimal(r["EstimatedFare"]);
            string driver = r["DriverID"] == DBNull.Value ? "--" : GetDriverName(Convert.ToInt32(r["DriverID"]));

            var sb = new StringBuilder();
            sb.Append("<div class=\"flex items-start justify-between gap-4 mb-5\">")
              .Append("<div><h3 class=\"text-lg font-bold text-gray-900\">Trip Details</h3>")
              .Append("<p class=\"text-sm text-gray-400 mt-0.5\">").Append(HttpUtility.HtmlEncode(when)).Append("</p></div>")
              .Append(StatusPill(r["Status"].ToString()))
              .Append("</div>");

            sb.Append("<div class=\"tw-detail-grid mb-5\">")
              .Append("<div><div class=\"tw-detail-label\">Service</div><div class=\"tw-detail-value\">")
                .Append(HttpUtility.HtmlEncode(GetServiceName(Convert.ToInt32(r["ServiceTypeID"])))).Append("</div></div>")
              .Append("<div><div class=\"tw-detail-label\">Vehicle</div><div class=\"tw-detail-value\">")
                .Append(HttpUtility.HtmlEncode(GetVehicleName(Convert.ToInt32(r["VehicleTypeID"])))).Append("</div></div>")
              .Append("<div><div class=\"tw-detail-label\">Distance</div><div class=\"tw-detail-value\">")
                .Append(FormatKm(r["DistanceKm"] == DBNull.Value ? (decimal?)null : Convert.ToDecimal(r["DistanceKm"]))).Append("</div></div>")
              .Append("<div><div class=\"tw-detail-label\">Fare</div><div class=\"tw-detail-value font-bold text-gray-900\">")
                .Append(FormatMoney(fare)).Append("</div></div>")
              .Append("<div><div class=\"tw-detail-label\">Payment</div><div>").Append(StatusPill(r["PaymentStatus"].ToString())).Append("</div></div>")
              .Append("<div><div class=\"tw-detail-label\">Stops</div><div class=\"tw-detail-value\">")
                .Append(stops.ToString()).Append(" stop").Append(stops == 1 ? "" : "s").Append("</div></div>")
              .Append("</div>");

            sb.Append("<div class=\"border-t border-gray-100 pt-5 mb-5\">")
              .Append("<div class=\"tw-detail-label mb-3\">Route</div>")
              .Append(RouteListHtml(tripId, r))
              .Append("</div>");

            sb.Append("<div class=\"border-t border-gray-100 pt-5 tw-detail-grid mb-5\">")
              .Append("<div><div class=\"tw-detail-label\">Customer</div>")
              .Append("<div class=\"tw-detail-value\">").Append(HttpUtility.HtmlEncode(r["CustomerName"].ToString())).Append("</div>")
              .Append("<div class=\"text-xs text-gray-400\">").Append(HttpUtility.HtmlEncode(r["CustomerPhone"].ToString())).Append("</div></div>")
              .Append("<div><div class=\"tw-detail-label\">Driver</div>")
              .Append("<div class=\"tw-detail-value\">").Append(HttpUtility.HtmlEncode(driver)).Append("</div></div>")
              .Append("</div>");

            sb.Append("<div class=\"border-t border-gray-100 pt-5 flex gap-2\">")
              .Append("<a href=\"")
              .Append(HttpUtility.HtmlEncode(detailUrl ?? ""))
              .Append("\" class=\"tw-btn-primary\">")
              .Append("<svg xmlns=\"http://www.w3.org/2000/svg\" fill=\"none\" viewBox=\"0 0 24 24\" stroke-width=\"1.5\" stroke=\"currentColor\" class=\"size-4\"><path stroke-linecap=\"round\" stroke-linejoin=\"round\" d=\"M8.25 6.75h12M8.25 12h12m-12 5.25h12M3.75 6.75h.007v.008H3.75V6.75Zm.375 0a.375.375 0 1 1-.75 0 .375.375 0 0 1 .75 0ZM3.75 12h.007v.008H3.75V12Zm.375 0a.375.375 0 1 1-.75 0 .375.375 0 0 1 .75 0Zm-.375 5.25h.007v.008H3.75v-.008Zm.375 0a.375.375 0 1 1-.75 0 .375.375 0 0 1 .75 0Z\"/></svg>")
                .Append("View Full Details</a>")
              .Append("</div>");

            return sb.ToString();
        }

        /// <summary>
        /// Rating lightbox body: 1-5 star picker plus an optional comment. The stars and the
        /// submit button post back to the hosting page (trip id / score / comment are read from
        /// Request.Form), so it works inside the shared lightbox without nested forms.
        /// </summary>
        public static string BuildRatingModalHtml(int tripId, string driverName)
        {
            const string StarPath = "M11.48 3.499a.562.562 0 0 1 1.04 0l2.125 5.111a.563.563 0 0 0 .475.345l5.518.442c.499.04.701.663.321.988l-4.204 3.602a.563.563 0 0 0-.182.557l1.285 5.385a.562.562 0 0 1-.84.61l-4.725-2.885a.562.562 0 0 0-.586 0L6.982 20.54a.562.562 0 0 1-.84-.61l1.285-5.386a.562.562 0 0 0-.182-.557l-4.204-3.602a.563.563 0 0 1 .321-.988l5.518-.442a.563.563 0 0 0 .475-.345L11.48 3.5Z";

            var sb = new StringBuilder();
            sb.Append("<div class=\"mb-4\">")
              .Append("<h3 class=\"text-lg font-bold text-gray-900\">Rate Your Trip</h3>")
              .Append("<p class=\"text-sm text-gray-400 mt-0.5\">");
            if (!string.IsNullOrEmpty(driverName))
                sb.Append("Trip with ").Append(HttpUtility.HtmlEncode(driverName));
            sb.Append("</p></div>");

            sb.Append("<input type=\"hidden\" name=\"twrtTrip\" value=\"").Append(tripId).Append("\" />")
              .Append("<input type=\"hidden\" name=\"twrtScore\" id=\"twRateScore\" value=\"\" />");

            sb.Append("<div id=\"twRateStars\" class=\"flex items-center gap-1 mb-4\">");
            for (int i = 1; i <= 5; i++)
            {
                sb.Append("<button type=\"button\" data-score=\"").Append(i)
                  .Append("\" onclick=\"twRatePick(").Append(i).Append("); return false;\"")
                  .Append(" aria-label=\"").Append(i).Append(" star").Append(i == 1 ? "" : "s").Append("\"")
                  .Append(" class=\"text-gray-300 hover:text-amber-400 transition-colors\">")
                  .Append("<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 24 24\" fill=\"currentColor\" class=\"size-9 inline-block align-middle\"><path d=\"")
                  .Append(StarPath).Append("\"/></svg></button>");
            }
            sb.Append("</div>");

            sb.Append("<textarea name=\"twrtComment\" rows=\"3\" maxlength=\"500\" class=\"tw-input tw-textarea mb-4 w-full\"")
              .Append(" placeholder=\"Leave a comment (optional)\"></textarea>");

            sb.Append("<button type=\"submit\" class=\"tw-btn-primary w-full justify-center\">Submit Rating</button>");

            return sb.ToString();
        }

        /// <summary>
        /// JobConnect-style "View" lightbox body for a driver.
        /// </summary>
        public static string BuildDriverModalHtml(int id, string detailUrl)
        {
            DataTable t = DBHelper.ExecuteQuery(
                @"SELECT d.DriverID, d.FullName, d.PhoneNumber, d.Email, d.KYCStatus, d.IsOnline,
                         d.VehiclePlateNumber, v.Name AS VehicleTypeName,
                         (SELECT COUNT(*) FROM Trips t WHERE t.DriverID = d.DriverID) AS TripCount,
                         (SELECT ISNULL(AVG(r.Score),0) FROM Ratings r
                          INNER JOIN Trips t ON r.TripID = t.TripID WHERE t.DriverID = d.DriverID) AS RatingValue,
                         (SELECT ISNULL(SUM(t.Fare),0) FROM Trips t
                          WHERE t.DriverID = d.DriverID AND t.Status = 'Completed') AS TotalEarned
                  FROM Drivers d
                  INNER JOIN VehicleTypes v ON d.VehicleTypeID = v.VehicleTypeID
                  WHERE d.DriverID=@id",
                new System.Data.SqlClient.SqlParameter("@id", id));
            if (t.Rows.Count == 0)
                return "<div class=\"text-sm text-gray-500\">Driver not found.</div>";

            DataRow r = t.Rows[0];
            bool online = Convert.ToBoolean(r["IsOnline"]);
            string name = r["FullName"].ToString();
            string initial = string.IsNullOrEmpty(name) ? "?" : name.Trim().Substring(0, 1).ToUpperInvariant();

            var sb = new StringBuilder();
            sb.Append("<div class=\"flex items-start justify-between gap-4 mb-5\">")
              .Append("<div class=\"flex items-center gap-3\"><span class=\"tw-avatar tw-avatar-amber\">")
              .Append(HttpUtility.HtmlEncode(initial))
              .Append("</span><div><h3 class=\"text-lg font-bold text-gray-900\">")
              .Append(HttpUtility.HtmlEncode(name)).Append("</h3>")
              .Append("<p class=\"text-sm text-gray-400 mt-0.5\">Driver #").Append(id).Append("</p></div></div>")
              .Append(StatusPill(r["KYCStatus"].ToString()))
              .Append("</div>");

            sb.Append("<div class=\"tw-detail-grid mb-5\">")
              .Append("<div><div class=\"tw-detail-label\">Email</div><div class=\"tw-detail-value\">").Append(HttpUtility.HtmlEncode(r["Email"].ToString())).Append("</div></div>")
              .Append("<div><div class=\"tw-detail-label\">Phone</div><div class=\"tw-detail-value\">").Append(HttpUtility.HtmlEncode(r["PhoneNumber"].ToString())).Append("</div></div>")
              .Append("<div><div class=\"tw-detail-label\">Vehicle</div><div class=\"tw-detail-value\">").Append(HttpUtility.HtmlEncode(r["VehicleTypeName"].ToString())).Append("</div></div>")
              .Append("<div><div class=\"tw-detail-label\">Plate</div><div class=\"tw-detail-value\">").Append(string.IsNullOrEmpty(r["VehiclePlateNumber"].ToString()) ? "-" : HttpUtility.HtmlEncode(r["VehiclePlateNumber"].ToString())).Append("</div></div>")
              .Append("<div><div class=\"tw-detail-label\">Trips</div><div class=\"tw-detail-value\">").Append(r["TripCount"].ToString()).Append("</div></div>")
              .Append("<div><div class=\"tw-detail-label\">Rating</div><div class=\"tw-detail-value\">").Append(r["RatingValue"] == null || string.IsNullOrEmpty(r["RatingValue"].ToString()) ? "-" : string.Format("{0:0.0}", Convert.ToDecimal(r["RatingValue"]))).Append("</div></div>")
              .Append("<div><div class=\"tw-detail-label\">Total Earned</div><div class=\"tw-detail-value font-bold text-gray-900\">MMK ").Append(string.Format("{0:N0}", Convert.ToDecimal(r["TotalEarned"]))).Append("</div></div>")
              .Append("<div><div class=\"tw-detail-label\">Online</div><div><span class=\"inline-flex px-2.5 py-1 rounded-full text-xs font-semibold whitespace-nowrap ").Append(online ? "bg-emerald-50 text-emerald-700" : "bg-gray-100 text-gray-500").Append("\">").Append(online ? "Online" : "Offline").Append("</span></div></div>")
              .Append("</div>");

            sb.Append("<div class=\"border-t border-gray-100 pt-5 flex gap-2\">")
              .Append("<a href=\"")
              .Append(HttpUtility.HtmlEncode(detailUrl ?? ""))
              .Append("\" class=\"tw-btn-primary\">")
              .Append("<svg xmlns=\"http://www.w3.org/2000/svg\" fill=\"none\" viewBox=\"0 0 24 24\" stroke-width=\"1.5\" stroke=\"currentColor\" class=\"size-4\"><path stroke-linecap=\"round\" stroke-linejoin=\"round\" d=\"M19 7.5v3m0 0v3m0-3h3m-3 0h-3m-2.25-4.125a3.375 3.375 0 1 1-6.75 0 3.375 3.375 0 0 1 6.75 0ZM4 19.235v-.11a6.375 6.375 0 0 1 12.75 0v.109A12.318 12.318 0 0 1 10.374 21c-2.331 0-4.512-.645-6.374-1.766Z\"/></svg>")
              .Append("Full Profile</a>")
              .Append("</div>");
            return sb.ToString();
        }

        /// <summary>
        /// Renders a single inline SVG star (heroicons solid path). Filled stars use
        /// currentColor so the surrounding text color styles them; empty stars are
        /// outlined gray by default.
        /// </summary>
        public static string StarSvg(bool filled, string sizeClass = "size-3.5", string colorClass = null)
        {
            string fill = filled
                ? "fill=\"currentColor\""
                : "fill=\"none\" stroke=\"currentColor\" stroke-width=\"1.5\"";
            string color = colorClass ?? (filled ? "text-amber-400" : "text-gray-300");
            return "<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 24 24\" "
                + fill + " class=\"" + sizeClass + " inline-block align-middle " + color + "\">"
                + "<path d=\"M11.48 3.499a.562.562 0 0 1 1.04 0l2.125 5.111a.563.563 0 0 0 .475.345l5.518.442c.499.04.701.663.321.988l-4.204 3.602a.563.563 0 0 0-.182.557l1.285 5.385a.562.562 0 0 1-.84.61l-4.725-2.885a.562.562 0 0 0-.586 0L6.982 20.54a.562.562 0 0 1-.84-.61l1.285-5.386a.562.562 0 0 0-.182-.557l-4.204-3.602a.562.562 0 0 1 .321-.988l5.518-.442a.563.563 0 0 0 .475-.345L11.48 3.5Z\"/></svg>";
        }

        /// <summary>
        /// Renders five SVG stars for a 1-5 rating: "score" filled amber stars followed
        /// by outlined gray stars.
        /// </summary>
        public static string StarsHtml(int score, string sizeClass = "size-5")
        {
            if (score < 0) score = 0;
            if (score > 5) score = 5;
            var sb = new StringBuilder();
            for (int i = 0; i < 5; i++)
                sb.Append(StarSvg(i < score, sizeClass));
            return sb.ToString();
        }

        /// <summary>
        /// Role-based landing page (~/ root-relative) shown in public CTA buttons
        /// once the user is logged in, replacing Register/Login prompts.
        /// </summary>
        public static string DashboardUrl()
        {
            switch (AuthHelper.GetRole())
            {
                case "Admin":
                    return "~/Admin/Dashboard.aspx";
                case "Driver":
                    return "~/Driver/Dashboard.aspx";
                case "Customer":
                    return "~/Customer/Dashboard.aspx";
                default:
                    return "~/Default.aspx";
            }
        }
    }
}