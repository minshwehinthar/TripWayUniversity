using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Text;

namespace TripWay.Customer
{
    public partial class BookTripPage : Helper.ListPageBase
    {
        private int CustomerId { get { return Helper.AuthHelper.GetAccountId(); } }

        private const string ActiveStates = "'Requested','Accepted','Arrived','Started'";

        public string FareJson { get; private set; } = "{}";
        public string VehicleJson { get; private set; } = "{}";
        public string PackageJson { get; private set; } = "{}";
        public string ServiceTypeJson { get; private set; } = "1";
        public string HotelJson { get; private set; } = "{}";

        /// <summary>
        /// The result of the last attempt to confirm the booking: "success" or "error", the
        /// text, and where to go on a success.
        ///
        /// A failure is the only thing this page raises as a toast. Choosing a service, a
        /// vehicle, hours, passengers or a hotel all report back on the page itself (the card
        /// that lit up, the pin on the map, the inline note, the summary), because those are
        /// choices rather than outcomes and a toast that vanishes is a poor record of them.
        /// A success is not a toast at all: it navigates to the trip it just created.
        /// </summary>
        public string ConfirmToastKind { get; private set; }
        public string ConfirmToastText { get; private set; }
        public string ConfirmRedirect { get; private set; }

        /// <summary>
        /// The same three values as a JavaScript literal, or null when there is nothing to say.
        /// JavaScriptStringEncode is used rather than HtmlEncode because the value is dropped
        /// inside a script block, where an apostrophe in a message would otherwise end the
        /// string it sits in.
        /// </summary>
        public string ConfirmToastJson
        {
            get
            {
                if (string.IsNullOrEmpty(ConfirmToastKind) || string.IsNullOrEmpty(ConfirmToastText)) return "null";
                return "{\"kind\":" + System.Web.HttpUtility.JavaScriptStringEncode(ConfirmToastKind)
                     + ",\"text\":" + System.Web.HttpUtility.JavaScriptStringEncode(ConfirmToastText)
                     + ",\"go\":" + System.Web.HttpUtility.JavaScriptStringEncode(ConfirmRedirect ?? "")
                     + "}";
            }
        }

        // Hotel attached to the trip being created, resolved once from the posted
        // hidden field and re-validated against the database. InsertTrip() reads
        // this instead of the raw field so the value it stores has been checked.
        private int? _hotelId;

        /// <summary>
        /// The two rates of the vehicle currently chosen in ddlVehicle, as plain nullable
        /// decimals, so the page can print a real price in its markup.
        ///
        /// The prices on this page used to exist only in JavaScript: the server wrote the words
        /// "From MMK 0/hr" on the hourly card and left the hour grid completely empty, and the
        /// script filled both in once it ran. That made the page's prices depend on the script
        /// arriving and running, and if anything stopped it early the customer was shown a hard
        /// coded zero and no hour prices at all. Printing the rate here means the number is right
        /// in the first byte of HTML, and the script only has to keep it up to date when the
        /// vehicle or the service changes.
        ///
        /// Null means "this vehicle has no rate set for that service", which is deliberately not
        /// the same as zero: a zero would be quoted as though it were a price.
        /// </summary>
        public decimal? SelectedPerKm { get; private set; }
        public decimal? SelectedPerHour { get; private set; }

        /// <summary>
        /// The hour blocks on sale, as markup the browser can show before the script runs. Kept in
        /// step with the ddlHours ListItems and with HourlyHourBlocks, which is what is charged.
        /// </summary>
        public string ServerHourCardsHtml
        {
            get
            {
                if (!SelectedPerHour.HasValue)
                    return "<div class=\"text-[11px] text-slate-500\">Rate unavailable</div>";

                var sb = new StringBuilder();
                foreach (int h in HourlyHourBlocks)
                {
                    decimal total = Helper.TripHelper.RoundFare(Helper.TripHelper.EstimateHourly(SelectedPerHour.Value, h));
                    sb.Append("<div class=\"hour-card text-left rounded-xl p-3.5 border border-slate-100 bg-white\">")
                      .Append("<div class=\"flex items-center justify-between gap-2 mb-1.5\">")
                      .Append("<span class=\"text-[13px] font-semibold text-slate-900\">").Append(h)
                      .Append(h == 1 ? " hour" : " hours").Append("</span></div>")
                      .Append("<div class=\"text-[11px] text-slate-500\">")
                      .Append(h >= 8 ? "Full day cover" : "Standby driver").Append("</div>")
                      .Append("<div class=\"mt-2.5 pt-2.5 border-t border-slate-100 text-[11px] font-semibold text-slate-500\">")
                      .Append("MMK ").Append(total.ToString("N0", System.Globalization.CultureInfo.InvariantCulture))
                      .Append("</div></div>");
                }
                return sb.ToString();
            }
        }

        /// <summary>
        /// A rate for the markup, or a dash when the vehicle has none for that service.
        /// </summary>
        public string FormatSelectedRate(decimal? rate, string suffix)
        {
            if (!rate.HasValue) return "Rate unavailable";
            return "MMK " + rate.Value.ToString("N0", System.Globalization.CultureInfo.InvariantCulture) + suffix;
        }

        private void LoadSelectedVehicleRates()
        {
            SelectedPerKm = null;
            SelectedPerHour = null;

            int vehicleTypeId;
            if (!int.TryParse(ddlVehicle.SelectedValue, out vehicleTypeId)) return;

            DataTable dt = Helper.DBHelper.ExecuteQuery(
                string.Format(CurrentRatesByVehicleSql, "AND f.VehicleTypeID = @v"),
                new SqlParameter("@v", vehicleTypeId));
            if (dt.Rows.Count == 0) return;

            object pk = dt.Rows[0]["PerKmRate"];
            object ph = dt.Rows[0]["HourlyRate"];
            if (pk != null && pk != DBNull.Value && Convert.ToDecimal(pk) > 0m) SelectedPerKm = Convert.ToDecimal(pk);
            if (ph != null && ph != DBNull.Value && Convert.ToDecimal(ph) > 0m) SelectedPerHour = Convert.ToDecimal(ph);
        }

        /// <summary>
        /// The two rates that are currently set for every vehicle, one row per vehicle.
        ///
        /// A vehicle has a single rate row holding both figures, so this is a plain read with no
        /// ranking and no aggregate.
        ///
        /// It used to be MAX(PerKmRate) and MAX(HourlyRate) over a vehicle's rows, back when a
        /// vehicle had one row per service. That answered "the largest rate anyone has ever
        /// entered for this vehicle" rather than "the rate that is currently set", so a motorbike
        /// whose hourly rate had been changed to 200 while an older 3,000 row was still there was
        /// quoted and charged 3,000. One row per vehicle removes the choice, and a unique index
        /// on VehicleTypeID stops a second row being created.
        ///
        /// {0} is an optional extra filter, e.g. "AND f.VehicleTypeID = @v".
        /// </summary>
        private const string CurrentRatesByVehicleSql = @"
            SELECT f.VehicleTypeID, f.PerKmRate, f.HourlyRate
            FROM dbo.FareRates f
            WHERE 1 = 1 {0}";

