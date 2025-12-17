using System;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;

/// <summary>
/// Incident List page with GridView, filtering, and pagination
/// </summary>
public partial class Pages_IncidentList : System.Web.UI.Page
{
    private IncidentManager _incidentManager;
    private ReportGenerator _reportGenerator;

    protected void Page_Load(object sender, EventArgs e)
    {
        _incidentManager = new IncidentManager();
        _reportGenerator = new ReportGenerator();

        // Wire up filter panel events - remove first to prevent duplicates
        FilterPanel1.SearchClicked -= FilterPanel1_SearchClicked;
        FilterPanel1.SearchClicked += FilterPanel1_SearchClicked;

        FilterPanel1.ClearClicked -= FilterPanel1_ClearClicked;
        FilterPanel1.ClearClicked += FilterPanel1_ClearClicked;

        FilterPanel1.FilterChanged -= FilterPanel1_FilterChanged;
        FilterPanel1.FilterChanged += FilterPanel1_FilterChanged;

        if (!IsPostBack)
        {
            LoadIncidents();
        }
    }

    /// <summary>
    /// Loads incidents into the GridView
    /// </summary>
    private void LoadIncidents()
    {
        try
        {
            DataTable dtIncidents = _incidentManager.GetAllIncidents(
                pageNumber: gvIncidents.PageIndex + 1,
                pageSize: gvIncidents.PageSize,
                sortColumn: ViewState["SortColumn"] != null ? ViewState["SortColumn"].ToString() : "IncidentDate",
                sortDirection: ViewState["SortDirection"] != null ? ViewState["SortDirection"].ToString() : "DESC"
            );

            gvIncidents.DataSource = dtIncidents;
            gvIncidents.DataBind();

            // Update record count
            if (dtIncidents.Rows.Count > 0)
            {
                int totalRecords = Convert.ToInt32(dtIncidents.Rows[0]["TotalRecords"]);
                lblRecordCount.Text = string.Format("{0} total", totalRecords);
            }
            else
            {
                lblRecordCount.Text = "0 total";
            }
        }
        catch (Exception ex)
        {
            Logger.LogError("IncidentList.LoadIncidents", ex);
            ShowError("Error loading incidents. Please try again.");
        }
    }

    /// <summary>
    /// Searches incidents based on filter criteria
    /// </summary>
    private void SearchIncidents()
    {
        try
        {
            DataTable dtIncidents = _incidentManager.SearchIncidents(
                keyword: FilterPanel1.Keyword,
                departmentId: FilterPanel1.DepartmentId,
                locationId: FilterPanel1.LocationId,
                categoryId: FilterPanel1.CategoryId,
                severity: FilterPanel1.Severity,
                status: FilterPanel1.Status,
                startDate: FilterPanel1.StartDate,
                endDate: FilterPanel1.EndDate,
                pageNumber: gvIncidents.PageIndex + 1,
                pageSize: gvIncidents.PageSize
            );

            gvIncidents.DataSource = dtIncidents;
            gvIncidents.DataBind();

            // Update record count
            int totalRecords = dtIncidents.Rows.Count > 0
                ? Convert.ToInt32(dtIncidents.Rows[0]["TotalRecords"])
                : 0;

            lblRecordCount.Text = string.Format("{0} found", totalRecords);
            FilterPanel1.SetResultCount(totalRecords);
        }
        catch (Exception ex)
        {
            Logger.LogError("IncidentList.SearchIncidents", ex);
            ShowError("Error searching incidents. Please try again.");
        }
    }

    /// <summary>
    /// Filter panel search button clicked
    /// </summary>
    private void FilterPanel1_SearchClicked(object sender, EventArgs e)
    {
        // Reset to first page
        gvIncidents.PageIndex = 0;
        SearchIncidents();
    }

    /// <summary>
    /// Filter panel clear button clicked
    /// </summary>
    private void FilterPanel1_ClearClicked(object sender, EventArgs e)
    {
        // Reset to first page
        gvIncidents.PageIndex = 0;
        LoadIncidents();
    }

    /// <summary>
    /// Filter changed event handler (for auto-search)
    /// </summary>
    private void FilterPanel1_FilterChanged(object sender, EventArgs e)
    {
        // Reset to first page when any filter changes
        gvIncidents.PageIndex = 0;

        // Always perform search when filters change
        // The stored procedure will handle null/empty values appropriately
        SearchIncidents();
    }

    /// <summary>
    /// GridView page index changing event
    /// </summary>
    protected void gvIncidents_PageIndexChanging(object sender, GridViewPageEventArgs e)
    {
        gvIncidents.PageIndex = e.NewPageIndex;

        // Check if we're in filtered mode
        if (!string.IsNullOrEmpty(FilterPanel1.Keyword) ||
            FilterPanel1.DepartmentId.HasValue ||
            FilterPanel1.LocationId.HasValue ||
            FilterPanel1.CategoryId.HasValue ||
            FilterPanel1.Severity.HasValue ||
            !string.IsNullOrEmpty(FilterPanel1.Status))
        {
            SearchIncidents();
        }
        else
        {
            LoadIncidents();
        }
    }

