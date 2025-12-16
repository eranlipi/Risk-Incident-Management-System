using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Collections.Generic;

/// <summary>
/// Business Logic Layer - Incident Management
/// Handles all business rules, validation, and incident operations
/// </summary>
public class IncidentManager
{
    private readonly DatabaseHelper _db;
    private readonly NotificationService _notificationService;

    public IncidentManager()
    {
        _db = new DatabaseHelper();
        _notificationService = new NotificationService();
    }

    #region Incident CRUD Operations

    /// <summary>
    /// Gets all incidents with pagination and sorting
    /// </summary>
    public DataTable GetAllIncidents(int pageNumber = 1, int pageSize = 20, string sortColumn = "IncidentDate", string sortDirection = "DESC")
    {
        SqlParameter[] parameters = new SqlParameter[]
        {
            _db.CreateParameter("@PageNumber", pageNumber),
            _db.CreateParameter("@PageSize", pageSize),
            _db.CreateParameter("@SortColumn", sortColumn),
            _db.CreateParameter("@SortDirection", sortDirection)
        };

        return _db.ExecuteStoredProcedure("sp_GetAllIncidents", parameters);
    }

    /// <summary>
    /// Gets a single incident by ID with full details
    /// </summary>
    public DataRow GetIncidentById(int incidentId)
    {
        SqlParameter[] parameters = new SqlParameter[]
        {
            _db.CreateParameter("@IncidentID", incidentId)
        };

        DataTable dt = _db.ExecuteStoredProcedure("sp_GetIncidentById", parameters);

        if (dt.Rows.Count == 0)
        {
            throw new ApplicationException($"Incident with ID {incidentId} not found.");
        }

        return dt.Rows[0];
    }

    /// <summary>
    /// Creates a new incident
    /// </summary>
    public int CreateIncident(
        string title,
        string description,
        int severity,
        DateTime incidentDate,
        int locationId,
        int departmentId,
        int categoryId,
        int reportedByUserId,
        string status = "Open",
        string rootCause = null,
        bool injuriesReported = false,
        int witnessCount = 0,
        decimal? estimatedCost = null)
    {
        // Validation
        ValidateIncident(title, severity, incidentDate);

        SqlParameter[] parameters = new SqlParameter[]
        {
            _db.CreateParameter("@Title", title),
            _db.CreateParameter("@Description", description),
            _db.CreateParameter("@Severity", severity),
            _db.CreateParameter("@IncidentDate", incidentDate),
            _db.CreateParameter("@LocationID", locationId),
            _db.CreateParameter("@DepartmentID", departmentId),
            _db.CreateParameter("@CategoryID", categoryId),
            _db.CreateParameter("@ReportedByUserID", reportedByUserId),
            _db.CreateParameter("@Status", status),
            _db.CreateParameter("@RootCause", rootCause),
            _db.CreateParameter("@InjuriesReported", injuriesReported),
            _db.CreateParameter("@WitnessCount", witnessCount),
            _db.CreateParameter("@EstimatedCost", estimatedCost)
        };

        int newIncidentId = Convert.ToInt32(_db.ExecuteWithOutputParameter(
            "sp_InsertIncident",
            "@NewIncidentID",
            SqlDbType.Int,
            parameters
        ));

        // Send notification for critical incidents
        if (ShouldSendNotification(severity))
        {
            try
            {
                _notificationService.SendCriticalIncidentAlert(newIncidentId, title, severity, departmentId);
                Logger.LogInfo("IncidentManager.CreateIncident", $"Notification sent for incident {newIncidentId}");
            }
            catch (Exception ex)
            {
                Logger.LogError("IncidentManager.CreateIncident - Notification", ex);
                // Don't fail incident creation if notification fails
            }
        }

        return newIncidentId;
    }

    /// <summary>
    /// Updates an existing incident
    /// </summary>
    public bool UpdateIncident(
        int incidentId,
        string title,
        string description,
        int severity,
        DateTime incidentDate,
        int locationId,
        int departmentId,
        int categoryId,
        string status,
        string rootCause = null,
        bool injuriesReported = false,
        int witnessCount = 0,
        decimal? estimatedCost = null,
        int? closedByUserId = null)
    {
        // Validation
        ValidateIncident(title, severity, incidentDate);

        SqlParameter[] parameters = new SqlParameter[]
        {
            _db.CreateParameter("@IncidentID", incidentId),
            _db.CreateParameter("@Title", title),
            _db.CreateParameter("@Description", description),
            _db.CreateParameter("@Severity", severity),
            _db.CreateParameter("@IncidentDate", incidentDate),
            _db.CreateParameter("@LocationID", locationId),
            _db.CreateParameter("@DepartmentID", departmentId),
            _db.CreateParameter("@CategoryID", categoryId),
            _db.CreateParameter("@Status", status),
            _db.CreateParameter("@RootCause", rootCause),
            _db.CreateParameter("@InjuriesReported", injuriesReported),
            _db.CreateParameter("@WitnessCount", witnessCount),
            _db.CreateParameter("@EstimatedCost", estimatedCost),
            _db.CreateParameter("@ClosedByUserID", closedByUserId)
        };

        int rowsAffected = _db.ExecuteNonQuery("sp_UpdateIncident", parameters);

        return rowsAffected > 0;
    }

