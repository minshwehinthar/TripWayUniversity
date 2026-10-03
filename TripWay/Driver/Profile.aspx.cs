using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Web.UI.WebControls;

namespace TripWay.Driver
{
    public partial class ProfilePage : Helper.ListPageBase
    {
        private int DriverId { get { return Helper.AuthHelper.GetAccountId(); } }

        /// <summary>
        /// Rendered state of the online switch. The checkbox posts back through
        /// lnkToggleOnline, and every path that ends in a redraw has to refresh this
        /// so the knob never drifts away from the value in the database.
        /// </summary>
        public bool IsOnlineNow { get; private set; }

        /// <summary>
        /// The document already stored in each picker, so the slot shows the original photo
        /// and its name until the driver picks a replacement. Null when nothing is uploaded.
        /// </summary>
        public DocItem NrcStored { get; private set; }
        public DocItem LicenseStored { get; private set; }
        public DocItem VehicleStored { get; private set; }
        public DocItem RegDocStored { get; private set; }

        protected void Page_Load(object sender, EventArgs e)
        {
            Helper.AuthHelper.RequireDriver(this);
            if (!IsPostBack) LoadProfile();

            /* On a postback the panel is re-declared hidden, so a ticked "Remove current
               photo" would silently vanish when something else fails validation and the save
               is abandoned. Checkboxes do round-trip, so trust that instead. */
            if (IsPostBack && chkRemovePhoto.Checked) pnlRemovePhoto.Visible = true;

        }

        private void LoadProfile()
        {
            DataTable t = Helper.DBHelper.ExecuteQuery(
                @"SELECT d.*, v.Name AS VehicleTypeName FROM Drivers d
                  INNER JOIN VehicleTypes v ON d.VehicleTypeID = v.VehicleTypeID
                  WHERE d.DriverID=@id",
                new SqlParameter("@id", DriverId));

            if (t.Rows.Count == 0) return;
            DataRow r = t.Rows[0];

            lblName.InnerText = r["FullName"].ToString();
            lblEmail.InnerText = r["Email"].ToString();
            txtFullName.Text = r["FullName"].ToString();
            txtPhone.Text = r["PhoneNumber"].ToString();
            txtPaymentAccount.Text = r["PaymentAccount"] == DBNull.Value ? "" : r["PaymentAccount"].ToString();
            txtVehicleType.Text = r["VehicleTypeName"].ToString();
            txtSeatCapacity.Text = r["SeatCapacity"].ToString();
            txtPlate.Text = r["VehiclePlateNumber"].ToString();
            lblJoined.InnerText = r["CreatedAt"] == DBNull.Value ? "" : "Joined " + FormatTime(r["CreatedAt"], "dd MMM yyyy");

            string photoPath = r["ProfilePhotoUrl"] == DBNull.Value ? "" : r["ProfilePhotoUrl"].ToString();
            if (!string.IsNullOrEmpty(photoPath))
            {
                // ImageUrl needs the app-relative "~/" form; DriverPhotoUrl returns a
                // bare path that would resolve against /Driver/ on this page.
                imgProfilePhoto.ImageUrl = "~/" + Helper.TripHelper.DriverPhotoUrl(photoPath);
                imgProfilePhoto.Visible = true;
                imgDefaultPhoto.Visible = false;
            }
            else
            {
                imgProfilePhoto.Visible = false;
                imgDefaultPhoto.Visible = true;
            }

            // Nothing to remove until something has been stored.
            pnlRemovePhoto.Visible = !string.IsNullOrEmpty(photoPath);

            string kyc = r["KYCStatus"].ToString();
            SetKycPill(kyc);

            IsOnlineNow = r["IsOnline"] != DBNull.Value && Convert.ToBoolean(r["IsOnline"]);
            lblOnlineText.Text = IsOnlineNow ? "Online" : "Offline";

            NrcStored = ToDoc(r["NRCPhotoUrl"]);
            LicenseStored = ToDoc(r["LicensePhotoUrl"]);
            VehicleStored = ToDoc(r["VehiclePhotoUrl"]);
            RegDocStored = ToDoc(r["VehicleRegDocUrl"]);

            var docs = new List<DocItem>();
            AddDoc(docs, "NRC", NrcStored);
            AddDoc(docs, "License", LicenseStored);
            AddDoc(docs, "Vehicle", VehicleStored);
            AddDoc(docs, "Reg. Doc", RegDocStored);
            rptDocs.DataSource = docs;
            rptDocs.DataBind();
            SetNoDataBlock(pnlNoDocs, docs.Count == 0,
                "No documents have been uploaded yet. Add them below and save.");

            var master = (SiteMaster)Master;
            master.RefreshUserInfo();
        }

