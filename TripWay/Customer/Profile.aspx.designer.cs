namespace TripWay.Customer
{
    public partial class ProfilePage
    {
        protected global::System.Web.UI.HtmlControls.HtmlGenericControl imgDefaultPhoto;
        protected global::System.Web.UI.WebControls.Image imgProfilePhoto;
        protected global::System.Web.UI.HtmlControls.HtmlGenericControl lblName;
        protected global::System.Web.UI.HtmlControls.HtmlGenericControl lblEmail;
        protected global::System.Web.UI.HtmlControls.HtmlGenericControl lblJoined;
        protected global::System.Web.UI.WebControls.Panel pnlProfileMsg;
        protected global::System.Web.UI.WebControls.Label lblProfileMsg;
        protected global::System.Web.UI.WebControls.FileUpload fuProfilePhoto;
        protected global::System.Web.UI.WebControls.TextBox txtEmail;
        protected global::System.Web.UI.WebControls.RegularExpressionValidator revEmail;
        protected global::System.Web.UI.WebControls.TextBox txtFullName;
        protected global::System.Web.UI.WebControls.RequiredFieldValidator rfvFullName;
        protected global::System.Web.UI.WebControls.TextBox txtPhone;
        protected global::System.Web.UI.WebControls.DropDownList ddlGender;
        protected global::System.Web.UI.WebControls.TextBox txtDefaultAddress;
        protected global::System.Web.UI.WebControls.Button btnSaveProfile;
        protected global::System.Web.UI.WebControls.Panel pnlPwdMsg;
        protected global::System.Web.UI.WebControls.Label lblPwdMsg;
        protected global::System.Web.UI.WebControls.TextBox txtCurrentPassword;
        protected global::System.Web.UI.WebControls.RequiredFieldValidator rfvCurrentPassword;
        protected global::System.Web.UI.WebControls.TextBox txtNewPassword;
        protected global::System.Web.UI.WebControls.RequiredFieldValidator rfvNewPassword;
        protected global::System.Web.UI.WebControls.RegularExpressionValidator revNewPassword;
        protected global::System.Web.UI.WebControls.TextBox txtConfirmPassword;
        protected global::System.Web.UI.WebControls.RequiredFieldValidator rfvConfirmPassword;
        protected global::System.Web.UI.WebControls.CompareValidator cmpConfirmPassword;
        protected global::System.Web.UI.WebControls.Button btnChangePassword;
    }
}