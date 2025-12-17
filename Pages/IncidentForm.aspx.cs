using System;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;

/// <summary>
/// Incident Form - Handles Create, Edit, and View modes
/// </summary>
public partial class Pages_IncidentForm : System.Web.UI.Page
{
    private IncidentManager _incidentManager;
    private DatabaseHelper _db;
    private int _incidentId;
    private string _mode; // view, edit, or create

    protected void Page_Load(object sender, EventArgs e)
    {
        _incidentManager = new IncidentManager();
        _db = new DatabaseHelper();

        // Get mode and incident ID from query string
        _mode = Request.QueryString["mode"] ?? "create";
        if (int.TryParse(Request.QueryString["id"], out _incidentId))
        {
            // Editing or viewing existing incident
        }
        else
        {
            _mode = "create";
        }

        if (!IsPostBack)
        {
            LoadLookupData();
            InitializeForm();
        }
    }

    /// <summary>
    /// Loads dropdown lists
    /// </summary>
    private void LoadLookupData()
    {
        // Load Departments
        DataTable dtDepartments = _db.GetDepartments();
        ddlDepartment.DataSource = dtDepartments;
        ddlDepartment.DataTextField = "DepartmentName";
        ddlDepartment.DataValueField = "DepartmentID";
        ddlDepartment.DataBind();
        ddlDepartment.Items.Insert(0, new ListItem("-- Select Department --", ""));

        // Load Locations
        DataTable dtLocations = _db.GetLocations();
        ddlLocation.DataSource = dtLocations;
        ddlLocation.DataTextField = "LocationName";
        ddlLocation.DataValueField = "LocationID";
        ddlLocation.DataBind();
        ddlLocation.Items.Insert(0, new ListItem("-- Select Location --", ""));

        // Load Categories
        DataTable dtCategories = _db.GetCategories();
        ddlCategory.DataSource = dtCategories;
        ddlCategory.DataTextField = "CategoryName";
        ddlCategory.DataValueField = "CategoryID";
        ddlCategory.DataBind();
        ddlCategory.Items.Insert(0, new ListItem("-- Select Category --", ""));
    }

    /// <summary>
    /// Initializes form based on mode
    /// </summary>
    private void InitializeForm()
    {
        switch (_mode.ToLower())
        {
            case "create":
                lblPageTitle.Text = "New Incident Report";
                txtIncidentDate.Text = DateTime.Now.ToString("yyyy-MM-ddTHH:mm");
                break;

            case "edit":
                lblPageTitle.Text = "Edit Incident Report";
                LoadIncidentData();
                pnlIncidentInfo.Visible = true;
                pnlActions.Visible = true;
                pnlRootCause.Visible = true;
                LoadActions();
                break;

            case "view":
                lblPageTitle.Text = "View Incident Report";
                LoadIncidentData();
                SetReadOnlyMode();
                pnlIncidentInfo.Visible = true;
                pnlActions.Visible = true;
                LoadActions();
                break;
        }
    }

    /// <summary>
    /// Loads incident data for edit/view mode
    /// </summary>
    private void LoadIncidentData()
    {
        try
        {
            DataRow incident = _incidentManager.GetIncidentById(_incidentId);

            txtTitle.Text = incident["Title"].ToString();
            txtDescription.Text = incident["Description"].ToString();
            ddlSeverity.SelectedValue = incident["Severity"].ToString();
            txtIncidentDate.Text = Convert.ToDateTime(incident["IncidentDate"]).ToString("yyyy-MM-ddTHH:mm");
            ddlStatus.SelectedValue = incident["Status"].ToString();
            ddlDepartment.SelectedValue = incident["DepartmentID"].ToString();
            ddlLocation.SelectedValue = incident["LocationID"].ToString();
            ddlCategory.SelectedValue = incident["CategoryID"].ToString();
            chkInjuries.Checked = Convert.ToBoolean(incident["InjuriesReported"]);
            txtWitnessCount.Text = incident["WitnessCount"].ToString();

            if (incident["EstimatedCost"] != DBNull.Value)
            {
                txtEstimatedCost.Text = incident["EstimatedCost"].ToString();
            }

            if (incident["RootCause"] != DBNull.Value)
            {
                txtRootCause.Text = incident["RootCause"].ToString();
            }

            // Set info panel
            lblIncidentId.Text = string.Format("#{0}", _incidentId);
            lblCreatedDate.Text = Convert.ToDateTime(incident["CreatedDate"]).ToString("MMM dd, yyyy HH:mm");
            lblLastModified.Text = Convert.ToDateTime(incident["LastModifiedDate"]).ToString("MMM dd, yyyy HH:mm");
            lblReportedBy.Text = incident["ReportedBy"].ToString();
        }
        catch (Exception ex)
        {
            Logger.LogError("IncidentForm.LoadIncidentData", ex);
            ShowError("Error loading incident data.");
        }
    }

