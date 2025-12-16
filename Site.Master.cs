using System;
using System.Web.UI;

/// <summary>
/// Master page code-behind
/// </summary>
public partial class SiteMaster : System.Web.UI.MasterPage
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            // Set active navigation menu item based on current page
            HighlightActiveMenuItem();
        }
    }

    /// <summary>
    /// Highlights the active menu item based on current page
    /// </summary>
    private void HighlightActiveMenuItem()
    {
        string currentPage = System.IO.Path.GetFileName(Request.Url.AbsolutePath).ToLower();

        // This would be enhanced to add 'active' class to navigation items
        // For now, this serves as a placeholder for future enhancement
    }

    /// <summary>
    /// Public property to display page-specific alerts/messages
    /// </summary>
    public string PageMessage
    {
        get { return ViewState["PageMessage"] as string; }
        set { ViewState["PageMessage"] = value; }
    }
}
