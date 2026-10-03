using System;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Web;

namespace TripWay
{
    public partial class RegisterPage : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Helper.AuthHelper.IsLoggedIn())
            {
                Helper.AuthHelper.RedirectByRole(this);
            }

            if (!IsPostBack)
            {
                BindVehicleTypes();
            }

            UpdatePanels();
        }

        private void UpdatePanels()
        {
            bool isDriver = ddlRole.SelectedValue == "Driver";
            pnlCustomer.Visible = !isDriver;
            pnlDriver.Visible = isDriver;
        }

        protected void ddlRole_SelectedIndexChanged(object sender, EventArgs e)
        {
            bool isDriver = ddlRole.SelectedValue == "Driver";
            pnlCustomer.Visible = !isDriver;
            pnlDriver.Visible = isDriver;

            // Enable / disable required validators per role.
            SetValidators(!isDriver);
        }

        private void SetValidators(bool customer)
        {
            rfvFullName.Enabled = customer;
            rfvEmail.Enabled = customer;
            revEmail.Enabled = customer;
            rfvPassword.Enabled = customer;
            revPassword.Enabled = customer;
            rfvPhone.Enabled = customer;

            rfvDriverName.Enabled = !customer;
            rfvDriverEmail.Enabled = !customer;
            revDriverEmail.Enabled = !customer;
            rfvDriverPassword.Enabled = !customer;
            revDriverPassword.Enabled = !customer;
            rfvDriverPhone.Enabled = !customer;
            rfvNrc.Enabled = !customer;
            rfvNrcPhoto.Enabled = !customer;
            rfvLicenseNumber.Enabled = !customer;
            rfvLicensePhoto.Enabled = !customer;
            rfvVehicleType.Enabled = !customer;
            rfvPlateNumber.Enabled = !customer;
            rfvVehiclePhoto.Enabled = !customer;
            rfvRegDoc.Enabled = !customer;
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
            // suggested capacity travels with the option instead of costing a postback that
            // would clear the files already picked on this form.
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

        protected void btnRegister_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            if (ddlRole.SelectedValue == "Driver")
            {
                RegisterDriver();
            }
            else
            {
                RegisterCustomer();
            }
        }

        private void RegisterCustomer()
        {
            string email = txtEmail.Text.Trim();
            if (EmailExists(email))
            {
                ShowMessage("This email is already registered.", true);
                return;
            }

            string photoUrl = "";
            if (fuProfilePhoto.HasFile)
            {
                photoUrl = SaveUpload(fuProfilePhoto, "ProfilePhotos", "Profile");
            }

            Helper.DBHelper.ExecuteNonQuery(
                "INSERT INTO Customers (FullName, Email, PasswordHash, PhoneNumber, ProfilePhotoUrl, Gender, DefaultAddress, Status) " +
                "VALUES (@Name, @Email, @Hash, @Phone, @Photo, @Gender, @Address, 'Active')",
                new SqlParameter("@Name", txtFullName.Text.Trim()),
                new SqlParameter("@Email", email),
                new SqlParameter("@Hash", Helper.AuthHelper.HashPassword(txtPassword.Text)),
                new SqlParameter("@Phone", txtPhone.Text.Trim()),
                new SqlParameter("@Photo", (object)photoUrl ?? DBNull.Value),
                new SqlParameter("@Gender", (object)ddlGender.SelectedValue ?? DBNull.Value),
                new SqlParameter("@Address", (object)txtDefaultAddress.Text.Trim() ?? DBNull.Value));

            Helper.TripHelper.LogActivity("Registered", null, "New customer account: " + email);
            Response.Redirect("Login.aspx?registered=1");
        }

        private void RegisterDriver()
        {
            string email = txtDriverEmail.Text.Trim();
            if (EmailExists(email))
            {
                ShowMessage("This email is already registered.", true);
                return;
            }

            // Upload all KYC documents first.
            string nrcPhoto = SaveUpload(fuNrcPhoto, "NRCPhotos", "NRC");
            string licensePhoto = SaveUpload(fuLicensePhoto, "LicensePhotos", "License");
            string vehiclePhoto = SaveUpload(fuVehiclePhoto, "VehiclePhotos", "Vehicle");
            string regDoc = SaveUpload(fuRegDoc, "RegDocs", "RegDoc");

            if (nrcPhoto.Length == 0 || licensePhoto.Length == 0 || vehiclePhoto.Length == 0 || regDoc.Length == 0)
            {
                // A document can be missing because it was never chosen, or because it was
                // refused for its type or size, so both reasons are named here.
                bool anyChosen = fuNrcPhoto.HasFile || fuLicensePhoto.HasFile
                              || fuVehiclePhoto.HasFile || fuRegDoc.HasFile;
                ShowMessage(anyChosen
                    ? "Those files were not accepted. Use a JPG or PNG photo, or a PDF for the "
                      + "registration document, each under "
                      + (Helper.TripHelper.MaxImageBytes / (1024 * 1024)) + " MB."
                    : "All KYC documents (NRC, license, vehicle photo, registration) are required.",
                    true);
                return;
            }

            int seatCapacity;
            int.TryParse(txtSeatCapacity.Text.Trim(), out seatCapacity);

            Helper.DBHelper.ExecuteNonQuery(
                "INSERT INTO Drivers (FullName, Email, PasswordHash, PhoneNumber, NRCNumber, NRCPhotoUrl, LicenseNumber, LicensePhotoUrl, " +
                "VehicleTypeID, VehiclePlateNumber, VehiclePhotoUrl, VehicleRegDocUrl, SeatCapacity, PaymentAccount, KYCStatus) " +
                "VALUES (@Name, @Email, @Hash, @Phone, @Nrc, @NrcPhoto, @License, @LicensePhoto, @" +
                "VehType, @Plate, @VehPhoto, @RegDoc, @Seats, @PayAcc, 'Pending')",
                new SqlParameter("@Name", txtDriverName.Text.Trim()),
                new SqlParameter("@Email", email),
                new SqlParameter("@Hash", Helper.AuthHelper.HashPassword(txtDriverPassword.Text)),
                new SqlParameter("@Phone", txtDriverPhone.Text.Trim()),
                new SqlParameter("@Nrc", txtNrc.Text.Trim()),
                new SqlParameter("@NrcPhoto", nrcPhoto),
                new SqlParameter("@License", txtLicenseNumber.Text.Trim()),
                new SqlParameter("@LicensePhoto", licensePhoto),
                new SqlParameter("@VehType", int.Parse(ddlVehicleType.SelectedValue)),
                new SqlParameter("@Plate", txtPlateNumber.Text.Trim()),
                new SqlParameter("@VehPhoto", vehiclePhoto),
                new SqlParameter("@RegDoc", regDoc),
                new SqlParameter("@Seats", seatCapacity),
                new SqlParameter("@PayAcc", (object)txtPaymentAccount.Text.Trim() ?? DBNull.Value));

            Helper.TripHelper.LogActivity("DriverRegistered", null,
                "New driver account with KYC Pending: " + email + " (vehicle type " + ddlVehicleType.SelectedItem.Text + ")");
            Response.Redirect("Login.aspx?registered=1");
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

        /// <summary>
        /// Stores one uploaded file and returns its page-relative path, or "" when there was
        /// no file. The extension is checked against an allowlist rather than trusted, because
        /// this page is reachable without signing in: a ".aspx" saved into the Uploads folder
        /// would be picked up by IIS and run as code. The registration document is the one
        /// file allowed to be a PDF rather than a photo.
        /// </summary>
        private string SaveUpload(System.Web.UI.WebControls.FileUpload fu, string folder, string prefix)
        {
            if (!fu.HasFile) return "";

            string saved = Helper.TripHelper.StoreImage(fu.PostedFile, "Uploads/" + folder, prefix);
            if (saved == null && folder == "RegDocs")
                saved = SaveDocument(fu, folder, prefix);
            return saved ?? "";
        }

        private static readonly string[] DocumentExtensions = { ".pdf", ".jpg", ".jpeg", ".png" };

        private string SaveDocument(System.Web.UI.WebControls.FileUpload fu, string folder, string prefix)
        {
            string ext = System.IO.Path.GetExtension(fu.FileName ?? "").ToLowerInvariant();
            if (Array.IndexOf(DocumentExtensions, ext) < 0) return null;
            if (fu.PostedFile.ContentLength <= 0
                || fu.PostedFile.ContentLength > Helper.TripHelper.MaxImageBytes) return null;

            string dir = Server.MapPath("~/Uploads/" + folder);
            if (!System.IO.Directory.Exists(dir)) System.IO.Directory.CreateDirectory(dir);

            string fileName = prefix + "_" + System.DateTime.Now.Ticks + ext;
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