    /// <summary>
    /// Loads corrective actions
    /// </summary>
    private void LoadActions()
    {
        try
        {
            DataTable dtActions = _incidentManager.GetIncidentActions(_incidentId);
            gvActions.DataSource = dtActions;
            gvActions.DataBind();
        }
        catch (Exception ex)
        {
            Logger.LogError("IncidentForm.LoadActions", ex);
        }
    }

    /// <summary>
    /// Sets form to read-only mode
    /// </summary>
    private void SetReadOnlyMode()
    {
        txtTitle.Enabled = false;
        txtDescription.Enabled = false;
        ddlSeverity.Enabled = false;
        txtIncidentDate.Enabled = false;
        ddlStatus.Enabled = false;
        ddlDepartment.Enabled = false;
        ddlLocation.Enabled = false;
        ddlCategory.Enabled = false;
        chkInjuries.Enabled = false;
        txtWitnessCount.Enabled = false;
        txtEstimatedCost.Enabled = false;
        txtRootCause.Enabled = false;

        pnlButtons.Visible = false;
    }

    /// <summary>
    /// Save button click handler
    /// </summary>
    protected void btnSave_Click(object sender, EventArgs e)
    {
        if (!Page.IsValid)
            return;

        try
        {
            string title = txtTitle.Text.Trim();
            string description = txtDescription.Text.Trim();
            int severity = int.Parse(ddlSeverity.SelectedValue);
            DateTime incidentDate = DateTime.Parse(txtIncidentDate.Text);
            int locationId = int.Parse(ddlLocation.SelectedValue);
            int departmentId = int.Parse(ddlDepartment.SelectedValue);
            int categoryId = int.Parse(ddlCategory.SelectedValue);
            string status = ddlStatus.SelectedValue;
            bool injuriesReported = chkInjuries.Checked;
            int witnessCount = string.IsNullOrEmpty(txtWitnessCount.Text) ? 0 : int.Parse(txtWitnessCount.Text);

            decimal? estimatedCost = null;
            if (!string.IsNullOrEmpty(txtEstimatedCost.Text))
            {
                estimatedCost = decimal.Parse(txtEstimatedCost.Text);
            }

            string rootCause = txtRootCause.Text.Trim();

            if (_mode == "create")
            {
                // Create new incident
                // For demo purposes, using UserID = 2 (safety officer)
                int newIncidentId = _incidentManager.CreateIncident(
                    title, description, severity, incidentDate,
                    locationId, departmentId, categoryId,
                    reportedByUserId: 2, // Default user ID
                    status: status,
                    rootCause: string.IsNullOrEmpty(rootCause) ? null : rootCause,
                    injuriesReported: injuriesReported,
                    witnessCount: witnessCount,
                    estimatedCost: estimatedCost
                );

                ShowSuccess(string.Format("Incident #{0} created successfully.", newIncidentId));

                // Redirect to edit mode
                Response.Redirect(string.Format("IncidentForm.aspx?id={0}&mode=edit", newIncidentId));
            }
            else if (_mode == "edit")
            {
                // Update existing incident
                bool success = _incidentManager.UpdateIncident(
                    _incidentId, title, description, severity, incidentDate,
                    locationId, departmentId, categoryId, status,
                    rootCause: string.IsNullOrEmpty(rootCause) ? null : rootCause,
                    injuriesReported: injuriesReported,
                    witnessCount: witnessCount,
                    estimatedCost: estimatedCost,
                    closedByUserId: status == "Closed" ? 2 : (int?)null // Default user ID
                );

                if (success)
                {
                    ShowSuccess("Incident updated successfully.");
                    LoadIncidentData(); // Reload to show updated data
                }
                else
                {
                    ShowError("Failed to update incident.");
                }
            }
        }
        catch (ValidationException vex)
        {
            ShowError(vex.Message);
        }
        catch (Exception ex)
        {
            Logger.LogError("IncidentForm.btnSave_Click", ex);
            ShowError(string.Format("Error saving incident: {0}", ex.Message));
        }
    }

    /// <summary>
    /// Cancel button click handler
    /// </summary>
    protected void btnCancel_Click(object sender, EventArgs e)
    {
        Response.Redirect("IncidentList.aspx");
    }

    /// <summary>
    /// Custom validator for incident date
    /// </summary>
    protected void cvIncidentDate_ServerValidate(object source, ServerValidateEventArgs args)
    {
        DateTime incidentDate;
        if (DateTime.TryParse(args.Value, out incidentDate))
        {
            args.IsValid = incidentDate <= DateTime.Now;
        }
        else
        {
            args.IsValid = false;
        }
    }

    /// <summary>
    /// Shows success message
    /// </summary>
    private void ShowSuccess(string message)
    {
        lblSuccess.Text = message;
        pnlSuccess.Visible = true;
        pnlError.Visible = false;
    }

    /// <summary>
    /// Shows error message
    /// </summary>
    private void ShowError(string message)
    {
        lblError.Text = message;
        pnlError.Visible = true;
        pnlSuccess.Visible = false;
    }
}
