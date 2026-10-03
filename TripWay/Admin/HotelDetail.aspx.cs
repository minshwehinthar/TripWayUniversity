using System;
using System.Data;
using System.Data.SqlClient;

namespace TripWay.Admin
{
    /// <summary>
    /// Read-only detail view of one hotel: its logo, map pin, contact details and whether it is
    /// currently offered on the booking page. Editing happens on HotelEdit, and the page offers
    /// no toggle or delete of its own, so browsing here can never change anything.
    /// </summary>
    public partial class HotelDetailPage : Helper.ListPageBase
    {
        // Always valid numbers, so the inline map script cannot emit a syntax error
        // when the "no longer exists" panel is the thing being shown.
        private const double FallbackLat = 16.890;
        private const double FallbackLng = 97.633;

        private double _lat = FallbackLat;
        private double _lng = FallbackLng;
        private bool _hasHotel;

        public int HotelIdParam
        {
            get
            {
                int id;
                return int.TryParse(Request.QueryString["id"], out id) && id > 0 ? id : 0;
            }
        }

        /// <summary>Invariant-culture coordinates for the inline map script.</summary>
        public string LatJs { get { return _lat.ToString("R", System.Globalization.CultureInfo.InvariantCulture); } }

        public string LngJs { get { return _lng.ToString("R", System.Globalization.CultureInfo.InvariantCulture); } }

        /// <summary>Emitted into the inline script as the JavaScript literal true or false.</summary>
        public string HasHotelJs { get { return _hasHotel ? "true" : "false"; } }

        protected override void OnInit(EventArgs e)
        {
            base.OnInit(e);
            Helper.TripHelper.EnsureHotels();
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            Helper.AuthHelper.RequireAdmin(this);
            if (!IsPostBack) Bind();
        }

        private void Bind()
        {
            int id = HotelIdParam;
            if (id == 0)
            {
                pnlMissing.Visible = true;
                return;
            }

            DataTable t = Helper.DBHelper.ExecuteQuery(
                @"SELECT Name, Address, Phone, Email, LogoPhotoUrl, Lat, Lng, IsActive, CreatedAt,
                         (SELECT COUNT(*) FROM Trips tr WHERE tr.HotelID = h.HotelID) AS TripsCount
                    FROM Hotels h WHERE HotelID=@id",
                new SqlParameter("@id", id));

            if (t.Rows.Count == 0)
            {
                pnlMissing.Visible = true;
                return;
            }

            DataRow r = t.Rows[0];
            pnlHotel.Visible = true;
            _hasHotel = true;

            bool isActive = Convert.ToBoolean(r["IsActive"]);

            lblCardName.Text = Server.HtmlEncode(r["Name"].ToString());
            lblPhone.Text = OrDash(r["Phone"]);
            lblEmail.Text = Server.HtmlEncode(OrDash(r["Email"]));
            lblAddress.Text = Server.HtmlEncode(OrDash(r["Address"]));

            _lat = Convert.ToDouble(r["Lat"], System.Globalization.CultureInfo.InvariantCulture);
            _lng = Convert.ToDouble(r["Lng"], System.Globalization.CultureInfo.InvariantCulture);
            lblLat.Text = _lat.ToString("0.000000", System.Globalization.CultureInfo.InvariantCulture);
            lblLng.Text = _lng.ToString("0.000000", System.Globalization.CultureInfo.InvariantCulture);

            lblActive.Text = isActive ? "Active" : "Hidden";
            lblActive.CssClass = "inline-flex px-2.5 py-0.5 rounded-full text-[11px] font-bold "
                + (isActive ? "bg-green-100 text-green-700" : "bg-gray-100 text-gray-500");

            // This label now reads on its own next to the Edit button, so it carries the whole
            // sentence rather than a count the markup finishes off with "routed here".
            int trips = Convert.ToInt32(r["TripsCount"]);
            lblTrips.Text = trips == 0 ? "No trips routed here yet"
                : trips + (trips == 1 ? " trip routed here" : " trips routed here");

            string logo = Helper.TripHelper.HotelPhotoUrl(r["LogoPhotoUrl"]);
            pnlLogo.Visible = logo.Length > 0;
            pnlLogoNone.Visible = logo.Length == 0;
            if (logo.Length > 0) imgLogo.ImageUrl = ResolveUrl("~/" + logo);
        }

        private static string OrDash(object value)
        {
            if (value == null || value == DBNull.Value) return "—";
            string text = value.ToString().Trim();
            return text.Length == 0 ? "—" : text;
        }
    }
}
