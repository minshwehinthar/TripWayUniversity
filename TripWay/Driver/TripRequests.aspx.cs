using System;
using System.Data;
using System.Data.SqlClient;

namespace TripWay.Driver
{
    public partial class TripRequestsPage : Helper.ListPageBase
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            Helper.AuthHelper.RequireDriver(this);

            DataRow me = Helper.DBHelper.ExecuteQuery(
                "SELECT KYCStatus FROM Drivers WHERE DriverID=@id",
                new SqlParameter("@id", Helper.AuthHelper.GetAccountId())).Rows[0];
            string kyc = me["KYCStatus"].ToString();
            if (kyc != "Approved")
            {
                pnlKycBanner.Visible = true;
                lblKycState.Text = kyc;
            }

            object busy = Helper.DBHelper.ExecuteScalar(
                "SELECT COUNT(*) FROM Trips WHERE DriverID=@id AND Status IN ('Accepted','Arrived','Started')",
                new SqlParameter("@id", Helper.AuthHelper.GetAccountId()));
            pnlBusy.Visible = Convert.ToInt32(busy) > 0 && kyc == "Approved";
        }
    }
}