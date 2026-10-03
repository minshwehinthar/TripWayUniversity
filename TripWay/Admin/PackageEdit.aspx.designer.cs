namespace TripWay.Admin
{
    public partial class PackageEditPage
    {
        protected global::System.Web.UI.WebControls.Panel pnlMessage;
        protected global::System.Web.UI.WebControls.Label lblMessage;
        protected global::System.Web.UI.WebControls.TextBox txtName;
        protected global::System.Web.UI.WebControls.RequiredFieldValidator rfvName;
        protected global::System.Web.UI.WebControls.TextBox txtDurationDays;
        protected global::System.Web.UI.WebControls.RequiredFieldValidator rfvDays;
        protected global::System.Web.UI.WebControls.TextBox txtFixedPrice;
        protected global::System.Web.UI.WebControls.RequiredFieldValidator rfvPrice;
        protected global::System.Web.UI.WebControls.CheckBox chkActive;
        protected global::System.Web.UI.WebControls.Repeater rptPlaces;
        protected global::System.Web.UI.WebControls.Literal litStopCount;
        protected global::System.Web.UI.WebControls.Literal litPickHint;
        protected global::System.Web.UI.WebControls.HiddenField hfStops;
        protected global::System.Web.UI.WebControls.Panel pnlCover;
        protected global::System.Web.UI.WebControls.Image imgCover;
        protected global::System.Web.UI.WebControls.Panel pnlCoverNone;
        protected global::System.Web.UI.WebControls.FileUpload fuCover;
        protected global::System.Web.UI.WebControls.CheckBox chkRemoveCover;
        protected global::System.Web.UI.WebControls.Button btnSave;
    }
}