        private void SetKycPill(string kyc)
        {
            string css = "inline-flex px-2.5 py-0.5 rounded-full text-[11px] font-bold ";
            switch (kyc)
            {
                case "Approved": css += "bg-emerald-50 text-emerald-700"; break;
                case "Rejected": css += "bg-red-50 text-red-700"; break;
                default: css += "bg-blue-50 text-blue-700"; break;
            }
            lblKycPill.Attributes["class"] = css;
            lblKycPill.InnerText = kyc;
        }

        private void AddDoc(List<DocItem> docs, string label, DocItem item)
        {
            if (item == null) return;
            docs.Add(new DocItem
            {
                Label = label,
                FileName = item.FileName,
                Src = item.Src,
                IsImage = item.IsImage,
                IsPdf = item.IsPdf
            });
        }

        /// <summary>
        /// Builds the viewer URL for one stored document, or null when the driver has not
        /// uploaded that document yet. The four properties feed the pickers below the gallery
        /// so each one can show the original photo until a new file is chosen.
        /// </summary>
        private DocItem ToDoc(object url)
        {
            if (url == null || url == DBNull.Value) return null;
            string value = url.ToString().Trim();
            if (value.Length == 0) return null;

            return new DocItem
            {
                FileName = value.Substring(value.LastIndexOf('/') + 1),
                Src = Helper.TripHelper.FileViewerUrl(value),
                IsImage = Helper.TripHelper.IsViewableImage(value),
                IsPdf = Helper.TripHelper.IsPdfFile(value)
            };
        }

        /// <summary>
        /// Builds the data-* attributes that open the shared image lightbox in Site.Master.
        /// </summary>
        public string DocAttrs(object src, object label, object name, object isPdf)
        {
            return Helper.TripHelper.DocDataAttrs(src, label, name, Convert.ToBoolean(isPdf));
        }

        public class DocItem
        {
            public string Label { get; set; }
            public string Src { get; set; }
            public string FileName { get; set; }
            public bool IsImage { get; set; }
            public bool IsPdf { get; set; }
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            string nrcUrl = SaveUpload(fuNrcPhoto, "NRCPhotos", "NRC");
            string licUrl = SaveUpload(fuLicensePhoto, "LicensePhotos", "License");
            string vehUrl = SaveUpload(fuVehiclePhoto, "VehiclePhotos", "Vehicle");
            string regUrl = SaveUpload(fuRegDoc, "RegDocs", "RegDoc");

            if (_documentRefused)
            {
                ShowProfileMessage("Those files were not accepted. Use a JPG or PNG photo, or a "
                    + "PDF for the registration document, each under "
                    + (Helper.TripHelper.MaxImageBytes / (1024 * 1024)) + " MB.", true);
                return;
            }

            object storedPhoto = Helper.DBHelper.ExecuteScalar(
                "SELECT ProfilePhotoUrl FROM Drivers WHERE DriverID=@id",
                new SqlParameter("@id", DriverId));
            string currentPhoto = Helper.TripHelper.DriverPhotoUrl(storedPhoto);

            /* Recorded here, not carried out: the file stays on disk until the row has
               stopped pointing at it, so a refused upload cannot take away the photo the
               driver already has. */
            bool photoRemoved = chkRemovePhoto.Checked && currentPhoto.Length > 0;

            // Profile photo is optional and independent of KYC: a rejected photo must not
            // push the account back into KYC review the way a document upload does.
            string photoUrl = null;
            if (fuProfilePhoto.HasFile)
            {
                photoUrl = SaveProfilePhoto();
                if (photoUrl == null)
                {
                    ShowPhotoRefused();
                    return;
                }
            }

            bool docsChanged = nrcUrl != null || licUrl != null || vehUrl != null || regUrl != null;

