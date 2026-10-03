using System;
using System.Data;
using System.Data.SqlClient;

namespace TripWay.Admin
{
    public partial class CreateDriverPage : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            Helper.AuthHelper.RequireAdmin(this);
            if (!IsPostBack)
            {
                BindVehicleTypes();
            }
        }

        /// <summary>
        /// New drivers are created already approved, so the KYC status is a constant rather
        /// than a field the admin has to remember to set.
        /// </summary>
        private const string NewDriverStatus = "Approved";

        protected void btnCreate_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            string email = txtEmail.Text.Trim();
            if (EmailExists(email))
            {
                ShowMessage("This email is already registered.", true);
                return;
            }

            // The avatar is optional, but it is stored first: a rejected image returns before
            // any KYC file is written, so a failed attempt cannot leave files behind.
            string profilePhoto = "";
            if (fuProfilePhoto.HasFile)
            {
                profilePhoto = Helper.TripHelper.StoreImage(fuProfilePhoto.PostedFile,
                    Helper.TripHelper.DriverPhotoFolder, "Profile") ?? "";
                if (profilePhoto.Length == 0)
                {
                    ShowMessage("Profile photo must be a JPG or PNG image.", true);
                    return;
                }
            }

            string nrcPhoto = SaveUpload(fuNrcPhoto, "NRCPhotos", "NRC");
            string licensePhoto = SaveUpload(fuLicensePhoto, "LicensePhotos", "License");
            string vehiclePhoto = SaveUpload(fuVehiclePhoto, "VehiclePhotos", "Vehicle");
            string regDoc = SaveUpload(fuRegDoc, "RegDocs", "RegDoc");

            if (nrcPhoto.Length == 0 || licensePhoto.Length == 0 || vehiclePhoto.Length == 0 || regDoc.Length == 0)
            {
                ShowMessage("All KYC documents (NRC, license, vehicle photo, registration) are required.", true);
                return;
            }

            int seatCapacity;
            int.TryParse(txtSeatCapacity.Text.Trim(), out seatCapacity);

            Helper.DBHelper.ExecuteNonQuery(
                "INSERT INTO Drivers (FullName, Email, PasswordHash, PhoneNumber, NRCNumber, NRCPhotoUrl, LicenseNumber, LicensePhotoUrl, " +
                "VehicleTypeID, VehiclePlateNumber, VehiclePhotoUrl, VehicleRegDocUrl, SeatCapacity, PaymentAccount, ProfilePhotoUrl, KYCStatus) " +
                "VALUES (@Name, @Email, @Hash, @Phone, @Nrc, @NrcPhoto, @License, @LicensePhoto, @" +
                "VehType, @Plate, @VehPhoto, @RegDoc, @Seats, @PayAcc, @Photo, @Status)",
                new SqlParameter("@Name", txtFullName.Text.Trim()),
                new SqlParameter("@Email", email),
                new SqlParameter("@Hash", Helper.AuthHelper.HashPassword(txtPassword.Text)),
                new SqlParameter("@Phone", txtPhone.Text.Trim()),
                new SqlParameter("@Nrc", txtNrc.Text.Trim()),
                new SqlParameter("@NrcPhoto", nrcPhoto),
                new SqlParameter("@License", txtLicenseNumber.Text.Trim()),
                new SqlParameter("@LicensePhoto", licensePhoto),
                new SqlParameter("@VehType", int.Parse(ddlVehicleType.SelectedValue)),
                new SqlParameter("@Plate", txtPlateNumber.Text.Trim()),
                new SqlParameter("@VehPhoto", vehiclePhoto),
                new SqlParameter("@RegDoc", regDoc),
                new SqlParameter("@Seats", seatCapacity),
                new SqlParameter("@PayAcc", (object)txtPaymentAccount.Text.Trim() ?? DBNull.Value),
                new SqlParameter("@Photo", (object)profilePhoto ?? DBNull.Value),
                new SqlParameter("@Status", NewDriverStatus));

            Helper.TripHelper.LogActivity("DriverCreated", null,
                "Admin created driver account with KYC " + NewDriverStatus +
                (profilePhoto.Length > 0 ? " and a profile photo" : "") + ": " + email);
            Response.Redirect("~/Admin/DriverManagement.aspx");
        }

        private void BindVehicleTypes()
        {
            DataTable dt = Helper.DBHelper.ExecuteQuery(
                "SELECT VehicleTypeID, Name + ' (' + CAST(MinSeatCapacity AS NVARCHAR) + '-' + CAST(MaxSeatCapacity AS NVARCHAR) + ' pax)' AS Label, MaxSeatCapacity FROM VehicleTypes ORDER BY VehicleTypeID");
            ddlVehicleType.DataSource = dt;
            ddlVehicleType.DataTextField = "Label";
            ddlVehicleType.DataValueField = "VehicleTypeID";
            ddlVehicleType.DataBind();

            // The seat box is filled in by the page script when the type changes, so the
            // suggested capacity travels with the option instead of costing a postback.
            var seats = new System.Collections.Generic.Dictionary<string, string>();
            foreach (DataRow row in dt.Rows)
                seats[row["VehicleTypeID"].ToString()] = row["MaxSeatCapacity"].ToString();

            foreach (System.Web.UI.WebControls.ListItem item in ddlVehicleType.Items)
            {
                string max;
                if (seats.TryGetValue(item.Value, out max)) item.Attributes["data-max"] = max;
            }

            ddlVehicleType.Items.Insert(0, new System.Web.UI.WebControls.ListItem("-- Select --", ""));
        }

        private bool EmailExists(string email)
        {
            int count = 0;
            count += Convert.ToInt32(Helper.DBHelper.ExecuteScalar(
                "SELECT COUNT(*) FROM Customers WHERE Email = @e", new SqlParameter("@e", email)));
            count += Convert.ToInt32(Helper.DBHelper.ExecuteScalar(
                "SELECT COUNT(*) FROM Drivers WHERE Email = @e", new SqlParameter("@e", email)));
            count += Convert.ToInt32(Helper.DBHelper.ExecuteScalar(
                "SELECT COUNT(*) FROM Admins WHERE Email = @e", new SqlParameter("@e", email)));
            return count > 0;
        }

        private string SaveUpload(System.Web.UI.WebControls.FileUpload fu, string folder, string prefix)
        {
            if (!fu.HasFile) return "";

            // The three photos go through the shared uploader, so they get the same
            // jpg/jpeg/png whitelist and size cap as every other photo on the site.
            string saved = Helper.TripHelper.StoreImage(fu.PostedFile, "Uploads/" + folder, prefix);
            if (saved == null && folder == "RegDocs")
            {
                // The registration document is the one KYC file that is allowed to be a PDF
                // rather than a photo. The extension is still an explicit allowlist, because
                // anything else (.aspx, .config, .exe ...) would be written inside the web
                // application and then be servable.
                saved = SaveDocument(fu, folder, prefix);
            }
            return saved ?? "";
        }

        private static readonly string[] DocumentExtensions = { ".pdf", ".jpg", ".jpeg", ".png" };

        private string SaveDocument(System.Web.UI.WebControls.FileUpload fu, string folder, string prefix)
        {
            string ext = System.IO.Path.GetExtension(fu.FileName ?? "").ToLowerInvariant();
            if (Array.IndexOf(DocumentExtensions, ext) < 0) return null;
            if (fu.PostedFile.ContentLength <= 0 || fu.PostedFile.ContentLength > Helper.TripHelper.MaxImageBytes) return null;

            string dir = Server.MapPath("~/Uploads/" + folder);
            if (!System.IO.Directory.Exists(dir)) System.IO.Directory.CreateDirectory(dir);

            string fileName = prefix + "_" + DateTime.Now.Ticks + ext;
            fu.PostedFile.SaveAs(System.IO.Path.Combine(dir, fileName));
            return "Uploads/" + folder + "/" + fileName;
        }

        private void ShowMessage(string msg, bool isError)
        {
            pnlMessage.Visible = true;
            lblMessage.Text = msg;
            pnlMessage.CssClass = isError
                ? "mb-4 p-3 rounded-lg text-sm bg-red-100 text-red-700 border border-red-200"
                : "mb-4 p-3 rounded-lg text-sm bg-green-100 text-green-700 border border-green-200";
        }
    }
}