    /// <summary>
    /// Soft deletes an incident (archives it)
    /// </summary>
    public bool DeleteIncident(int incidentId)
    {
        SqlParameter[] parameters = new SqlParameter[]
        {
            _db.CreateParameter("@IncidentID", incidentId)
        };

        int rowsAffected = _db.ExecuteNonQuery("sp_DeleteIncident", parameters);

        return rowsAffected > 0;
    }

    /// <summary>
    /// Searches incidents with multiple filter criteria
    /// </summary>
    public DataTable SearchIncidents(
        string keyword = null,
        int? departmentId = null,
        int? locationId = null,
        int? categoryId = null,
        int? severity = null,
        string status = null,
        DateTime? startDate = null,
        DateTime? endDate = null,
        int pageNumber = 1,
        int pageSize = 20)
    {
        SqlParameter[] parameters = new SqlParameter[]
        {
            _db.CreateParameter("@Keyword", keyword),
            _db.CreateParameter("@DepartmentID", departmentId),
            _db.CreateParameter("@LocationID", locationId),
            _db.CreateParameter("@CategoryID", categoryId),
            _db.CreateParameter("@Severity", severity),
            _db.CreateParameter("@Status", status),
            _db.CreateParameter("@StartDate", startDate),
            _db.CreateParameter("@EndDate", endDate),
            _db.CreateParameter("@PageNumber", pageNumber),
            _db.CreateParameter("@PageSize", pageSize)
        };

        return _db.ExecuteStoredProcedure("sp_SearchIncidents", parameters);
    }

    #endregion

    #region Incident Actions

    /// <summary>
    /// Gets all actions for a specific incident
    /// </summary>
    public DataTable GetIncidentActions(int incidentId)
    {
        SqlParameter[] parameters = new SqlParameter[]
        {
            _db.CreateParameter("@IncidentID", incidentId)
        };

        return _db.ExecuteStoredProcedure("sp_GetIncidentActions", parameters);
    }

    /// <summary>
    /// Creates a new corrective action
    /// </summary>
    public int CreateAction(
        int incidentId,
        string actionDescription,
        string actionType,
        int assignedToUserId,
        int createdByUserId,
        DateTime? dueDate = null,
        string status = "Pending",
        string notes = null)
    {
        // Validation
        if (string.IsNullOrWhiteSpace(actionDescription))
        {
            throw new ArgumentException("Action description is required.");
        }

        if (!IsValidActionType(actionType))
        {
            throw new ArgumentException("Invalid action type. Must be Corrective, Preventive, or Investigation.");
        }

        SqlParameter[] parameters = new SqlParameter[]
        {
            _db.CreateParameter("@IncidentID", incidentId),
            _db.CreateParameter("@ActionDescription", actionDescription),
            _db.CreateParameter("@ActionType", actionType),
            _db.CreateParameter("@AssignedToUserID", assignedToUserId),
            _db.CreateParameter("@CreatedByUserID", createdByUserId),
            _db.CreateParameter("@DueDate", dueDate),
            _db.CreateParameter("@Status", status),
            _db.CreateParameter("@Notes", notes)
        };

        int newActionId = Convert.ToInt32(_db.ExecuteWithOutputParameter(
            "sp_InsertIncidentAction",
            "@NewActionID",
            SqlDbType.Int,
            parameters
        ));

        // Send notification to assigned user
        try
        {
            _notificationService.SendActionAssignmentNotification(newActionId, assignedToUserId, actionDescription, dueDate);
        }
        catch (Exception ex)
        {
            Logger.LogError("IncidentManager.CreateAction - Notification", ex);
        }

        return newActionId;
    }

    /// <summary>
    /// Updates an existing action
    /// </summary>
    public bool UpdateAction(
        int actionId,
        string actionDescription,
        string actionType,
        int assignedToUserId,
        DateTime? dueDate,
        DateTime? completedDate,
        string status,
        string notes = null)
    {
        // Validation
        if (!IsValidActionType(actionType))
        {
            throw new ArgumentException("Invalid action type.");
        }

        SqlParameter[] parameters = new SqlParameter[]
        {
            _db.CreateParameter("@ActionID", actionId),
            _db.CreateParameter("@ActionDescription", actionDescription),
            _db.CreateParameter("@ActionType", actionType),
            _db.CreateParameter("@AssignedToUserID", assignedToUserId),
            _db.CreateParameter("@DueDate", dueDate),
            _db.CreateParameter("@CompletedDate", completedDate),
            _db.CreateParameter("@Status", status),
            _db.CreateParameter("@Notes", notes)
        };

        int rowsAffected = _db.ExecuteNonQuery("sp_UpdateIncidentAction", parameters);

        return rowsAffected > 0;
    }

