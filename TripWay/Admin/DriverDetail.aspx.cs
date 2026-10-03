using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Web;

namespace TripWay.Admin
{
    public partial class DriverDetailPage : Helper.ListPageBase
    {
        private int driverId;

        protected void Page_Load(object sender, EventArgs e)
        {
            Helper.AuthHelper.RequireAdmin(this);
            if (!int.TryParse(Request.QueryString["id"], out driverId))
            {
                Response.Redirect("DriverManagement.aspx");
                return;
            }
            if (!IsPostBack) LoadDriver();
        }

        private void LoadDriver()
        {
            DataTable t = Helper.DBHelper.ExecuteQuery(
                @"SELECT d.*, v.Name AS VehicleTypeName
                  FROM Drivers d
                  INNER JOIN VehicleTypes v ON d.VehicleTypeID = v.VehicleTypeID
                  WHERE d.DriverID = @id",
                new SqlParameter("@id", driverId));

            if (t.Rows.Count == 0)
            {
                pnlError.Visible = true;
                lblError.Text = "Driver not found.";
                pnlDriver.Visible = false;
                return;
            }

            pnlDriver.Visible = true;
            pnlError.Visible = false;

            DataRow r = t.Rows[0];
            lblAvatar.Text = GetInitial(r["FullName"].ToString());
            ShowPhoto(r["ProfilePhotoUrl"]);
            lblName.Text = Enc(r["FullName"]);
            lblEmail.Text = Enc(r["Email"]);
            lblDriverId.Text = driverId.ToString("N0");
            lblJoined.Text = r["CreatedAt"] == DBNull.Value ? "—" : Helper.TripHelper.FormatMyanmarTime(r["CreatedAt"], "dd MMM yyyy");
            lblNrc.Text = Enc(r["NRCNumber"]);
            lblLicense.Text = Enc(r["LicenseNumber"]);

            string kyc = r["KYCStatus"].ToString();
            lblKycState.CssClass = PillBase + PillCss(GetStatusCss(kyc));
            lblKycState.Text = kyc;

            bool online = r["IsOnline"] != DBNull.Value && Convert.ToBoolean(r["IsOnline"]);
            lblOnline.CssClass = PillBase + (online ? "bg-emerald-100 text-emerald-700" : "bg-gray-100 text-gray-600");
            lblOnline.Text = online ? "Online" : "Offline";

            BindIdentity(r);
            BindVehicle(r);
            BindDocs(r);
        }

        /// <summary>
        /// Repeaters and Literals write their text raw, so every value that came from the
        /// database is encoded once here rather than trusting the markup to do it.
        /// </summary>
        public string Enc(object value)
        {
            if (value == null || value == DBNull.Value) return "";
            return HttpUtility.HtmlEncode(Convert.ToString(value, CultureInfo.InvariantCulture));
        }

        /// <summary>
        /// GetStatusCss returns the -50 badge shade used by the list pages. The identity-card
        /// pills sit on a white card next to a solid role pill, so they take the -100 shade
        /// instead. Only the background class is touched; the text colour is left as-is.
        /// </summary>
        private static string PillCss(string statusCss)
        {
            return statusCss.Replace("-50 ", "-100 ");
        }

        private static string OrDash(object value)
        {
            if (value == null || value == DBNull.Value) return "—";
            string s = Convert.ToString(value).Trim();
            return s.Length == 0 ? "—" : HttpUtility.HtmlEncode(s);
        }


        // ---------------------------------------------------------------- identity

        private void BindIdentity(DataRow r)
        {
            // Same fields, in the same order, as the editable form: everything else this page
            // used to repeat in a table is already shown on the identity card above.
            var items = new List<Kv>
            {
                new Kv { Label = "Email",          Value = OrDash(r["Email"]) },
                new Kv { Label = "Full Name",      Value = OrDash(r["FullName"]) },
                new Kv { Label = "Phone",          Value = OrDash(r["PhoneNumber"]) },
                new Kv { Label = "Payment Account", Value = OrDash(r["PaymentAccount"]) }
            };
            rptIdentity.DataSource = items;
            rptIdentity.DataBind();
        }

        private void BindVehicle(DataRow r)
        {
            var items = new List<Kv>
            {
                new Kv { Label = "Vehicle Type", Value = OrDash(r["VehicleTypeName"]) },
                new Kv { Label = "Seat Capacity", Value = r["SeatCapacity"] == DBNull.Value ? "—" : Enc(r["SeatCapacity"]) }
            };
            rptVehicle.DataSource = items;
            rptVehicle.DataBind();
            lblPlate.Text = OrDash(r["VehiclePlateNumber"]);

            // CurrentLat/CurrentLng are only written while the driver app is reporting
            // location, so an unassigned driver legitimately has no coordinates yet.
            bool hasCoords = r["CurrentLat"] != DBNull.Value && r["CurrentLng"] != DBNull.Value;
            lblLastLocation.Text = hasCoords
                ? HttpUtility.HtmlEncode(Convert.ToDecimal(r["CurrentLat"]).ToString("0.######"))
                  + ", " + HttpUtility.HtmlEncode(Convert.ToDecimal(r["CurrentLng"]).ToString("0.######"))
                : "Not reported yet";
        }

        // ------------------------------------------------------------------- docs

        private void BindDocs(DataRow r)
        {
            var docs = new List<DocItem>();
            AddDoc(docs, "NRC Photo", r["NRCPhotoUrl"]);
            AddDoc(docs, "License Photo", r["LicensePhotoUrl"]);
            AddDoc(docs, "Vehicle Photo", r["VehiclePhotoUrl"]);
            AddDoc(docs, "Reg. Document", r["VehicleRegDocUrl"]);
            rptDocs.DataSource = docs;
            rptDocs.DataBind();
            pnlNoDocs.Visible = docs.Count == 0;
        }

        private void ShowPhoto(object storedPath)
        {
            string url = Helper.TripHelper.DriverPhotoUrl(storedPath);
            bool has = url.Length > 0;

            imgDriverPhoto.Visible = has;
            pnlDriverAvatar.Visible = !has;
            if (has) imgDriverPhoto.ImageUrl = ResolveUrl("~/" + url);
        }

        private void AddDoc(List<DocItem> docs, string label, object url)
        {
            if (url == null || url == DBNull.Value) return;
            string value = url.ToString().Trim();
            if (value.Length == 0) return;

            string fileName = value.Substring(value.LastIndexOf('/') + 1);

            docs.Add(new DocItem
            {
                Label = label,
                FileName = fileName,
                // ViewFile.ashx sends Content-Disposition: inline, so the browser renders
                // the bytes in place instead of downloading them.
                Src = Helper.TripHelper.FileViewerUrl(value),
                IsImage = Helper.TripHelper.IsViewableImage(value),
                IsPdf = Helper.TripHelper.IsPdfFile(value)
            });
        }

        /// <summary>
        /// Builds the data-* attributes the shared lightbox in Site.Master reads.
        /// </summary>
        public string DocAttrs(object src, object label, object name, object isPdf)
        {
            return Helper.TripHelper.DocDataAttrs(src, label, name, Convert.ToBoolean(isPdf));
        }

        // This page only shows what is on record. Approving, rejecting, deleting and editing
        // all happen elsewhere, so there is deliberately no action handler here.

        // ------------------------------------------------------------------- items

        private class Kv
        {
            public string Label { get; set; }
            public string Value { get; set; }
        }


        private class DocItem
        {
            public string Label { get; set; }
            public string Src { get; set; }
            public string FileName { get; set; }
            public bool IsImage { get; set; }
            public bool IsPdf { get; set; }
        }
    }
}