            var sets = new List<string>
            {
                "FullName=@n",
                "PhoneNumber=@p",
                "PaymentAccount=@pa",
                "SeatCapacity=@s",
                "VehiclePlateNumber=@pl"
            };
            var pars = new List<SqlParameter>
            {
                new SqlParameter("@n", txtFullName.Text.Trim()),
                new SqlParameter("@p", txtPhone.Text.Trim()),
                new SqlParameter("@pa", string.IsNullOrEmpty(txtPaymentAccount.Text) ? (object)DBNull.Value : txtPaymentAccount.Text.Trim()),
                new SqlParameter("@s", string.IsNullOrEmpty(txtSeatCapacity.Text) ? 0 : int.Parse(txtSeatCapacity.Text)),
                new SqlParameter("@pl", txtPlate.Text.Trim())
            };

            if (nrcUrl != null) { sets.Add("NRCPhotoUrl=@nrc"); pars.Add(new SqlParameter("@nrc", nrcUrl)); }
            if (licUrl != null) { sets.Add("LicensePhotoUrl=@lic"); pars.Add(new SqlParameter("@lic", licUrl)); }
            if (vehUrl != null) { sets.Add("VehiclePhotoUrl=@veh"); pars.Add(new SqlParameter("@veh", vehUrl)); }
            if (regUrl != null) { sets.Add("VehicleRegDocUrl=@reg"); pars.Add(new SqlParameter("@reg", regUrl)); }
            /* A new file wins over an explicit remove, and doing neither leaves the stored
               value exactly as it was. Only touched when something actually changed, so an
               unrelated edit cannot rewrite this column. */
            if (photoUrl != null) { sets.Add("ProfilePhotoUrl=@ph"); pars.Add(new SqlParameter("@ph", photoUrl)); }
            else if (photoRemoved) { sets.Add("ProfilePhotoUrl=@ph"); pars.Add(new SqlParameter("@ph", DBNull.Value)); }

            if (docsChanged)
            {
                sets.Add("KYCStatus='Pending'");   // re-review needed
            }

            pars.Add(new SqlParameter("@id", DriverId));
            Helper.DBHelper.ExecuteNonQuery("UPDATE Drivers SET " + string.Join(", ", sets) + " WHERE DriverID=@id", pars.ToArray());

            /* The row no longer refers to the old file, whether it was replaced or removed,
               so this is the first moment at which dropping it cannot leave a photo missing. */
            if (currentPhoto.Length > 0 && (photoRemoved || photoUrl != null))
                Helper.TripHelper.DeleteStoredPhoto(currentPhoto, Helper.TripHelper.DriverPhotoFolder);

            chkRemovePhoto.Checked = false;

            if (docsChanged)
                Helper.TripHelper.LogActivity("KYCUpdated", null, "Driver " + DriverId + " uploaded replacement KYC documents (status reset to Pending).");

            ShowProfileMessage(docsChanged
                ? "Profile saved. Your KYC returns to Pending for admin re-approval."
                : "Profile updated successfully.", false);
            LoadProfile();
        }

        /// <summary>
        /// Stores the picked avatar in the driver photo folder and returns the relative path,
        /// or null when no file was picked or the file was refused.
        /// </summary>
        private string SaveProfilePhoto()
        {
            if (!fuProfilePhoto.HasFile) return null;

            return Helper.TripHelper.StoreImage(
                fuProfilePhoto.PostedFile, Helper.TripHelper.DriverPhotoFolder, "Driver_" + DriverId);
        }

        private void ShowPhotoRefused()
        {
            ShowProfileMessage("Profile photo must be a JPG or PNG image under "
                + (Helper.TripHelper.MaxImageBytes / (1024 * 1024)) + " MB.", true);
        }

        protected void lnkToggleOnline_Click(object sender, EventArgs e)
        {
            DataRow r = Helper.DBHelper.ExecuteQuery(
                "SELECT KYCStatus, IsOnline FROM Drivers WHERE DriverID=@id",
                new SqlParameter("@id", DriverId)).Rows[0];
            bool nowOnline = !(r["IsOnline"] != DBNull.Value && Convert.ToBoolean(r["IsOnline"]));
            if (r["KYCStatus"].ToString() != "Approved")
            {
                // The checkbox has already moved client side, so redraw from the database
                // to snap it back to the real value instead of leaving it lying.
                LoadProfile();
                ShowProfileMessage("You must be approved before going online.", true);
                return;
            }

            Helper.DBHelper.ExecuteNonQuery(
                "UPDATE Drivers SET IsOnline=@o WHERE DriverID=@id",
                new SqlParameter("@o", nowOnline), new SqlParameter("@id", DriverId));
            Helper.TripHelper.LogActivity(nowOnline ? "DriverOnline" : "DriverOffline", null,
                "Driver " + DriverId + " went " + (nowOnline ? "online" : "offline") + ".");
            LoadProfile();
        }

