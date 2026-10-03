using System.Web;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;

namespace TripWay.Helper
{
    /// <summary>
    /// What a list shows when it has nothing in it.
    ///
    /// A Repeater renders no markup at all for an empty DataSource: no rows, and nothing in the
    /// gap where the rows would have been, because a Repeater has no empty template the way a
    /// GridView has. The page therefore just looked unfinished - a heading, a card, and then
    /// white space, with nothing to say whether the search found nothing, the account has no
    /// trips yet, or the page is simply broken.
    ///
    /// There are two shapes of empty state and they live here together so the wording and the
    /// spacing are decided once:
    ///
    ///   TableRow - for a list that is a table. The caller puts a hidden
    ///              &lt;tr id="trNoData"&gt; in the Repeater's FooterTemplate with a &lt;td&gt;
    ///              whose colspan is the table's column count, and this only reveals it.
    ///
    ///   Block    - for a list that is a set of cards or a grid rather than a table, where a
    ///              table row has nothing to span. The caller puts a hidden Panel holding a
    ///              Literal named "litEmpty" in the markup, and this reveals it and sets the
    ///              message.
    ///
    /// The message is passed in by the caller because only the caller knows what the list is
    /// for: "You have not booked any trips yet" and "No photos have been added to this package"
    /// are more use to whoever is looking at the page than one shared "No data available".
    /// </summary>
    public static class EmptyState
    {
        /// <summary>
        /// Reveals the FooterTemplate row named trNoData. Safe to call when the Repeater has no
        /// footer or no such row, so a page that has not been given one yet still binds.
        /// </summary>
        public static void TableRow(Repeater rpt, bool showEmpty)
        {
            if (rpt == null || rpt.Controls.Count == 0) return;
            var item = rpt.Controls[rpt.Controls.Count - 1] as RepeaterItem;
            if (item == null || item.ItemType != ListItemType.Footer) return;
            var tr = item.FindControl("trNoData") as HtmlGenericControl;
            if (tr != null) tr.Visible = showEmpty;
        }

        /// <summary>
        /// Reveals the Panel, and writes the message into the Literal named litEmpty inside it.
        /// </summary>
        public static void Block(Panel target, bool showEmpty, string message)
        {
            if (target == null) return;
            target.Visible = showEmpty;
            if (!showEmpty) return;
            var lit = target.FindControl("litEmpty") as Literal;
            if (lit != null) lit.Text = HttpUtility.HtmlEncode(message ?? "");
        }
    }
}