    /// <summary>
    /// Gets overdue actions
    /// </summary>
    public DataTable GetOverdueActions()
    {
        return _db.ExecuteStoredProcedure("sp_GetOverdueActions");
    }

    #endregion

    #region Dashboard and Reporting

    /// <summary>
    /// Gets all dashboard metrics
    /// </summary>
    public DataSet GetDashboardMetrics()
    {
        return _db.ExecuteStoredProcedureDataSet("sp_GetDashboardMetrics");
    }

    /// <summary>
    /// Gets incident trends by month
    /// </summary>
    public DataTable GetIncidentsByMonth(int monthsBack = 12)
    {
        SqlParameter[] parameters = new SqlParameter[]
        {
            _db.CreateParameter("@MonthsBack", monthsBack)
        };

        return _db.ExecuteStoredProcedure("sp_GetIncidentsByMonth", parameters);
    }

    /// <summary>
    /// Gets incidents grouped by department
    /// </summary>
    public DataTable GetIncidentsByDepartment()
    {
        return _db.ExecuteStoredProcedure("sp_GetIncidentsByDepartment");
    }

    /// <summary>
    /// Gets incidents grouped by severity
    /// </summary>
    public DataTable GetIncidentsBySeverity()
    {
        return _db.ExecuteStoredProcedure("sp_GetIncidentsBySeverity");
    }

    /// <summary>
    /// Gets top incident categories
    /// </summary>
    public DataTable GetTopCategories(int topN = 5)
    {
        SqlParameter[] parameters = new SqlParameter[]
        {
            _db.CreateParameter("@TopN", topN)
        };

        return _db.ExecuteStoredProcedure("sp_GetTopCategories", parameters);
    }

    #endregion

    #region Validation Methods

    /// <summary>
    /// Validates incident data before insert/update
    /// </summary>
    private void ValidateIncident(string title, int severity, DateTime incidentDate)
    {
        List<string> errors = new List<string>();

        // Title validation
        if (string.IsNullOrWhiteSpace(title))
        {
            errors.Add("Title is required.");
        }
        else if (title.Length > 200)
        {
            errors.Add("Title cannot exceed 200 characters.");
        }

        // Severity validation
        if (severity < 1 || severity > 5)
        {
            errors.Add("Severity must be between 1 and 5.");
        }

        // Date validation
        if (incidentDate > DateTime.Now)
        {
            errors.Add("Incident date cannot be in the future.");
        }

        if (incidentDate < DateTime.Now.AddYears(-10))
        {
            errors.Add("Incident date seems too old. Please verify.");
        }

        if (errors.Count > 0)
        {
            throw new ValidationException(string.Join(" ", errors));
        }
    }

    /// <summary>
    /// Validates action type
    /// </summary>
    private bool IsValidActionType(string actionType)
    {
        string[] validTypes = { "Corrective", "Preventive", "Investigation" };
        return Array.Exists(validTypes, t => t.Equals(actionType, StringComparison.OrdinalIgnoreCase));
    }

    /// <summary>
    /// Determines if notification should be sent based on severity
    /// </summary>
    private bool ShouldSendNotification(int severity)
    {
        string enabledSetting = ConfigurationManager.AppSettings["AlertEmail.Enabled"];
        string thresholdSetting = ConfigurationManager.AppSettings["AlertEmail.CriticalSeverityThreshold"];

        if (enabledSetting == null || !bool.Parse(enabledSetting))
        {
            return false;
        }

        int threshold = int.Parse(thresholdSetting ?? "4");
        return severity >= threshold;
    }

    #endregion

    #region Helper Methods

    /// <summary>
    /// Gets severity label from numeric value
    /// </summary>
    public static string GetSeverityLabel(int severity)
    {
        switch (severity)
        {
            case 1:
                return "Low";
            case 2:
                return "Moderate";
            case 3:
                return "Significant";
            case 4:
                return "High";
            case 5:
                return "Critical";
            default:
                return "Unknown";
        }
    }

    /// <summary>
    /// Gets severity CSS class for styling
    /// </summary>
    public static string GetSeverityClass(int severity)
    {
        switch (severity)
        {
            case 1:
                return "severity-low";
            case 2:
                return "severity-moderate";
            case 3:
                return "severity-significant";
            case 4:
                return "severity-high";
            case 5:
                return "severity-critical";
            default:
                return "severity-unknown";
        }
    }

    /// <summary>
    /// Gets status badge CSS class
    /// </summary>
    public static string GetStatusClass(string status)
    {
        switch (status?.ToLower())
        {
            case "open":
                return "badge-danger";
            case "in progress":
                return "badge-warning";
            case "under review":
                return "badge-info";
            case "closed":
                return "badge-success";
            case "archived":
                return "badge-secondary";
            default:
                return "badge-light";
        }
    }

    #endregion
}

/// <summary>
/// Custom validation exception
/// </summary>
public class ValidationException : ApplicationException
{
    public ValidationException(string message) : base(message)
    {
    }
}
