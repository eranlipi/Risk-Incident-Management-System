using System;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;

/// <summary>
/// User Control for filtering incidents
/// </summary>
public partial class Controls_FilterPanel : System.Web.UI.UserControl
{
    private DatabaseHelper _db;

    // Event that fires when search button is clicked
    public event EventHandler SearchClicked;

    // Event that fires when clear button is clicked
    public event EventHandler ClearClicked;

    // Event that fires when any filter changes (for auto-search)
    public event EventHandler FilterChanged;

    protected void Page_Load(object sender, EventArgs e)
    {
        _db = new DatabaseHelper();

        if (!IsPostBack)
        {
            LoadFilterData();
        }
        else
        {
            // Check if the postback was triggered by the keyword textbox
            string eventTarget = Request.Form["__EVENTTARGET"];
            if (!string.IsNullOrEmpty(eventTarget) && eventTarget.Contains("txtKeyword"))
            {
                // Trigger auto-search when keyword textbox changes
                TriggerAutoSearch();
            }
        }
    }

    /// <summary>
    /// Loads dropdown list data from database
    /// </summary>
    private void LoadFilterData()
    {
        try
        {
            // Load Departments
            DataTable departments = _db.GetDepartments();
            if (ddlDepartment != null)
            {
                ddlDepartment.DataSource = departments;
                ddlDepartment.DataTextField = "DepartmentName";
                ddlDepartment.DataValueField = "DepartmentID";
                ddlDepartment.DataBind();
                ddlDepartment.Items.Insert(0, new ListItem("All Departments", ""));
            }

            // Load Locations
            DataTable locations = _db.GetLocations();
            if (ddlLocation != null)
            {
                ddlLocation.DataSource = locations;
                ddlLocation.DataTextField = "LocationName";
                ddlLocation.DataValueField = "LocationID";
                ddlLocation.DataBind();
                ddlLocation.Items.Insert(0, new ListItem("All Locations", ""));
            }

            // Load Categories
            DataTable categories = _db.GetCategories();
            if (ddlCategory != null)
            {
                ddlCategory.DataSource = categories;
                ddlCategory.DataTextField = "CategoryName";
                ddlCategory.DataValueField = "CategoryID";
                ddlCategory.DataBind();
                ddlCategory.Items.Insert(0, new ListItem("All Categories", ""));
            }
        }
        catch (Exception ex)
        {
            Logger.LogError("FilterPanel.LoadFilterData", ex);
            // Show error message to user
        }
    }

    /// <summary>
    /// Search button click handler
    /// </summary>
    protected void btnSearch_Click(object sender, EventArgs e)
    {
        // Raise the SearchClicked event
        if (SearchClicked != null)
        {
            SearchClicked.Invoke(this, EventArgs.Empty);
        }
    }

    /// <summary>
    /// Clear button click handler
    /// </summary>
    protected void btnClear_Click(object sender, EventArgs e)
    {
        ClearFilters();

        // Raise the ClearClicked event
        if (ClearClicked != null)
        {
            ClearClicked.Invoke(this, EventArgs.Empty);
        }
    }

    /// <summary>
    /// Date range dropdown change handler
    /// </summary>
    protected void ddlDateRange_SelectedIndexChanged(object sender, EventArgs e)
    {
        if (pnlCustomDateRange != null && ddlDateRange != null)
        {
            pnlCustomDateRange.Visible = (ddlDateRange.SelectedValue == "custom");
        }

        // Trigger auto-search when date range changes
        TriggerAutoSearch();
    }

    /// <summary>
    /// Department dropdown change handler
    /// </summary>
    protected void ddlDepartment_SelectedIndexChanged(object sender, EventArgs e)
    {
        TriggerAutoSearch();
    }

    /// <summary>
    /// Location dropdown change handler
    /// </summary>
    protected void ddlLocation_SelectedIndexChanged(object sender, EventArgs e)
    {
        TriggerAutoSearch();
    }

    /// <summary>
    /// Category dropdown change handler
    /// </summary>
    protected void ddlCategory_SelectedIndexChanged(object sender, EventArgs e)
    {
        TriggerAutoSearch();
    }

    /// <summary>
    /// Severity dropdown change handler
    /// </summary>
    protected void ddlSeverity_SelectedIndexChanged(object sender, EventArgs e)
    {
        TriggerAutoSearch();
    }

    /// <summary>
    /// Status dropdown change handler
    /// </summary>
    protected void ddlStatus_SelectedIndexChanged(object sender, EventArgs e)
    {
        TriggerAutoSearch();
    }

    /// <summary>
    /// Custom date textboxes change handler
    /// </summary>
    protected void txtCustomDate_TextChanged(object sender, EventArgs e)
    {
        TriggerAutoSearch();
    }

    /// <summary>
    /// Triggers auto-search by raising the FilterChanged event
    /// </summary>
    private void TriggerAutoSearch()
    {
        if (FilterChanged != null)
        {
            FilterChanged.Invoke(this, EventArgs.Empty);
        }
    }