        /// <summary>
        /// The rate row for one vehicle, which is the row the page quoted: both the printed price
        /// and the charge come from the same single row, so they cannot disagree.
        /// </summary>
        private const string CurrentRateForVehicleSql = @"
            SELECT f.PerKmRate, f.HourlyRate
            FROM dbo.FareRates f
            WHERE f.VehicleTypeID = @v";

        protected void Page_Load(object sender, EventArgs e)
        {
            Helper.AuthHelper.RequireCustomer(this);

            // Both guards run on every request, not just the initial GET: the postback branch
            // below re-reads Hotels and Packages, and both helpers are idempotent, so a missing
            // column is added before any query on this page can reference it.
            Helper.TripHelper.EnsureHotels();
            Helper.TripHelper.EnsurePackageActive();

            // One trip at a time. The Confirm button is dead while one of this customer's is in
            // flight and the panel above it says why, because a button that is disabled with no
            // explanation reads as a broken page. Checked on every request, not just the GET,
            // so the state is right after a postback too.
            //
            // The authoritative check stays in btnCreateTrip_Click: this one runs before the
            // postback that creates the trip, so it cannot be what stands between two bookings.
            bool tripInFlight = HasActiveTrip();
            btnCreateTrip.Enabled = !tripInFlight;
            pnlActiveTrip.Visible = tripInFlight;
            if (tripInFlight)
            {
                // .tw-btn-primary:hover is unconditional, so a disabled button would still
                // darken under the cursor and read as live.
                btnCreateTrip.CssClass = "tw-btn-primary w-full justify-center rounded-xl !opacity-60 !cursor-not-allowed";
            }

            if (!IsPostBack)
            {
                // Read once, because both the service type and the package selection need it.
                int linkedPackage = RequestedPackageId();

                /* A package link is a request for that package, so open on the package service
                   rather than making the customer press "Package Tour" as well. Set before
                   UpdatePanels, which decides whether the package panel is visible at all. */
                if (linkedPackage > 0 && ddlServiceType.Items.FindByValue("3") != null)
                    ddlServiceType.SelectedValue = "3";

                UpdatePanels();
                BindVehicleDropdown();
                BindPackageDropdown(linkedPackage);
                BindHotelCards();
                var serviceLabel = ddlServiceType.SelectedItem.Text;
                lblServiceLabel.Text = serviceLabel;
            }
            else
            {
                // The cards themselves are not re-rendered on a postback, but the data their
                // click handler looks the hotel up in is: the page re-emits its whole script
                // block every request, and an empty HOTELS there is why a hotel card could
                // report "that hotel could not be loaded" after changing service or vehicle.
                BuildHotelJson(Helper.TripHelper.GetActiveHotels());
            }
            LoadSelectedVehicleRates();
            BuildJsData();
            ServiceTypeJson = ddlServiceType.SelectedValue;
        }

        protected void ddlServiceType_SelectedIndexChanged(object sender, EventArgs e)
        {
            UpdatePanels();
            lblServiceLabel.Text = ddlServiceType.SelectedItem.Text;
        }

        private void UpdatePanels()
        {
            // The map stays visible for every service type: package bookings use it for the
            // pickup point and the numbered delivery itinerary.
            pnlMap.Visible = true;
            pnlHourly.Visible = ddlServiceType.SelectedValue == "2";
            pnlPackage.Visible = ddlServiceType.SelectedValue == "3";
        }

        private void BindVehicleDropdown()
        {
            DataTable dt = Helper.DBHelper.ExecuteQuery(
                "SELECT VehicleTypeID, Name, MinSeatCapacity, MaxSeatCapacity FROM VehicleTypes ORDER BY VehicleTypeID");
            ddlVehicle.DataSource = dt;
            ddlVehicle.DataTextField = "Name";
            ddlVehicle.DataValueField = "VehicleTypeID";
            ddlVehicle.DataBind();
        }

        /// <summary>
        /// Package id from the query string, or 0 when there is not a usable one. Not trusted
        /// on its own: BindPackageDropdown only accepts it if it is in the active package list
        /// it just loaded, so a hand-edited url cannot book an inactive or missing package.
        /// </summary>
        private int RequestedPackageId()
        {
            int id;
            return int.TryParse(Request.QueryString["package"], out id) && id > 0 ? id : 0;
        }

        private void BindPackageDropdown(int preferredPackageId)
        {
            DataTable dt = Helper.DBHelper.ExecuteQuery(
                "SELECT PackageID, Name + ' — MMK ' + FORMAT(FixedPrice, 'N0') AS Label, FixedPrice FROM Packages WHERE IsActive = 1 ORDER BY PackageID");
            ddlPackage.Items.Clear();
            ddlPackage.Items.Add(new System.Web.UI.WebControls.ListItem("-- Select a package --", "0"));
            foreach (DataRow r in dt.Rows)
            {
                ddlPackage.Items.Add(new System.Web.UI.WebControls.ListItem(r["Label"].ToString(), r["PackageID"].ToString()));
            }

            // The package cards are the picker now, so the page should never open with an empty
            // itinerary: the first real package is pre-selected and the customer changes it with
            // a card click. The "-- Select a package --" row stays as the unbookable fallback.
            // The linked package wins when it is in this list; otherwise fall through to the
            // original behaviour and preselect the first real package.
            if (preferredPackageId > 0 && ddlPackage.Items.FindByValue(preferredPackageId.ToString()) != null)
            {
                ddlPackage.SelectedValue = preferredPackageId.ToString();
                return;
            }

            if (ddlPackage.Items.Count > 1)
                ddlPackage.SelectedValue = ddlPackage.Items[1].Value;
        }

        protected void ddlPackage_SelectedIndexChanged(object sender, EventArgs e)
        {
            // Places rendering is handled client-side from PackageJson.
        }

        /// <summary>
        /// The payment method now arrives in a hidden field, so it is untrusted input. Anything
        /// not in the whitelist the cards offer falls back to Cash.
        /// </summary>
        private static readonly string[] AllowedPaymentMethods = { "Cash", "KPay", "WavePay" };

        private static string ValidatedPaymentMethod(string posted)
        {
            string value = (posted ?? "").Trim();
            foreach (string allowed in AllowedPaymentMethods)
            {
                if (string.Equals(value, allowed, StringComparison.OrdinalIgnoreCase)) return allowed;
            }
            return "Cash";
        }

        /// <summary>
        /// Hotel cards on the booking page. Only active hotels are offered, and the same rows
        /// feed the HOTELS lookup the "route to this hotel" button uses.
        ///
        /// The cards are rendered once, on the first load. The JSON behind them is built on
        /// every request, because the page re-renders its whole script block on a postback and
        /// an empty HOTELS there leaves every hotel card unable to find itself.
        /// </summary>
        private void BindHotelCards()
        {
            DataTable dt = Helper.TripHelper.GetActiveHotels();
            rptHotels.DataSource = dt;
            rptHotels.DataBind();
            pnlHotels.Visible = dt.Rows.Count > 0;
            BuildHotelJson(dt);
        }

