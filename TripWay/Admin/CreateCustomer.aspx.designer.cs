namespace TripWay.Admin
{
    public partial class CreateCustomerPage
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
        protected global::System.Web.UI.WebControls.DropDownList ddlGender;
        protected global::System.Web.UI.WebControls.FileUpload fuProfilePhoto;
        protected global::System.Web.UI.WebControls.TextBox txtDefaultAddress;
        protected global::System.Web.UI.WebControls.Button btnCreate;
    }
}