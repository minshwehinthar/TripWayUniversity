using System;
using System.Data;
using System.Data.SqlClient;
using System.IO;

namespace TripWay.Admin
{
    /// <summary>
    /// Edit-only form for a driver. Creating lives on CreateDriver.aspx; viewing, the KYC
    /// decision and the profile photo are on DriverDetail.aspx, so ?id= is mandatory here.
    /// The password is not on this form: it is hashed at creation and never stored in the clear.
    /// </summary>
    public partial class DriverEditPage : Helper.ListPageBase
    {
        public int DriverIdParam
        {
            get
            {
                int id;
                return int.TryParse(Request.QueryString["id"], out id) && id > 0 ? id : 0;
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            Helper.AuthHelper.RequireAdmin(this);

            if (DriverIdParam == 0)
            {
                Response.Redirect("DriverManagement.aspx");
                return;
            }

            if (!IsPostBack)
            {
                BindVehicleTypes();
                LoadDriver();
            }
            else
            {
                // A failed save comes straight back as a postback, so the identity card has to
                // be filled again or the avatar and name would come back blank.
                BindIdentityCard();
                BindStoredDocuments();
            }
        }

        /// <summary>
        /// The identity card at the top of the page: stored photo or initials, plus the name
        /// and email the driver currently has on record.
        /// </summary>
        private void BindIdentityCard()
        {
            DataTable t = Helper.DBHelper.ExecuteQuery(
                "SELECT FullName, Email, ProfilePhotoUrl FROM Drivers WHERE DriverID=@id",
                new SqlParameter("@id", DriverIdParam));
            if (t.Rows.Count == 0) return;

            DataRow r = t.Rows[0];
            lblCardName.InnerText = Enc(r["FullName"]);
            lblCardEmail.InnerText = Enc(r["Email"]);
            lblCardId.Text = DriverIdParam.ToString("N0");

            string photo = Helper.TripHelper.DriverPhotoUrl(r["ProfilePhotoUrl"]);
            imgDriverPhoto.Visible = photo.Length > 0;
            imgDefaultPhoto.Visible = photo.Length == 0;
            if (photo.Length > 0) imgDriverPhoto.ImageUrl = ResolveUrl("~/" + photo);
        }

        private static string Enc(object value)
        {
            if (value == null || value == DBNull.Value) return "";
            return System.Web.HttpUtility.HtmlEncode(value.ToString());
        }

        private void LoadDriver()
        {
            DataTable t = Helper.DBHelper.ExecuteQuery(
                @"SELECT FullName, Email, PhoneNumber, PaymentAccount, NRCNumber, LicenseNumber,
                         VehicleTypeID, VehiclePlateNumber, SeatCapacity
                    FROM Drivers WHERE DriverID=@id",
                new SqlParameter("@id", DriverIdParam));
            if (t.Rows.Count == 0)
            {
                Response.Redirect("DriverManagement.aspx");
                return;
            }

            DataRow r = t.Rows[0];
            txtFullName.Text = r["FullName"].ToString();
            txtEmail.Text = r["Email"].ToString();
            txtPhone.Text = r["PhoneNumber"].ToString();
            txtNrc.Text = r["NRCNumber"].ToString();
            txtLicenseNumber.Text = r["LicenseNumber"].ToString();
            txtPlateNumber.Text = r["VehiclePlateNumber"].ToString();
            txtSeatCapacity.Text = r["SeatCapacity"].ToString();
            txtPaymentAccount.Text = r["PaymentAccount"] == DBNull.Value ? "" : r["PaymentAccount"].ToString();

            if (ddlVehicleType.Items.FindByValue(r["VehicleTypeID"].ToString()) != null)
                ddlVehicleType.SelectedValue = r["VehicleTypeID"].ToString();

            BindIdentityCard();
            BindStoredDocuments();
        }

        /// <summary>
        /// Draws the documents already on file into the four slots, so the admin can see what
        /// is stored before deciding to replace it. A slot with nothing on file stays hidden.
        /// </summary>
        private void BindStoredDocuments()
        {
            DataTable t = Helper.DBHelper.ExecuteQuery(
                @"SELECT NRCPhotoUrl, LicensePhotoUrl, VehiclePhotoUrl, VehicleRegDocUrl
                    FROM Drivers WHERE DriverID=@id",
                new SqlParameter("@id", DriverIdParam));
            if (t.Rows.Count == 0) return;

            DataRow r = t.Rows[0];
            ShowStored(kycTileNrc, kycCoverNrc, imgNrcDoc, kycFallbackNrc, r["NRCPhotoUrl"]);
            ShowStored(kycTileLicense, kycCoverLicense, imgLicenseDoc, kycFallbackLicense, r["LicensePhotoUrl"]);
            ShowStored(kycTileVehicle, kycCoverVehicle, imgVehicleDoc, kycFallbackVehicle, r["VehiclePhotoUrl"]);
            ShowStored(kycTileReg, kycCoverReg, imgRegDoc, kycFallbackReg, r["VehicleRegDocUrl"]);
        }

        private void ShowStored(System.Web.UI.HtmlControls.HtmlGenericControl tile,
            System.Web.UI.HtmlControls.HtmlGenericControl cover,
            System.Web.UI.WebControls.Image img,
            System.Web.UI.HtmlControls.HtmlGenericControl fallback, object storedPath)
        {
            string path = Helper.TripHelper.HotelPhotoUrl(storedPath);
            bool has = path.Length > 0;
            tile.Visible = has;

            // The cover carries the flag the shared script reads, so a slot holding a document
            // keeps its tile even after a newly picked file is cleared away again.
            cover.Attributes["data-tw-has-doc"] = has ? "1" : "0";

            bool isPhoto = has && !path.EndsWith(".pdf", StringComparison.OrdinalIgnoreCase);
            img.Visible = isPhoto;
            fallback.Style["display"] = has && !isPhoto ? "flex" : "none";
            if (isPhoto) img.ImageUrl = ResolveUrl("~/" + path);
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            string email = txtEmail.Text.Trim();
            if (EmailTakenByOther(email, DriverIdParam))
            {
                ShowMessage("Another account already uses this email address.");
                return;
            }

            int seatCapacity;
            if (!int.TryParse(txtSeatCapacity.Text.Trim(), out seatCapacity) || seatCapacity < 1)
            {
                ShowMessage("Enter a seat capacity of at least 1.");
                return;
            }

            int vehicleTypeId;
            if (!int.TryParse(ddlVehicleType.SelectedValue, out vehicleTypeId) || vehicleTypeId <= 0)
            {
                ShowMessage("Choose a vehicle type.");
                return;
            }

            // The KYC columns are NOT NULL, so a replacement upload is written straight over
            // the current one and an empty upload leaves the stored path untouched.
            var old = CurrentDocuments();

            // The avatar follows the same rule: an empty picker keeps the stored photo.
            string profilePhoto = old.ProfilePhoto ?? "";
            if (fuProfilePhoto.HasFile)
            {
                string savedPhoto = Helper.TripHelper.StoreImage(fuProfilePhoto.PostedFile,
                    Helper.TripHelper.DriverPhotoFolder, "Profile_" + DriverIdParam);
                if (savedPhoto == null)
                {
                    ShowMessage("Profile photo must be a JPG or PNG image under "
                        + (Helper.TripHelper.MaxImageBytes / (1024 * 1024)) + " MB.");
                    return;
                }
                profilePhoto = savedPhoto;
            }

            string nrcPhoto, licensePhoto, vehiclePhoto, regDoc;
            if (!TryReplace(fuNrcPhoto, "NRCPhotos", "NRC", old.NrcPhoto, out nrcPhoto)
                || !TryReplace(fuLicensePhoto, "LicensePhotos", "License", old.LicensePhoto, out licensePhoto)
                || !TryReplace(fuVehiclePhoto, "VehiclePhotos", "Vehicle", old.VehiclePhoto, out vehiclePhoto)
                || !TryReplace(fuRegDoc, "RegDocs", "RegDoc", old.RegDoc, out regDoc))
            {
                ShowMessage("That file was not accepted. Use a JPG, PNG or PDF under "
                    + (Helper.TripHelper.MaxImageBytes / (1024 * 1024)) + " MB.");
                return;
            }

            Helper.DBHelper.ExecuteNonQuery(
                @"UPDATE Drivers SET FullName=@Name, Email=@Email, PhoneNumber=@Phone,
                          NRCNumber=@Nrc, NRCPhotoUrl=@NrcPhoto,
                          LicenseNumber=@License, LicensePhotoUrl=@LicensePhoto,
                          VehicleTypeID=@VehType, VehiclePlateNumber=@Plate,
                          VehiclePhotoUrl=@VehPhoto, VehicleRegDocUrl=@RegDoc,
                          SeatCapacity=@Seats, PaymentAccount=@PayAcc,
                          ProfilePhotoUrl=@Photo
                    WHERE DriverID=@id",
                new SqlParameter("@Name", txtFullName.Text.Trim()),
                new SqlParameter("@Email", email),
                new SqlParameter("@Phone", txtPhone.Text.Trim()),
                new SqlParameter("@Nrc", txtNrc.Text.Trim()),
                new SqlParameter("@NrcPhoto", nrcPhoto),
                new SqlParameter("@License", txtLicenseNumber.Text.Trim()),
                new SqlParameter("@LicensePhoto", licensePhoto),
                new SqlParameter("@VehType", vehicleTypeId),
                new SqlParameter("@Plate", txtPlateNumber.Text.Trim()),
                new SqlParameter("@VehPhoto", vehiclePhoto),
                new SqlParameter("@RegDoc", regDoc),
                new SqlParameter("@Seats", seatCapacity),
                new SqlParameter("@PayAcc", BlankAsDbNull(txtPaymentAccount.Text)),
                new SqlParameter("@Photo", BlankAsDbNull(profilePhoto)),
                new SqlParameter("@id", DriverIdParam));

            Helper.TripHelper.LogActivity("DriverUpdated", null, "Admin updated driver " + DriverIdParam + ".");

            // Only now that the row points at the new files is it safe to drop the old ones.
            DeleteSuperseded(nrcPhoto, old.NrcPhoto, "Uploads/NRCPhotos");
            DeleteSuperseded(licensePhoto, old.LicensePhoto, "Uploads/LicensePhotos");
            DeleteSuperseded(vehiclePhoto, old.VehiclePhoto, "Uploads/VehiclePhotos");
            DeleteSuperseded(regDoc, old.RegDoc, "Uploads/RegDocs");
            DeleteSuperseded(profilePhoto, old.ProfilePhoto, Helper.TripHelper.DriverPhotoFolder);

            Response.Redirect("DriverDetail.aspx?id=" + DriverIdParam);
        }

        /// <summary>
        /// Drops the previous file, but only when this save actually replaced it, so an
        /// untouched document is never deleted out from under the row.
        /// </summary>
        private static void DeleteSuperseded(string newPath, string oldPath, string folder)
        {
            if (string.IsNullOrWhiteSpace(oldPath)) return;
            if (string.Equals(newPath, oldPath, StringComparison.OrdinalIgnoreCase)) return;
            Helper.TripHelper.DeleteStoredPhoto(oldPath.TrimStart('~', '/'), folder);
        }

        private class Documents
        {
            public string NrcPhoto;
            public string LicensePhoto;
            public string VehiclePhoto;
            public string RegDoc;
            public string ProfilePhoto;
        }

        private Documents CurrentDocuments()
        {
            DataTable t = Helper.DBHelper.ExecuteQuery(
                "SELECT NRCPhotoUrl, LicensePhotoUrl, VehiclePhotoUrl, VehicleRegDocUrl, ProfilePhotoUrl FROM Drivers WHERE DriverID=@id",
                new SqlParameter("@id", DriverIdParam));
            var docs = new Documents();
            if (t.Rows.Count == 0) return docs;
            DataRow r = t.Rows[0];
            docs.NrcPhoto = r["NRCPhotoUrl"].ToString();
            docs.LicensePhoto = r["LicensePhotoUrl"].ToString();
            docs.VehiclePhoto = r["VehiclePhotoUrl"].ToString();
            docs.RegDoc = r["VehicleRegDocUrl"].ToString();
            docs.ProfilePhoto = r["ProfilePhotoUrl"] == DBNull.Value ? "" : r["ProfilePhotoUrl"].ToString();
            return docs;
        }

        private void BindVehicleTypes()
        {
            DataTable dt = Helper.DBHelper.ExecuteQuery(
                "SELECT VehicleTypeID, Name + ' (' + CAST(MinSeatCapacity AS NVARCHAR) + '-' + CAST(MaxSeatCapacity AS NVARCHAR) + ' pax)' AS Label FROM VehicleTypes ORDER BY VehicleTypeID");
            ddlVehicleType.DataSource = dt;
            ddlVehicleType.DataTextField = "Label";
            ddlVehicleType.DataValueField = "VehicleTypeID";
            ddlVehicleType.DataBind();
            ddlVehicleType.Items.Insert(0, new System.Web.UI.WebControls.ListItem("-- Select --", ""));
        }

        /// <summary>
        /// Email is unique per table, but the same address could exist as a customer or an
        /// admin, which would break sign-in, so all three are checked.
        /// </summary>
        private static bool EmailTakenByOther(string email, int driverId)
        {
            int count = Convert.ToInt32(Helper.DBHelper.ExecuteScalar(
                "SELECT COUNT(*) FROM Drivers WHERE Email = @e AND DriverID <> @id",
                new SqlParameter("@e", email), new SqlParameter("@id", driverId)));
            count += Convert.ToInt32(Helper.DBHelper.ExecuteScalar(
                "SELECT COUNT(*) FROM Customers WHERE Email = @e", new SqlParameter("@e", email)));
            count += Convert.ToInt32(Helper.DBHelper.ExecuteScalar(
                "SELECT COUNT(*) FROM Admins WHERE Email = @e", new SqlParameter("@e", email)));
            return count > 0;
        }

        /// <summary>
        /// Decides what should be stored for one KYC document: the newly uploaded file when
        /// there is one, otherwise the path already on the row. Returns false when a file was
        /// chosen but had to be refused, so the admin is told instead of the upload being
        /// silently dropped.
        /// </summary>
        private bool TryReplace(System.Web.UI.WebControls.FileUpload fu, string folder, string prefix,
            string currentPath, out string storedPath)
        {
            storedPath = currentPath ?? "";
            if (!fu.HasFile) return true;

            // The three photos go through the shared uploader, so they get the same
            // jpg/jpeg/png whitelist and size cap as every other photo on the site.
            string saved = Helper.TripHelper.StoreImage(fu.PostedFile, "Uploads/" + folder, prefix + "_" + DriverIdParam);
            if (saved == null && folder == "RegDocs")
            {
                // The registration document is the one KYC file that is allowed to be a PDF
                // rather than a photo, so it is stored here instead of through StoreImage.
                // The extension is still an explicit allowlist: anything else (.aspx,
                // .config, .exe ...) would land inside the web application and be servable.
                saved = StoreDocument(fu, folder, prefix + "_" + DriverIdParam);
            }
            if (saved == null) return false;

            storedPath = saved;
            return true;
        }

        private static readonly string[] DocumentExtensions = { ".pdf", ".jpg", ".jpeg", ".png" };

        private string StoreDocument(System.Web.UI.WebControls.FileUpload fu, string folder, string prefix)
        {
            string ext = Path.GetExtension(fu.FileName ?? "").ToLowerInvariant();
            if (Array.IndexOf(DocumentExtensions, ext) < 0) return null;
            if (fu.PostedFile.ContentLength <= 0 || fu.PostedFile.ContentLength > Helper.TripHelper.MaxImageBytes) return null;

            string dir = Server.MapPath("~/Uploads/" + folder);
            if (!Directory.Exists(dir)) Directory.CreateDirectory(dir);

            string fileName = prefix + "_" + DateTime.Now.Ticks + ext;
            fu.PostedFile.SaveAs(Path.Combine(dir, fileName));
            return "Uploads/" + folder + "/" + fileName;
        }

        private static object BlankAsDbNull(string value)
        {
            string text = (value ?? "").Trim();
            return text.Length == 0 ? (object)DBNull.Value : text;
        }

        private void ShowMessage(string text)
        {
            lblMessage.Text = text;
            pnlMessage.Visible = true;
        }
    }
}