        /// <summary>The hotel data the page script looks up, rebuilt on every request.</summary>
        private void BuildHotelJson(DataTable dt)
        {
            var hotels = new StringBuilder();
            hotels.Append("{");
            bool first = true;
            foreach (DataRow r in dt.Rows)
            {
                if (!first) hotels.Append(",");
                first = false;
                // The stored address, logo and contacts travel with the hotel so the map can
                // show the full card without another lookup, and the pin is labelled even when
                // the reverse geocoder is slow or unavailable. ok is 0 when the hotel has no
                // usable coordinates, which the page must not treat as a map position.
                double hotelLat, hotelLng;
                bool located = UsableCoordinates(r["Lat"], r["Lng"], out hotelLat, out hotelLng);
                hotels.Append(r["HotelID"]).Append(":{name:\"").Append(JsonEsc(r["Name"].ToString()))
                       .Append("\",addr:\"").Append(JsonEsc(Flat(r["Address"])))
                       .Append("\",phone:\"").Append(JsonEsc(Flat(r["Phone"])))
                       .Append("\",email:\"").Append(JsonEsc(Flat(r["Email"])))
                       .Append("\",logo:\"").Append(JsonEsc(HotelPhotoUrlResolved(r["LogoPhotoUrl"])))
                       .Append("\",ok:").Append(located ? "1" : "0")
                       .Append(",lat:").Append(located ? Num(hotelLat) : "null")
                       .Append(",lng:").Append(located ? Num(hotelLng) : "null").Append("}");
            }
            hotels.Append("}");
            HotelJson = hotels.ToString();
        }

        /// <summary>
        /// One-line address for the hotel map pin: line breaks would break the pin label and
        /// the JSON string.
        /// </summary>
        private static string Flat(object value)
        {
            if (value == null || value == DBNull.Value) return "";
            return value.ToString().Replace("\r", " ").Replace("\n", " ").Trim();
        }

        /// <summary>
        /// A hotel is only mappable when both coordinates are readable and are not the null
        /// island a missing value used to become. The booking server refuses such a hotel in
        /// GetBookableHotel, so the page says so instead of dropping a pin in the ocean.
        /// </summary>
        private static bool UsableCoordinates(object lat, object lng, out double latOut, out double lngOut)
        {
            latOut = 0; lngOut = 0;
            if (lat == null || lng == null || lat == DBNull.Value || lng == DBNull.Value) return false;

            try
            {
                latOut = Convert.ToDouble(lat, System.Globalization.CultureInfo.InvariantCulture);
                lngOut = Convert.ToDouble(lng, System.Globalization.CultureInfo.InvariantCulture);
            }
            catch (Exception)
            {
                return false;
            }

            if (double.IsNaN(latOut) || double.IsNaN(lngOut)) return false;
            if (latOut == 0 && lngOut == 0) return false;
            return true;
        }

        /// <summary>
        /// "1" when the hotel is inside the bookable area, "0" when it is outside, and "none"
        /// when it has no coordinates at all. This is the same helper the booking server
        /// re-checks with, so a hotel edited after the page was rendered is caught here first.
        /// </summary>
        protected string HotelInArea(object lat, object lng)
        {
            double la, ln;
            if (!UsableCoordinates(lat, lng, out la, out ln)) return "none";
            return Helper.TripHelper.IsWithinServiceArea(la, ln) ? "1" : "0";
        }

        /// <summary>
        /// Text for a hotel card line. An empty value renders as nothing at all, because a card
        /// that says "-" for a hotel with no phone number looks broken.
        /// </summary>
        protected string HotelText(object value)
        {
            string text = value == null || value == DBNull.Value ? "" : value.ToString().Trim();
            return text.Length == 0 ? "" : System.Web.HttpUtility.HtmlEncode(text);
        }

        /// <summary>
        /// The whole photo tag for a hotel card, or nothing when the hotel has no uploaded logo.
        /// The card markup carries the neutral placeholder underneath, so a missing or broken
        /// upload shows that instead of an empty gap. An absolute link is used as it is, a
        /// stored path is made relative to this application.
        /// </summary>
        protected string HotelPhotoTag(object storedPath)
        {
            string url = HotelPhotoUrlResolved(storedPath);
            if (url.Length == 0) return "";
            return "<img src=\"" + System.Web.HttpUtility.HtmlEncode(url) + "\" alt=\"\" loading=\"lazy\""
                + " class=\"absolute inset-0 size-full object-cover\" onerror=\"this.style.display='none'\" />";
        }

        /// <summary>
        /// The whole address line of a hotel card, or nothing when the hotel has no address.
        /// A template can only hold expressions, not an if block, so the decision lives here.
        /// </summary>
        protected string HotelAddressTag(object value)
        {
            string text = HotelText(value);
            if (text.Length == 0) return "";
            return "<div class=\"mt-1 text-[11px] leading-snug text-slate-500 line-clamp-2\">" + text + "</div>";
        }

        /// <summary>
        /// The whole phone line of a hotel card, or nothing when there is no phone number.
        /// </summary>
        protected string HotelPhoneTag(object value)
        {
            string text = HotelText(value);
            if (text.Length == 0) return "";
            return "<div class=\"mt-1.5 flex items-center gap-1.5 text-[11px] text-slate-400\">"
                + "<svg xmlns=\"http://www.w3.org/2000/svg\" fill=\"none\" viewBox=\"0 0 24 24\" stroke-width=\"1.8\""
                + " stroke=\"currentColor\" class=\"size-3 shrink-0\"><path stroke-linecap=\"round\" stroke-linejoin=\"round\""
                + " d=\"M2.25 6.75c0 8.284 6.716 15 15 15h2.25a2.25 2.25 0 0 0 2.25-2.25v-1.372c0-.516-.351-.966-.852-1.091l-4.423-1.106"
                + "c-.44-.11-.902.055-1.173.417l-.97 1.293c-.282.376-.769.542-1.21.38a12.035 12.035 0 0 1-7.143-7.143"
                + "c-.162-.441.004-.928.38-1.21l1.293-.97c.363-.271.527-.734.417-1.173L6.963 3.102a1.125 1.125 0 0 0-1.091-.852H4.5"
                + "A2.25 2.25 0 0 0 2.25 4.5v2.25Z\"/></svg>"
                + "<span class=\"truncate\">" + text + "</span></div>";
        }

        /// <summary>
        /// The warning chip for a hotel that was saved without a usable map position. Such a
        /// hotel cannot be booked as a destination, so the card says so up front.
        /// </summary>
        protected string HotelMapTag(object lat, object lng)
        {
            if (HotelInArea(lat, lng) != "none") return "";
            return "<div class=\"mt-2 inline-flex items-center gap-1 px-1.5 py-0.5 rounded-md bg-amber-50"
                + " text-amber-700 text-[10px] font-semibold\">No map position yet</div>";
        }