        protected void btnChangePassword_Click(object sender, EventArgs e)
        {
            string current = txtCurrentPassword.Text;
            if (current.Length == 0 || txtNewPassword.Text.Length == 0 || txtConfirmPassword.Text.Length == 0)
            {
                ShowPasswordMessage("Please fill in all password fields.", true);
                return;
            }

            object hash = Helper.DBHelper.ExecuteScalar(
                "SELECT PasswordHash FROM Drivers WHERE DriverID=@id",
                new SqlParameter("@id", DriverId));
            if (hash == null || !Helper.AuthHelper.VerifyPassword(current, hash.ToString()))
            {
                ShowPasswordMessage("Current password is incorrect.", true);
                return;
            }

            Helper.DBHelper.ExecuteNonQuery(
                "UPDATE Drivers SET PasswordHash=@h WHERE DriverID=@id",
                new SqlParameter("@h", Helper.AuthHelper.HashPassword(txtNewPassword.Text)),
                new SqlParameter("@id", DriverId));

            txtCurrentPassword.Text = "";
            txtNewPassword.Text = "";
            txtConfirmPassword.Text = "";
            ShowPasswordMessage("Password updated successfully.", false);
        }

        private string SaveUpload(FileUpload fu, string folder, string prefix)
        {
            if (!fu.HasFile) return null;

            // The shared uploader is used rather than writing the posted extension out by
            // hand, so an uploaded ".aspx" can never land inside the Uploads folder. The
            // registration document is allowed to be a PDF; everything else must be an image.
            string saved = Helper.TripHelper.StoreImage(fu.PostedFile, "Uploads/" + folder, prefix);
            if (saved == null && folder == "RegDocs")
                saved = SaveDocument(fu, folder, prefix);

            if (saved == null)
            {
                // A file was chosen but refused, which is different from no file at all and
                // would otherwise be saved as a silent no-op.
                _documentRefused = true;
                return null;
            }
            return saved;
        }

        /// <summary>
        /// Set when a chosen upload was refused, so the save can be stopped and the reason
        /// shown instead of the profile quietly appearing unchanged.
        /// </summary>
        private bool _documentRefused;

        private static readonly string[] DocumentExtensions = { ".pdf", ".jpg", ".jpeg", ".png" };

        private string SaveDocument(FileUpload fu, string folder, string prefix)
        {
            string ext = Path.GetExtension(fu.FileName ?? "").ToLowerInvariant();
            if (Array.IndexOf(DocumentExtensions, ext) < 0) return null;
            if (fu.PostedFile.ContentLength <= 0
                || fu.PostedFile.ContentLength > Helper.TripHelper.MaxImageBytes) return null;

            string dir = Server.MapPath("~/Uploads/" + folder);
            if (!Directory.Exists(dir)) Directory.CreateDirectory(dir);

            string name = prefix + "_" + DateTime.Now.Ticks + ext;
            fu.PostedFile.SaveAs(Path.Combine(dir, name));
            return "Uploads/" + folder + "/" + name;
        }

        private void ShowProfileMessage(string msg, bool isError)
        {
            pnlProfileMsg.Visible = true;
            lblProfileMsg.Text = msg;
            pnlProfileMsg.CssClass = isError
                ? "mb-4 p-3 rounded-lg text-sm bg-red-100 text-red-700 border border-red-200"
                : "mb-4 p-3 rounded-lg text-sm bg-green-100 text-green-700 border border-green-200";
        }

        private void ShowPasswordMessage(string msg, bool isError)
        {
            pnlPwdMsg.Visible = true;
            lblPwdMsg.Text = msg;
            pnlPwdMsg.CssClass = isError
                ? "mb-4 p-3 rounded-lg text-sm bg-red-100 text-red-700 border border-red-200"
                : "mb-4 p-3 rounded-lg text-sm bg-green-100 text-green-700 border border-green-200";
        }
    }
}