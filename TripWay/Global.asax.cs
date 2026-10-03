using System;

namespace TripWay
{
    public class Global : System.Web.HttpApplication
    {
        protected void Application_Start(object sender, EventArgs e)
        {
            Helper.DatabaseUpgrader.ApplyUpgrades();
        }
    }
}