        /// <summary>
        /// Stored photo path turned into something an img src can use. Empty when there is no
        /// photo, an absolute link is left alone, anything else is made relative to this app.
        /// </summary>
        private string HotelPhotoUrlResolved(object storedPath)
        {
            string path = Helper.TripHelper.HotelPhotoUrl(storedPath);
            if (path.Length == 0) return "";
            if (path.StartsWith("http://") || path.StartsWith("https://")) return path;
            return ResolveUrl("~/" + path);
        }

        private void BuildJsData()
        {
            var rates = new StringBuilder();
            rates.Append("{");
            bool first = true;
            // Only the two rates that are actually charged are emitted: perKm for point-to-point
            // and perHour for hourly. There is no base fare to quote, so the vehicle cards, the
            // estimate and the breakdown all read these same two numbers. Only the rate that is
            // currently set is emitted: the query keeps the most recently updated row for each
            // vehicle and service, so an older superseded row can no longer put a higher figure
            // on the page than the one in force.
            foreach (DataRow r in Helper.DBHelper.ExecuteQuery(
                string.Format(CurrentRatesByVehicleSql, "") + " ORDER BY f.VehicleTypeID").Rows)
            {
                if (!first) rates.Append(",");
                first = false;
                rates.Append(r["VehicleTypeID"]).Append(":{perKm:").Append(NumOrNull(r["PerKmRate"]))
                     .Append(",perHour:").Append(NumOrNull(r["HourlyRate"]))
                     .Append("}");
            }
            rates.Append("}");
            FareJson = rates.ToString();

            var veh = new StringBuilder();
            veh.Append("{");
            first = true;
            foreach (DataRow r in Helper.DBHelper.ExecuteQuery(
                "SELECT VehicleTypeID, Name, MinSeatCapacity, MaxSeatCapacity FROM VehicleTypes").Rows)
            {
                if (!first) veh.Append(",");
                first = false;
                veh.Append(r["VehicleTypeID"]).Append(":{name:\"").Append(JsonEsc(r["Name"].ToString()))
                    .Append("\",min:").Append(r["MinSeatCapacity"])
                    .Append(",max:").Append(r["MaxSeatCapacity"]).Append("}");
            }
            veh.Append("}");
            VehicleJson = veh.ToString();

            

            var packs = new StringBuilder();
            packs.Append("{");
            first = true;
            foreach (DataRow r in Helper.DBHelper.ExecuteQuery(@"
                SELECT p.PackageID, p.Name AS PackageName, p.FixedPrice, p.CoverPhotoUrl,
                       (SELECT pp.PlaceName + N'~' + CONVERT(NVARCHAR(24), pp.Lat) + N'~' + CONVERT(NVARCHAR(24), pp.Lng) + N'~'
                          FROM PackagePlaces pp WHERE pp.PackageID = p.PackageID
                          ORDER BY pp.OrderIndex, pp.PackagePlaceID FOR XML PATH('')) AS Places
                FROM Packages p WHERE p.IsActive = 1 ORDER BY p.PackageID").Rows)
            {
                if (!first) packs.Append(",");
                first = false;
                string places = r["Places"] == DBNull.Value ? "" : r["Places"].ToString();
                string[] parts = places.Split(new[] { '~' }, StringSplitOptions.RemoveEmptyEntries);
                var names = new StringBuilder();
                var stops = new StringBuilder();
                bool firstName = true, firstStop = true;
                for (int i = 0; i + 2 < parts.Length; i += 3)
                {
                    string placeName = parts[i].Trim();
                    if (placeName.Length == 0) continue;
                    if (!firstName) names.Append(",");
                    firstName = false;
                    names.Append("\"").Append(JsonEsc(placeName)).Append("\"");

                    double lat, lng;
                    if (double.TryParse(parts[i + 1], System.Globalization.NumberStyles.Any, System.Globalization.CultureInfo.InvariantCulture, out lat)
                        && double.TryParse(parts[i + 2], System.Globalization.NumberStyles.Any, System.Globalization.CultureInfo.InvariantCulture, out lng)
                        && lat != 0 && lng != 0)
                    {
                        if (!firstStop) stops.Append(",");
                        firstStop = false;
                        stops.Append("{name:\"").Append(JsonEsc(placeName))
                             .Append("\",lat:").Append(lat.ToString(System.Globalization.CultureInfo.InvariantCulture))
                             .Append(",lng:").Append(lng.ToString(System.Globalization.CultureInfo.InvariantCulture))
                             .Append("}");
                    }
                }
                // name travels with the package so the left-hand package cards can label
                // themselves; places[] keeps every place name in order, stops[] only the
                // ones that carry usable coordinates (they are matched by name, not index).
                // cover is the real uploaded image, so the itinerary cards can show the tour the
                // customer is actually booking instead of a stock image. photos is kept in the
                // shape the script reads (see photoFor in BookTrip.aspx), but this project uses
                // the cover photo only, so it is always empty.
                int packageId = Convert.ToInt32(r["PackageID"]);
                packs.Append(packageId).Append(":{name:\"").Append(JsonEsc(r["PackageName"].ToString()))
                     .Append("\",fare:").Append(NumOrNull(r["FixedPrice"]))
                     .Append(",cover:\"").Append(JsonEsc(PhotoUrl(r["CoverPhotoUrl"]))).Append("\"")
                     .Append(",photos:[],places:[").Append(names).Append("],stops:[").Append(stops).Append("]}");
            }
            packs.Append("}");
            PackageJson = packs.ToString();
        }

        /// <summary>
        /// Page-relative URL for a stored package image, or "" when there is none. External
        /// links are passed through untouched so an admin can paste an image from anywhere.
        /// </summary>
        private string PhotoUrl(object storedPath)
        {
            string path = Helper.TripHelper.PackagePhotoUrl(storedPath);
            if (path.Length == 0) return "";
            if (path.StartsWith("http://") || path.StartsWith("https://")) return path;
            return ResolveUrl("~/" + path);
        }

        private string JsonEsc(string value)
        {
            if (value == null) return "";
            return value.Replace("\\", "\\\\").Replace("\"", "\\\"").Replace("\r", " ").Replace("\n", " ").Replace("\t", " ");
        }

        // Null-safe, culture-invariant number for JS literals (DBNull/decimals).
        private static string Num(object value)
        {
            if (value == null || value == DBNull.Value) return "0";
            return Convert.ToDecimal(value).ToString(System.Globalization.CultureInfo.InvariantCulture);
        }

        /// <summary>
        /// A rate for the JavaScript, where "no rate set" has to stay distinguishable from
        /// "a rate of zero".
        ///
        /// Num() cannot be used for these, because it writes a missing rate as the number 0.
        /// The page tests a rate with "rate.perHour != null" to decide whether to show a price
        /// or say the rate is unavailable, and a 0 sails straight through that test. A vehicle
        /// with no hourly rate set was therefore quoted "MMK 0/hr" on the service card while
        /// the hour cards said "Rate unavailable" for the same vehicle, which read as a broken
        /// price rather than a missing one. JSON null is what the test is looking for.
        /// </summary>
        private static string NumOrNull(object value)
        {
            if (value == null || value == DBNull.Value) return "null";
            return Convert.ToDecimal(value).ToString(System.Globalization.CultureInfo.InvariantCulture);
        }

        // Set as soon as InsertTrip returns a real id, so the catch below can tell a booking
        // that failed outright from one that is in the database and only tripped over
        // something that came afterwards.
        private int _bookedTripId;

        /// <summary>
        /// Books the trip, or refuses it with a message, then leaves for the trip if it worked.
        ///
        /// A booking that succeeded ends this response with a 302 to ActiveTrip.aspx. That is
        /// deliberately done here, by the server, rather than by handing the page a URL and
        /// letting the script follow it: the redirect was previously client-side, which meant a
        /// successful booking only reached the trip page if every script on the page parsed,
        /// evaluated and ran to completion. A syntax error in any inline block, a missing
        /// library, or a throw at the top level of any of them left the customer sitting on the
        /// form they had just successfully booked from, with a trip in the database and no
        /// indication of it. A refusal still renders this page, because that message has
        /// nowhere else to live.
        ///
        /// This also covers the partial failure in the catch below, where the trip reached the
        /// database and only something after it failed: the customer is sent to the trip that
        /// exists rather than told it failed, because otherwise they would book the same ride
        /// again and be refused by HasActiveTrip.
        /// </summary>
        protected void btnCreateTrip_Click(object sender, EventArgs e)
        {
            try
            {
                BookTripOrRefuse();
            }
            catch (Exception ex)
            {
                // The message is kept out of the toast: it is whatever the driver underneath
                // happened to say, which is not something to hand a customer.
                Helper.TripHelper.LogActivity("BookFailed", 0,
                    "Customer " + CustomerId + " could not be booked: " + ex.Message);

                if (_bookedTripId > 0)
                {
                    ConfirmToastKind = "success";
                    ConfirmRedirect = "ActiveTrip.aspx?trip=" + _bookedTripId;
                }
                else
                {
                    ShowMessage("We could not send your request just now. Please try again.", true);
                }
            }

            // Outside the try on purpose: Response.Redirect ends the response by throwing
            // ThreadAbortException, and the catch above would otherwise swallow the redirect and
            // show the customer a success toast on this page instead of sending them to the trip.
            if (ConfirmToastKind == "success" && !string.IsNullOrEmpty(ConfirmRedirect))
            {
                Response.Redirect(ResolveUrl(ConfirmRedirect), true);
            }
        }

        private void BookTripOrRefuse()
        {
            if (HasActiveTrip())
            {
                ShowMessage("You already have an active trip. Finish it before booking a new one.", true);
                return;
            }

            int serviceType;
            if (!int.TryParse(ddlServiceType.SelectedValue, out serviceType)) return;
            int vehicleType = int.Parse(ddlVehicle.SelectedValue);

            double pickupLat, pickupLng;
            bool okPickupLat = double.TryParse(hfPickupLat.Value, out pickupLat);
            bool okPickupLng = double.TryParse(hfPickupLng.Value, out pickupLng);
            bool hasPickup = okPickupLat && okPickupLng;

            // The map blocks out-of-area points in JavaScript, but the hidden fields
            // are ordinary form input and can be posted by hand. Re-check here so
            // the rule is actually enforced, not just suggested.
            if (hasPickup && !Helper.TripHelper.IsWithinServiceArea(pickupLat, pickupLng))
            {
                ShowMessage(Helper.TripHelper.ServiceAreaMessage, true);
                return;
            }

            // Destination coordinates are needed both by point-to-point and by the
            // hotel check below, so they are parsed once here rather than per case.
            // The two TryParse calls are deliberately separate statements: joining them
            // with && would short-circuit, and dropLng would then be only conditionally
            // assigned as far as the compiler is concerned.
            double dropLat, dropLng;
            bool okDropLat = double.TryParse(hfDropLat.Value, out dropLat);
            bool okDropLng = double.TryParse(hfDropLng.Value, out dropLng);
            bool hasDrop = okDropLat && okDropLng;

            // A posted hotel is only honoured when it is genuinely bookable and the
            // destination really is that hotel. hfHotelId is ordinary form input, so
            // without this a hand-crafted post could label any trip with a hotel name,
            // or reference a hotel that was deactivated or deleted after page load.
            _hotelId = null;
            int postedHotel;
            if (int.TryParse(hfHotelId.Value, out postedHotel) && postedHotel > 0)
            {
                if (serviceType != 1)
                {
                    ShowMessage("A hotel can only be used as a point-to-point destination.", true);
                    return;
                }
                if (!hasDrop)
                {
                    ShowMessage("Please set both pickup and destination on the map.", true);
                    return;
                }

                DataRow hotel = Helper.TripHelper.GetBookableHotel(postedHotel);
                if (hotel == null)
                {
                    ShowMessage("That hotel is no longer available. Please choose another one.", true);
                    return;
                }

                double hotelLat = Convert.ToDouble(hotel["Lat"]);
                double hotelLng = Convert.ToDouble(hotel["Lng"]);

                // A hotel can also be moved or re-pointed out of the bookable area
                // after the page was rendered, so re-apply the boundary here.
                if (!Helper.TripHelper.IsWithinServiceArea(hotelLat, hotelLng))
                {
                    ShowMessage(Helper.TripHelper.ServiceAreaMessage, true);
                    return;
                }

                // The destination must be the hotel itself. Otherwise the trip would
                // be shown to the driver as "to <hotel>" while actually going
                // somewhere else, and the fare would be for the wrong journey.
                if (Math.Abs(hotelLat - dropLat) > 0.000001 || Math.Abs(hotelLng - dropLng) > 0.000001)
                {
                    ShowMessage("The destination does not match the selected hotel. Please select the hotel again.", true);
                    return;
                }

                _hotelId = postedHotel;
            }

            int tripId = 0;
            switch (serviceType)
            {
                case 1: // Point-to-Point
                    if (!hasPickup || !hasDrop)
                    {
                        ShowMessage("Please set both pickup and destination on the map.", true);
                        return;
                    }
                    if (!Helper.TripHelper.IsWithinServiceArea(dropLat, dropLng))
                    {
                        ShowMessage(Helper.TripHelper.ServiceAreaMessage, true);
                        return;
                    }
                    // Checked before InsertTrip so a bad waypoint cannot leave a
                    // half-written trip behind.
                    if (!StopsWithinServiceArea())
                    {
                        ShowMessage(Helper.TripHelper.ServiceAreaMessage, true);
                        return;
                    }
                    decimal km = ComputeRouteKm(pickupLat, pickupLng, dropLat, dropLng);
                    DataRow rate = GetRate(vehicleType, serviceType);
                    if (rate == null)
                    {
                        ShowMessage("No per-km rate is set for this vehicle, so it cannot be booked on distance. Please choose another vehicle or contact us.", true);
                        return;
                    }
                    decimal fare = Helper.TripHelper.RoundFare(
                        Helper.TripHelper.EstimateP2P(Convert.ToDecimal(rate["PerKmRate"]), km));
                    if (RefuseIfOverCapacity(vehicleType)) return;
                    tripId = InsertTrip(vehicleType, serviceType, null, pickupLat, pickupLng, hfPickupAddr.Value, dropLat, dropLng, hfDropAddr.Value, km, 0, fare);
                    if (tripId > 0) InsertStops(tripId, pickupLat, pickupLng, hfPickupAddr.Value, dropLat, dropLng, hfDropAddr.Value);
                    break;

                case 2: // Hourly
                    int hours;
                    // Only the published hour blocks may be booked. Checking the list (rather
                    // than just ">= 1") means a hand-edited or stale posted value cannot be
                    // charged at the extra-hour rate for a block we do not sell.
                    if (!int.TryParse(ddlHours.SelectedValue, out hours) || !HourlyBlockIsSold(hours))
                    {
                        ShowMessage("Please choose a valid number of hours.", true);
                        return;
                    }
                    if (!hasPickup)
                    {
                        ShowMessage("Please set the pickup location on the map.", true);
                        return;
                    }
                    DataRow rateH = GetRate(vehicleType, serviceType);
                    if (rateH == null)
                    {
                        ShowMessage("No hourly rate is set for this vehicle, so it cannot be booked on time. Please choose another vehicle or contact us.", true);
                        return;
                    }
                    decimal fareH = HourlyFare(rateH, hours);
                    if (RefuseIfOverCapacity(vehicleType)) return;
                    tripId = InsertTrip(vehicleType, serviceType, null, pickupLat, pickupLng, hfPickupAddr.Value, null, null, null, null, hours, fareH);
                    break;

                case 3: // Package
                    int packageId;
                    if (!int.TryParse(ddlPackage.SelectedValue, out packageId) || packageId == 0)
                    {
                        ShowMessage("Please choose a package.", true);
                        return;
                    }
                    if (RefuseIfOverCapacity(vehicleType)) return;
                    // A tour is a single set price on the package itself, not a rate per km or
                    // per hour, so it is read from the package and used as it stands.
                    // IsActive is re-checked here rather than trusted from the dropdown: the
                    // package id is posted back, so a hidden package could otherwise be
                    // quoted and booked by hand-editing the form.
                    object packagePrice = Helper.DBHelper.ExecuteScalar(
                        "SELECT FixedPrice FROM Packages WHERE PackageID=@p AND IsActive=1",
                        new SqlParameter("@p", packageId));
                    if (packagePrice == null)
                    {
                        ShowMessage("Package not found.", true);
                        return;
                    }
                    // The package itinerary IS the route: the customer's own pickup when they
                    // set one, otherwise the first place, and the last place is the destination.
                    // Persisting the places as TripStops is what puts every one of them on the
                    // trip map of the customer, the driver and the admin.
                    var packagePlaces = PackagePlaces(packageId);
                    if (packagePlaces.Count == 0)
                    {
                        ShowMessage("That package has no places set up yet. Please choose another package.", true);
                        return;
                    }

                    string pickupAddress = (hfPickupAddr.Value ?? "").Trim();
                    if (!hasPickup)
                    {
                        pickupLat = packagePlaces[0].Lat;
                        pickupLng = packagePlaces[0].Lng;
                        pickupAddress = packagePlaces[0].Name;
                    }
                    if (pickupAddress.Length == 0) pickupAddress = "Pickup at hotel / home";

                    var lastPlace = packagePlaces[packagePlaces.Count - 1];
                    tripId = InsertTrip(vehicleType, serviceType, packageId, pickupLat, pickupLng, pickupAddress,
                        lastPlace.Lat, lastPlace.Lng, lastPlace.Name, PackageRouteKm(pickupLat, pickupLng, packagePlaces),
                        null, Helper.TripHelper.RoundFare(Convert.ToDecimal(packagePrice)));
                    if (tripId > 0) InsertPackageStops(tripId, packagePlaces);
                    break;
            }

            _bookedTripId = tripId;

            Helper.TripHelper.LogActivity("Requested", tripId,
                "Customer " + CustomerId + " requested service '" + ddlServiceType.SelectedItem.Text
                + "' on " + ddlVehicle.SelectedItem.Text + " (" + Helper.TripHelper.FormatMoney(GetFare(tripId)) + ")");

            // On success the customer is sent straight to the trip they just asked for. The
            // redirect is done by the client rather than here because a server-side
            // Response.Redirect would land them with nothing on screen: the trip page opens on
            // this request already, so it carries the confirmation and the trip together. Only
            // a failure is raised as a toast on this page.
            ConfirmToastKind = "success";
            ConfirmToastText = "Driver request sent. We are looking for a "
                + ddlVehicle.SelectedItem.Text + " for you now.";
            ConfirmRedirect = "ActiveTrip.aspx?trip=" + tripId;
        }

        private decimal GetFare(int tripId)
        {
            object o = Helper.DBHelper.ExecuteScalar("SELECT Fare FROM Trips WHERE TripID=@t", new SqlParameter("@t", tripId));
            return Convert.ToDecimal(o);
        }

        private int InsertTrip(int vehicleType, int serviceType, int? packageId,
            double pickupLat, double pickupLng, string pickupAddr,
            double? dropLat, double? dropLng, string dropAddr,
            decimal? km, int? hours, decimal fare)
        {
            // Payment method is chosen once here at booking time; the customer is never
            // asked again on ActiveTrip.aspx.
            string paymentMethod = ValidatedPaymentMethod(hfPayment.Value);

            // Set when the customer routed the trip to a hotel, so the driver and the trip
            // detail pages can name the hotel instead of only showing coordinates.
            // _hotelId was re-validated against the database in btnCreateTrip_Click;
            // the raw hidden field is deliberately not trusted here.
            int? hotelId = _hotelId;

            return Helper.DBHelper.ExecuteNonQueryWithIdentity(
                @"INSERT INTO Trips (CustomerID, VehicleTypeID, ServiceTypeID, PackageID, HotelID, PickupLat, PickupLng, PickupAddress,
                                      DropoffLat, DropoffLng, DropoffAddress, EstimatedKm, Hours, Fare, Status, PaymentMethod, PaymentStatus)
                  VALUES (@c, @v, @s, @p, @h, @plat, @plng, @paddr, @dlat, @dlng, @daddr, @km, @hrs, @fare, 'Requested', @pm, 'Unpaid')",
                new SqlParameter("@pm", paymentMethod),
                new SqlParameter("@c", CustomerId),
                new SqlParameter("@v", vehicleType),
                new SqlParameter("@s", serviceType),
                new SqlParameter("@p", (object)packageId ?? DBNull.Value),
                new SqlParameter("@h", (object)hotelId ?? DBNull.Value),
                new SqlParameter("@plat", pickupLat),
                new SqlParameter("@plng", pickupLng),
                new SqlParameter("@paddr", (object)pickupAddr ?? DBNull.Value),
                new SqlParameter("@dlat", (object)dropLat ?? DBNull.Value),
                new SqlParameter("@dlng", (object)dropLng ?? DBNull.Value),
                new SqlParameter("@daddr", (object)dropAddr ?? DBNull.Value),
                new SqlParameter("@km", (object)km ?? DBNull.Value),
                new SqlParameter("@hrs", (object)hours ?? DBNull.Value),
                new SqlParameter("@fare", fare));
        }

        // Total distance across pickup -> stops... -> drop (haversine per segment),
        // so multi-stop routes are priced over the full path.
        private decimal ComputeRouteKm(double pickupLat, double pickupLng, double dropLat, double dropLng)
        {
            var pts = new List<Tuple<double, double>> { Tuple.Create(pickupLat, pickupLng) };
            List<object[]> stops = ParseStops();
            foreach (object[] s in stops)
            {
                if (s.Length >= 2) pts.Add(Tuple.Create(Convert.ToDouble(s[0]), Convert.ToDouble(s[1])));
            }
            pts.Add(Tuple.Create(dropLat, dropLng));

            decimal total = 0m;
            for (int i = 1; i < pts.Count; i++)
            {
                total += Helper.TripHelper.HaversineKm(
                    pts[i - 1].Item1, pts[i - 1].Item2, pts[i].Item1, pts[i].Item2);
            }
            return total;
        }

        private List<object[]> ParseStops()
        {
            if (string.IsNullOrEmpty(hfStops.Value)) return new List<object[]>();
            try
            {
                var ser = new System.Web.Script.Serialization.JavaScriptSerializer();
                return ser.Deserialize<List<object[]>>(hfStops.Value) ?? new List<object[]>();
            }
            catch
            {
                return new List<object[]>();
            }
        }

        private static bool TryParseStop(object value, out double result)
        {
            return double.TryParse(
                Convert.ToString(value),
                System.Globalization.NumberStyles.Float,
                System.Globalization.CultureInfo.InvariantCulture,
                out result);
        }

        /// <summary>
        /// Every posted waypoint must be a real number inside the service area.
        /// Called before the trip row is created so an out-of-area stop cannot
        /// leave a half-written trip behind.
        /// </summary>
        private bool StopsWithinServiceArea()
        {
            foreach (object[] s in ParseStops())
            {
                if (s == null || s.Length < 2) continue;

                double sLat, sLng;
                if (!TryParseStop(s[0], out sLat)) return false;
                if (!TryParseStop(s[1], out sLng)) return false;
                if (!Helper.TripHelper.IsWithinServiceArea(sLat, sLng)) return false;
            }
            return true;
        }

        /// <summary>
        /// One place of a package itinerary. The list is ordered by OrderIndex, which is the
        /// order the places are delivered in and the order they are numbered on the trip map.
        /// </summary>
        private class PackagePlace
        {
            public double Lat;
            public double Lng;
            public string Name;
        }

        /// <summary>
        /// The package itinerary, read fresh at booking time so the stops saved on the trip are
        /// the places the package actually has right now.
        /// </summary>
        private static List<PackagePlace> PackagePlaces(int packageId)
        {
            var list = new List<PackagePlace>();
            DataTable dt = Helper.DBHelper.ExecuteQuery(
                "SELECT PlaceName, Lat, Lng FROM PackagePlaces WHERE PackageID=@p ORDER BY OrderIndex, PackagePlaceID",
                new SqlParameter("@p", packageId));
            foreach (DataRow r in dt.Rows)
            {
                list.Add(new PackagePlace
                {
                    Lat = Convert.ToDouble(r["Lat"]),
                    Lng = Convert.ToDouble(r["Lng"]),
                    Name = (r["PlaceName"] == DBNull.Value ? "" : r["PlaceName"].ToString()).Trim()
                });
            }
            return list;
        }

        /// <summary>
        /// Stores the package itinerary as the trip's stops. The customer's own pickup point
        /// comes first when they set one, the last place is the destination, and everything
        /// between them is a stop the maps number in driving order.
        /// </summary>
        private void InsertPackageStops(int tripId, List<PackagePlace> places)
        {
            int order = 1;
            DataRow trip = Helper.DBHelper.ExecuteQuery(
                "SELECT PickupLat, PickupLng, ISNULL(PickupAddress,'') AS A FROM Trips WHERE TripID=@t",
                new SqlParameter("@t", tripId)).Rows[0];

            // A place the customer also pinned by hand is left out, so the map does not
            // show the same spot twice.
            int start = IsSameSpot(Convert.ToDouble(trip["PickupLat"]), Convert.ToDouble(trip["PickupLng"]), places[0])
                ? 1 : 0;
            int end = places.Count - 1;
            if (end > start && IsSameSpot(Convert.ToDouble(trip["PickupLat"]), Convert.ToDouble(trip["PickupLng"]), places[end]))
                end--;

            var points = new List<PackagePlace>
            {
                new PackagePlace
                {
                    Lat = Convert.ToDouble(trip["PickupLat"]),
                    Lng = Convert.ToDouble(trip["PickupLng"]),
                    Name = trip["A"].ToString()
                }
            };
            for (int i = start; i <= end; i++) points.Add(places[i]);

            foreach (PackagePlace p in points)
                Helper.DBHelper.ExecuteNonQuery(
                    "INSERT INTO TripStops (TripID, Lat, Lng, Address, OrderIndex) VALUES (@t, @lat, @lng, @a, @o)",
                    new SqlParameter("@t", tripId),
                    new SqlParameter("@lat", p.Lat),
                    new SqlParameter("@lng", p.Lng),
                    new SqlParameter("@a", (object)p.Name ?? DBNull.Value),
                    new SqlParameter("@o", order++));
        }

        private static bool IsSameSpot(double lat, double lng, PackagePlace place)
        {
            return Math.Abs(lat - place.Lat) < 0.000001 && Math.Abs(lng - place.Lng) < 0.000001;
        }

        /// <summary>
        /// Length of the whole package route (pickup -> every place -> last place) so the trip
        /// carries the real distance, not just the straight line to the destination.
        /// </summary>
        private static decimal? PackageRouteKm(double pickupLat, double pickupLng, List<PackagePlace> places)
        {
            if (places.Count < 2) return null;

            decimal total = 0m;
            double prevLat = pickupLat, prevLng = pickupLng;
            for (int i = 0; i < places.Count; i++)
            {
                total += Helper.TripHelper.HaversineKm(prevLat, prevLng, places[i].Lat, places[i].Lng);
                prevLat = places[i].Lat;
                prevLng = places[i].Lng;
            }
            return total;
        }

        // Persist the full ordered route (first stop = pickup, last = dropoff)
        // so drivers/customers can see every point on the trip map.
        private void InsertStops(int tripId, double pickupLat, double pickupLng, string pickupAddr,
            double dropLat, double dropLng, string dropAddr)
        {
            int order = 1;
            Helper.DBHelper.ExecuteNonQuery(
                "INSERT INTO TripStops (TripID, Lat, Lng, Address, OrderIndex) VALUES (@t, @lat, @lng, @a, @o)",
                new SqlParameter("@t", tripId),
                new SqlParameter("@lat", pickupLat),
                new SqlParameter("@lng", pickupLng),
                new SqlParameter("@a", (object)pickupAddr ?? DBNull.Value),
                new SqlParameter("@o", order++));

            foreach (object[] s in ParseStops())
            {
                if (s == null || s.Length < 2) continue;
                // Already validated by StopsWithinServiceArea before the trip was
                // created; parsed defensively here so a hand-crafted hfStops value
                // can never throw a FormatException halfway through the inserts.
                double sLat, sLng;
                if (!TryParseStop(s[0], out sLat)) continue;
                if (!TryParseStop(s[1], out sLng)) continue;
                if (!Helper.TripHelper.IsWithinServiceArea(sLat, sLng)) continue;
                Helper.DBHelper.ExecuteNonQuery(
                    "INSERT INTO TripStops (TripID, Lat, Lng, Address, OrderIndex) VALUES (@t, @lat, @lng, @a, @o)",
                    new SqlParameter("@t", tripId),
                    new SqlParameter("@lat", sLat),
                    new SqlParameter("@lng", sLng),
                    new SqlParameter("@a", DBNull.Value),
                    new SqlParameter("@o", order++));
            }

            Helper.DBHelper.ExecuteNonQuery(
                "INSERT INTO TripStops (TripID, Lat, Lng, Address, OrderIndex) VALUES (@t, @lat, @lng, @a, @o)",
                new SqlParameter("@t", tripId),
                new SqlParameter("@lat", dropLat),
                new SqlParameter("@lng", dropLng),
                new SqlParameter("@a", (object)dropAddr ?? DBNull.Value),
                new SqlParameter("@o", order++));
        }

        /// <summary>
        /// The rate row for a vehicle and service. Only the two rate columns that are actually
        /// charged are selected: PerKmRate for point-to-point and HourlyRate for hourly. The
        /// BaseFare column is no longer part of any calculation and is not read here.
        /// </summary>
        /// <summary>
        /// The rate row for a vehicle and service, or null when there is nothing usable to
        /// charge. Only the two rate columns that are actually charged are selected: PerKmRate
        /// for point-to-point and HourlyRate for hourly. The BaseFare column is no longer part
        /// of any calculation and is not read here.
        ///
        /// MAX is used so the fare charged is the same figure the page quoted. The page builds
        /// its RATES object with MAX over the vehicle's rows, so if a second rate row were ever
        /// added for the same vehicle and service, taking the first row here would quietly price
        /// the booking differently from the price on the card the customer clicked.
        ///
        /// A row that exists but holds nothing usable counts as no rate rather than a fare of
        /// zero. Mapping a missing rate to 0 let a vehicle with no hourly rate set be booked for
        /// nothing, so the caller now stops and says so instead of taking the booking.
        /// </summary>
        private DataRow GetRate(int vehicleType, int serviceType)
        {
            DataTable dt = Helper.DBHelper.ExecuteQuery(
                CurrentRateForVehicleSql, new SqlParameter("@v", vehicleType));
            if (dt.Rows.Count == 0) return null;

            DataRow rate = dt.Rows[0];
            // serviceType still decides which column of the vehicle's single row is charged, so a
            // vehicle that offers one service but not the other is refused rather than priced at 0.
            object value = serviceType == 2 ? rate["HourlyRate"] : rate["PerKmRate"];
            if (value == null || value == DBNull.Value) return null;
            return Convert.ToDecimal(value) > 0m ? rate : null;
        }

        /// <summary>
        /// The hour blocks on sale, and they must stay in step with the ddlHours ListItems in
        /// BookTrip.aspx (1, 2, 3, 4, 5, 6 and the 8 hour full day). The client builds the same
        /// list into the hour cards; this is the copy that decides what may actually be charged.
        /// </summary>
        private static readonly int[] HourlyHourBlocks = { 1, 2, 3, 4, 5, 6, 8 };

        private static bool HourlyBlockIsSold(int hours)
        {
            return Array.IndexOf(HourlyHourBlocks, hours) >= 0;
        }

        /// <summary>
        /// Hourly fare for a booking, off the hourly row of the rate table. One flat rate for
        /// every hour: no base fare for the first hour and no separate rate for the hours after
        /// it, so the total is simply the per-hour rate times the hours booked.
        ///
        ///     fare = HourlyRate x hours
        ///
        /// The arithmetic itself lives in TripHelper.EstimateHourly, which is the one place the
        /// rule is written down, and hourFare() in BookTrip.aspx quotes the same figure.
        /// Distance is not part of an hourly fare, so the fare never moves with the route.
        /// </summary>
        private static decimal HourlyFare(DataRow rate, int hours)
        {
            if (hours < 1) hours = 1;
            object perHour = rate["HourlyRate"];
            return Helper.TripHelper.RoundFare(
                Helper.TripHelper.EstimateHourly(perHour == DBNull.Value ? 0m : Convert.ToDecimal(perHour), hours));
        }

        /// <summary>
        /// Whether the chosen vehicle can carry the chosen party, as a message to show.
        ///
        /// Returns null when the pairing is fine. This used to throw on an over-capacity party,
        /// which made it the one refusal on this page that did not go through ShowMessage and
        /// so escaped as an error page instead of a toast.
        /// </summary>
        private string CapacityProblem(int vehicleType)
        {
            DataTable dt = Helper.DBHelper.ExecuteQuery(
                "SELECT MinSeatCapacity, MaxSeatCapacity FROM VehicleTypes WHERE VehicleTypeID=@v",
                new SqlParameter("@v", vehicleType));
            if (dt.Rows.Count == 0) return null;

            // TryParse, not Parse: an unreadable passenger count is a reason to ask again, not
            // a reason to abandon the whole booking with an error page.
            int pax;
            if (!int.TryParse(ddlPassengers.SelectedValue, out pax))
            {
                return "Please choose how many passengers are travelling.";
            }

            int min = Convert.ToInt32(dt.Rows[0]["MinSeatCapacity"]);
            int max = Convert.ToInt32(dt.Rows[0]["MaxSeatCapacity"]);
            if (pax < min || pax > max)
            {
                return string.Format("This vehicle carries {0}-{1} passengers.", min, max);
            }
            return null;
        }

        /// <summary>
        /// Reports an over-capacity party as a toast and says whether the caller should stop.
        /// A method rather than a bare check so the three places that need it cannot each end
        /// up handling the refusal slightly differently.
        /// </summary>
        private bool RefuseIfOverCapacity(int vehicleType)
        {
            string problem = CapacityProblem(vehicleType);
            if (problem == null) return false;
            ShowMessage(problem, true);
            return true;
        }

        private bool HasActiveTrip()
        {
            object o = Helper.DBHelper.ExecuteScalar(
                "SELECT COUNT(*) FROM Trips WHERE CustomerID=@c AND Status IN (" + ActiveStates + ")",
                new SqlParameter("@c", CustomerId));
            return Convert.ToInt32(o) > 0;
        }

        /// <summary>
        /// The booking could not go through. Recorded as the page's one toast rather than shown
        /// as a banner, so a refused confirm reads the same way a successful one does.
        /// lblMessage is left empty on purpose: the message is not also painted into the page.
        /// </summary>
        private void ShowMessage(string msg, bool isError)
        {
            ConfirmToastKind = isError ? "error" : "success";
            ConfirmToastText = msg;
            pnlMessage.Visible = false;
            lblMessage.Text = "";
        }
    }
}