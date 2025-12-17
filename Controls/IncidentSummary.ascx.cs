using System;
using System.Data;
using System.Web.UI;

/// <summary>
/// User Control for displaying incident summary card
/// </summary>
public partial class Controls_IncidentSummary : System.Web.UI.UserControl
{
    private int _incidentId;
    private int _severity;
    private string _status;

    protected void Page_Load(object sender, EventArgs e)
    {
    }

    /// <summary>
    /// Loads incident data into the control
    /// </summary>
    public void LoadIncident(DataRow incidentRow, bool showDescription = false)
    {
        if (incidentRow == null)
            return;

        _incidentId = Convert.ToInt32(incidentRow["IncidentID"]);
        _severity = Convert.ToInt32(incidentRow["Severity"]);
        _status = incidentRow["Status"].ToString();

        lblIncidentId.Text = string.Format("#{0}", _incidentId);
        lblTitle.Text = incidentRow["Title"].ToString();
        lblIncidentDate.Text = Convert.ToDateTime(incidentRow["IncidentDate"]).ToString("MMM dd, yyyy");
        lblDepartment.Text = incidentRow["DepartmentName"].ToString();
        lblLocation.Text = incidentRow["LocationName"].ToString();
        lblCategory.Text = incidentRow["CategoryName"].ToString();
        lblSeverity.Text = string.Format("{0} - {1}", _severity, IncidentManager.GetSeverityLabel(_severity));
        lblStatus.Text = _status;
        lblReportedBy.Text = incidentRow["ReportedBy"].ToString();

        // Show description if requested
        if (showDescription && incidentRow["Description"] != DBNull.Value)
        {
            string description = incidentRow["Description"].ToString();
            if (!string.IsNullOrWhiteSpace(description))
            {
                pnlDescription.Visible = true;
                lblDescription.Text = description.Length > 200
                    ? description.Substring(0, 200) + "..."
                    : description;
            }
        }

        // Set navigation links
        lnkViewDetails.NavigateUrl = string.Format("~/Pages/IncidentForm.aspx?id={0}&mode=view", _incidentId);
        lnkEdit.NavigateUrl = string.Format("~/Pages/IncidentForm.aspx?id={0}&mode=edit", _incidentId);
    }

    /// <summary>
    /// Loads incident data from incident ID
    /// </summary>
    public void LoadIncident(int incidentId, bool showDescription = false)
    {
        IncidentManager manager = new IncidentManager();
        DataRow incident = manager.GetIncidentById(incidentId);
        LoadIncident(incident, showDescription);
    }

    /// <summary>
    /// Gets CSS class for severity header
    /// </summary>
    protected string GetSeverityClass()
    {
        switch (_severity)
        {
            case 5:
                return "bg-danger text-white";
            case 4:
                return "bg-warning text-dark";
            case 3:
                return "bg-info text-white";
            case 2:
                return "bg-secondary text-white";
            case 1:
                return "bg-light text-dark";
            default:
                return "bg-light text-dark";
        }
    }

    /// <summary>
    /// Gets badge CSS class for severity
    /// </summary>
    protected string GetSeverityBadgeClass()
    {
        switch (_severity)
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
    /// Gets badge CSS class for status
    /// </summary>
    protected string GetStatusBadgeClass()
    {
        return IncidentManager.GetStatusClass(_status);
    }
}
