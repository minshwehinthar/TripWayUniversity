namespace TripWay.Admin
{
    public partial class CreateDriverPage
    {
        protected global::System.Web.UI.WebControls.Panel pnlMessage;
        protected global::System.Web.UI.WebControls.Label lblMessage;
        protected global::System.Web.UI.WebControls.TextBox txtFullName;
        protected global::System.Web.UI.WebControls.RequiredFieldValidator rfvFullName;
        protected global::System.Web.UI.WebControls.TextBox txtEmail;
        protected global::System.Web.UI.WebControls.RequiredFieldValidator rfvEmail;
        protected global::System.Web.UI.WebControls.RegularExpressionValidator revEmail;
        protected global::System.Web.UI.WebControls.TextBox txtPassword;
        protected global::System.Web.UI.WebControls.RequiredFieldValidator rfvPassword;
        protected global::System.Web.UI.WebControls.RegularExpressionValidator revPassword;
        protected global::System.Web.UI.WebControls.TextBox txtConfirmPassword;
        protected global::System.Web.UI.WebControls.CompareValidator cvPassword;
        protected global::System.Web.UI.WebControls.TextBox txtPhone;
        protected global::System.Web.UI.WebControls.RequiredFieldValidator rfvPhone;
        protected global::System.Web.UI.WebControls.TextBox txtNrc;
        protected global::System.Web.UI.WebControls.RequiredFieldValidator rfvNrc;
        protected global::System.Web.UI.WebControls.FileUpload fuNrcPhoto;
        protected global::System.Web.UI.WebControls.RequiredFieldValidator rfvNrcPhoto;
        protected global::System.Web.UI.WebControls.TextBox txtLicenseNumber;
        protected global::System.Web.UI.WebControls.RequiredFieldValidator rfvLicenseNumber;
        protected global::System.Web.UI.WebControls.FileUpload fuLicensePhoto;
        protected global::System.Web.UI.WebControls.RequiredFieldValidator rfvLicensePhoto;
        protected global::System.Web.UI.WebControls.DropDownList ddlVehicleType;
        protected global::System.Web.UI.WebControls.RequiredFieldValidator rfvVehicleType;
        protected global::System.Web.UI.WebControls.TextBox txtPlateNumber;
        protected global::System.Web.UI.WebControls.RequiredFieldValidator rfvPlateNumber;
        protected global::System.Web.UI.WebControls.FileUpload fuVehiclePhoto;
        protected global::System.Web.UI.WebControls.RequiredFieldValidator rfvVehiclePhoto;
        protected global::System.Web.UI.WebControls.FileUpload fuRegDoc;
        protected global::System.Web.UI.WebControls.RequiredFieldValidator rfvRegDoc;
        protected global::System.Web.UI.WebControls.TextBox txtSeatCapacity;
        protected global::System.Web.UI.WebControls.TextBox txtPaymentAccount;
        protected global::System.Web.UI.WebControls.FileUpload fuProfilePhoto;
        protected global::System.Web.UI.WebControls.Button btnCreate;
    }
}