    /// <summary>
    /// GridView sorting event
    /// </summary>
    protected void gvIncidents_Sorting(object sender, GridViewSortEventArgs e)
    {
        string currentSortColumn = ViewState["SortColumn"] != null ? ViewState["SortColumn"].ToString() : null;
        string currentSortDirection = ViewState["SortDirection"] != null ? ViewState["SortDirection"].ToString() : "ASC";

        // Toggle sort direction if same column
        if (currentSortColumn == e.SortExpression)
        {
            currentSortDirection = (currentSortDirection == "ASC") ? "DESC" : "ASC";
        }
        else
        {
            currentSortDirection = "ASC";
        }

        ViewState["SortColumn"] = e.SortExpression;
        ViewState["SortDirection"] = currentSortDirection;

        // Reset to first page
        gvIncidents.PageIndex = 0;

        // Check if we're in filtered mode
        if (!string.IsNullOrEmpty(FilterPanel1.Keyword) ||
            FilterPanel1.DepartmentId.HasValue ||
            FilterPanel1.LocationId.HasValue ||
            FilterPanel1.CategoryId.HasValue ||
            FilterPanel1.Severity.HasValue ||
            !string.IsNullOrEmpty(FilterPanel1.Status))
        {
            SearchIncidents();
        }
        else
        {
            LoadIncidents();
        }
    }

    /// <summary>
    /// GridView row command event
    /// </summary>
    protected void gvIncidents_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        if (e.CommandName == "DeleteIncident")
        {
            int incidentId = Convert.ToInt32(e.CommandArgument);

            try
            {
                bool success = _incidentManager.DeleteIncident(incidentId);

                if (success)
                {
                    ShowMessage(string.Format("Incident #{0} has been archived successfully.", incidentId));
                    LoadIncidents();
                }
                else
                {
                    ShowError("Failed to archive incident. Please try again.");
                }
            }
            catch (Exception ex)
            {
                Logger.LogError("IncidentList.DeleteIncident", ex);
                ShowError("Error archiving incident. Please try again.");
            }
        }
    }

    /// <summary>
    /// Export to Excel button click
    /// </summary>
    protected void btnExportExcel_Click(object sender, EventArgs e)
    {
        try
        {
            // Get current incidents (without pagination)
            DataTable dtIncidents;

            // Check if we're in filtered mode
            if (!string.IsNullOrEmpty(FilterPanel1.Keyword) ||
                FilterPanel1.DepartmentId.HasValue ||
                FilterPanel1.LocationId.HasValue ||
                FilterPanel1.CategoryId.HasValue ||
                FilterPanel1.Severity.HasValue ||
                !string.IsNullOrEmpty(FilterPanel1.Status))
            {
                dtIncidents = _incidentManager.SearchIncidents(
                    keyword: FilterPanel1.Keyword,
                    departmentId: FilterPanel1.DepartmentId,
                    locationId: FilterPanel1.LocationId,
                    categoryId: FilterPanel1.CategoryId,
                    severity: FilterPanel1.Severity,
                    status: FilterPanel1.Status,
                    startDate: FilterPanel1.StartDate,
                    endDate: FilterPanel1.EndDate,
                    pageNumber: 1,
                    pageSize: 10000 // Max export limit
                );
            }
            else
            {
                dtIncidents = _incidentManager.GetAllIncidents(
                    pageNumber: 1,
                    pageSize: 10000 // Max export limit
                );
            }

            _reportGenerator.ExportIncidentsToExcel(dtIncidents, Response, "Incidents");
        }
        catch (Exception ex)
        {
            Logger.LogError("IncidentList.ExportToExcel", ex);
            ShowError(string.Format("Error exporting to Excel: {0}", ex.Message));
        }
    }

    /// <summary>
    /// Helper method to get severity badge CSS class
    /// </summary>
    protected string GetSeverityBadgeClass(object severity)
    {
        int severityValue = Convert.ToInt32(severity);
        switch (severityValue)
        {
            case 5:
                return "badge badge-danger";
            case 4:
                return "badge badge-warning";
            case 3:
                return "badge badge-info";
            case 2:
                return "badge badge-secondary";
            case 1:
                return "badge badge-light";
            default:
                return "badge badge-light";
        }
    }

    /// <summary>
    /// Helper method to truncate text
    /// </summary>
    protected string TruncateText(string text, int maxLength)
    {
        if (string.IsNullOrEmpty(text) || text.Length <= maxLength)
            return text;

        return text.Substring(0, maxLength) + "...";
    }

    /// <summary>
    /// Shows success message
    /// </summary>
    private void ShowMessage(string message)
    {
        lblMessage.Text = message;
        lblMessage.Visible = true;
        lblError.Visible = false;
    }

    /// <summary>
    /// Shows error message
    /// </summary>
    private void ShowError(string message)
    {
        lblError.Text = message;
        lblError.Visible = true;
        lblMessage.Visible = false;
    }
}