    /// <summary>
    /// Clears all filter selections
    /// </summary>
    public void ClearFilters()
    {
        if (txtKeyword != null) txtKeyword.Text = string.Empty;
        if (ddlDepartment != null) ddlDepartment.SelectedIndex = 0;
        if (ddlLocation != null) ddlLocation.SelectedIndex = 0;
        if (ddlCategory != null) ddlCategory.SelectedIndex = 0;
        if (ddlSeverity != null) ddlSeverity.SelectedIndex = 0;
        if (ddlStatus != null) ddlStatus.SelectedIndex = 0;
        if (ddlDateRange != null) ddlDateRange.SelectedIndex = 0;
        if (txtStartDate != null) txtStartDate.Text = string.Empty;
        if (txtEndDate != null) txtEndDate.Text = string.Empty;
        // if (pnlCustomDateRange != null) pnlCustomDateRange.Visible = false; // Managed by JS now
        // if (lblResultCount != null) lblResultCount.Visible = false; // Removed control
    }

    /// <summary>
    /// Sets the result count label
    /// </summary>
    public void SetResultCount(int count)
    {
        // Client-side filtering handles the count display now
        /*
        if (lblResultCount != null)
        {
            lblResultCount.Text = string.Format("{0} result{1}", count, (count != 1 ? "s" : ""));
            lblResultCount.Visible = true;
        }
        */
    }

    #region Properties for accessing filter values

    public string Keyword
    {
        get { return txtKeyword != null ? txtKeyword.Text.Trim() : string.Empty; }
        set { if (txtKeyword != null) txtKeyword.Text = value; }
    }

    public int? DepartmentId
    {
        get
        {
            if (ddlDepartment == null) return null;
            if (string.IsNullOrEmpty(ddlDepartment.SelectedValue)) return null;

            int result;
            if (int.TryParse(ddlDepartment.SelectedValue, out result))
                return result;

            return null;
        }
        set
        {
            if (ddlDepartment == null) return;
            if (value.HasValue)
                ddlDepartment.SelectedValue = value.Value.ToString();
            else
                ddlDepartment.SelectedIndex = 0;
        }
    }

    public int? LocationId
    {
        get
        {
            if (ddlLocation == null) return null;
            if (string.IsNullOrEmpty(ddlLocation.SelectedValue)) return null;

            int result;
            if (int.TryParse(ddlLocation.SelectedValue, out result))
                return result;

            return null;
        }
        set
        {
            if (ddlLocation == null) return;
            if (value.HasValue)
                ddlLocation.SelectedValue = value.Value.ToString();
            else
                ddlLocation.SelectedIndex = 0;
        }
    }

    public int? CategoryId
    {
        get
        {
            if (ddlCategory == null) return null;
            if (string.IsNullOrEmpty(ddlCategory.SelectedValue)) return null;

            int result;
            if (int.TryParse(ddlCategory.SelectedValue, out result))
                return result;

            return null;
        }
        set
        {
            if (ddlCategory == null) return;
            if (value.HasValue)
                ddlCategory.SelectedValue = value.Value.ToString();
            else
                ddlCategory.SelectedIndex = 0;
        }
    }

    public int? Severity
    {
        get
        {
            if (ddlSeverity == null) return null;
            if (string.IsNullOrEmpty(ddlSeverity.SelectedValue)) return null;

            int result;
            if (int.TryParse(ddlSeverity.SelectedValue, out result))
                return result;

            return null;
        }
        set
        {
            if (ddlSeverity == null) return;
            if (value.HasValue)
                ddlSeverity.SelectedValue = value.Value.ToString();
            else
                ddlSeverity.SelectedIndex = 0;
        }
    }

    public string Status
    {
        get { return ddlStatus != null ? ddlStatus.SelectedValue : string.Empty; }
        set { if (ddlStatus != null) ddlStatus.SelectedValue = value; }
    }

    public DateTime? StartDate
    {
        get
        {
            DateTime result;
            if (ddlDateRange != null && txtStartDate != null && ddlDateRange.SelectedValue == "custom" && DateTime.TryParse(txtStartDate.Text, out result))
                return result;

            return GetStartDateFromRange();
        }
    }

    public DateTime? EndDate
    {
        get
        {
            DateTime result;
            if (ddlDateRange != null && txtEndDate != null && ddlDateRange.SelectedValue == "custom" && DateTime.TryParse(txtEndDate.Text, out result))
                return result;

            return GetEndDateFromRange();
        }
    }

    /// <summary>
    /// Calculates start date based on date range selection
    /// </summary>
    private DateTime? GetStartDateFromRange()
    {
        if (ddlDateRange == null) return null;

        switch (ddlDateRange.SelectedValue)
        {
            case "today":
                return DateTime.Today;
            case "7days":
                return DateTime.Today.AddDays(-7);
            case "30days":
                return DateTime.Today.AddDays(-30);
            case "3months":
                return DateTime.Today.AddMonths(-3);
            case "6months":
                return DateTime.Today.AddMonths(-6);
            default:
                return null;
        }
    }

    /// <summary>
    /// Calculates end date based on date range selection
    /// </summary>
    private DateTime? GetEndDateFromRange()
    {
        if (ddlDateRange == null) return null;

        if (ddlDateRange.SelectedValue != "all")
            return DateTime.Now;

        return null;
    }

    #endregion
}
