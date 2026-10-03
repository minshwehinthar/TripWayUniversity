using System;

namespace TripWay
{
    public partial class ContactUsPage : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
        }

        protected void btnSend_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            Helper.TripHelper.LogActivity("ContactMessage", null,
                string.Format("Contact form: {0} ({1}) — {2}: {3}",
                    txtName.Text.Trim(), txtEmail.Text.Trim(), txtSubject.Text.Trim(), txtMessage.Text.Trim()));

            txtName.Text = "";
            txtEmail.Text = "";
            txtSubject.Text = "";
            txtMessage.Text = "";
            pnlSuccess.Visible = true;
        }
    }
}