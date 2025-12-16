using System;
using System.Data;
using System.Web.Script.Serialization;
using System.Collections.Generic;
using System.Linq;

/// <summary>
/// Dashboard page - displays KPIs and charts
/// </summary>
public partial class Pages_Default : System.Web.UI.Page
{
    private IncidentManager _incidentManager;

    protected void Page_Load(object sender, EventArgs e)
    {
        _incidentManager = new IncidentManager();

        if (!IsPostBack)
        {
            LoadDashboardData();
        }
    }

    /// <summary>
    /// Loads all dashboard data
    /// </summary>
    private void LoadDashboardData()
    {
        try
        {
            LoadMetrics();
            LoadChartData();
            LoadRecentIncidents();

            lblLastUpdate.Text = DateTime.Now.ToString("MMM dd, yyyy HH:mm");
        }
        catch (Exception ex)
        {
            Logger.LogError("Default.LoadDashboardData", ex);
            ShowError("Error loading dashboard data. Please try again.");
        }
    }

    /// <summary>
    /// Loads KPI metrics
    /// </summary>
    private void LoadMetrics()
    {
        DataSet dsMetrics = _incidentManager.GetDashboardMetrics();

        // Total Incidents
        if (dsMetrics.Tables[0].Rows.Count > 0)
        {
            lblTotalIncidents.Text = dsMetrics.Tables[0].Rows[0]["TotalIncidents"].ToString();
        }

        // Open Incidents
        if (dsMetrics.Tables[1].Rows.Count > 0)
        {
            lblOpenIncidents.Text = dsMetrics.Tables[1].Rows[0]["OpenIncidents"].ToString();
        }

        // Closed Incidents
        if (dsMetrics.Tables[2].Rows.Count > 0)
        {
            lblClosedIncidents.Text = dsMetrics.Tables[2].Rows[0]["ClosedIncidents"].ToString();
        }

        // Average Resolution Time
        if (dsMetrics.Tables[3].Rows.Count > 0 && dsMetrics.Tables[3].Rows[0]["AvgResolutionDays"] != DBNull.Value)
        {
            double avgDays = Convert.ToDouble(dsMetrics.Tables[3].Rows[0]["AvgResolutionDays"]);
            lblAvgResolution.Text = Math.Round(avgDays, 1).ToString();
        }

        // Critical Incidents
        if (dsMetrics.Tables[4].Rows.Count > 0)
        {
            lblCriticalIncidents.Text = dsMetrics.Tables[4].Rows[0]["CriticalIncidents"].ToString();
        }

        // Incidents with Injuries
        if (dsMetrics.Tables[5].Rows.Count > 0)
        {
            lblInjuries.Text = dsMetrics.Tables[5].Rows[0]["IncidentsWithInjuries"].ToString();
        }

        // Overdue Actions
        if (dsMetrics.Tables[6].Rows.Count > 0)
        {
            lblOverdueActions.Text = dsMetrics.Tables[6].Rows[0]["OverdueActions"].ToString();
        }

        // Pending Actions
        if (dsMetrics.Tables[7].Rows.Count > 0)
        {
            lblPendingActions.Text = dsMetrics.Tables[7].Rows[0]["PendingActions"].ToString();
        }
    }

    /// <summary>
    /// Loads chart data and serializes to JSON for JavaScript
    /// </summary>
    private void LoadChartData()
    {
        JavaScriptSerializer serializer = new JavaScriptSerializer();

        // Incidents by Month
        DataTable dtByMonth = _incidentManager.GetIncidentsByMonth(6);
        var monthData = new
        {
            labels = dtByMonth.AsEnumerable().Select(r => r.Field<string>("MonthName")).ToArray(),
            data = dtByMonth.AsEnumerable().Select(r => r.Field<int>("IncidentCount")).ToArray()
        };
        hfIncidentsByMonth.Value = serializer.Serialize(monthData);

        // Incidents by Department
        DataTable dtByDepartment = _incidentManager.GetIncidentsByDepartment();
        var deptData = new
        {
            labels = dtByDepartment.AsEnumerable().Select(r => r.Field<string>("DepartmentName")).ToArray(),
            data = dtByDepartment.AsEnumerable().Select(r => r.Field<int>("IncidentCount")).ToArray()
        };
        hfIncidentsByDepartment.Value = serializer.Serialize(deptData);

        // Incidents by Severity
        DataTable dtBySeverity = _incidentManager.GetIncidentsBySeverity();
        var severityData = new
        {
            labels = dtBySeverity.AsEnumerable().Select(r => r.Field<string>("SeverityLabel")).ToArray(),
            data = dtBySeverity.AsEnumerable().Select(r => r.Field<int>("IncidentCount")).ToArray()
        };
        hfIncidentsBySeverity.Value = serializer.Serialize(severityData);

        // Top Categories
        DataTable dtTopCategories = _incidentManager.GetTopCategories(5);
        var categoryData = new
        {
            labels = dtTopCategories.AsEnumerable().Select(r => r.Field<string>("CategoryName")).ToArray(),
            data = dtTopCategories.AsEnumerable().Select(r => r.Field<int>("IncidentCount")).ToArray()
        };
        hfTopCategories.Value = serializer.Serialize(categoryData);
    }

    /// <summary>
    /// Loads recent incidents for the grid
    /// </summary>
    private void LoadRecentIncidents()
    {
        DataTable dtIncidents = _incidentManager.GetAllIncidents(pageNumber: 1, pageSize: 10, sortColumn: "IncidentDate", sortDirection: "DESC");

        gvRecentIncidents.DataSource = dtIncidents;
        gvRecentIncidents.DataBind();
    }

    /// <summary>
    /// Refresh button click handler
    /// </summary>
    protected void btnRefresh_Click(object sender, EventArgs e)
    {
        LoadDashboardData();
        UpdatePanelMetrics.Update();
    }

    /// <summary>
    /// Gets severity badge CSS class for GridView
    /// </summary>
    protected string GetSeverityBadgeClass(object severity)
    {
        int severityValue = Convert.ToInt32(severity);
        return IncidentManager.GetSeverityClass(severityValue);
    }

    /// <summary>
    /// Shows error message to user
    /// </summary>
    private void ShowError(string message)
    {
        // In a production app, this would display a proper error message
        // For now, we'll just log it
        Logger.LogError("Default.ShowError", new Exception(message));
    }
}
