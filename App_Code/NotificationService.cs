using System;
using System.Configuration;
using System.Net;
using System.Net.Mail;
using System.Text;
using System.Threading.Tasks;
using System.Data;

/// <summary>
/// Notification Service - Handles email notifications
/// Sends alerts for critical incidents, action assignments, and overdue tasks
/// </summary>
public class NotificationService
{
    private readonly string _smtpHost;
    private readonly int _smtpPort;
    private readonly bool _enableSsl;
    private readonly string _smtpUsername;
    private readonly string _smtpPassword;
    private readonly string _fromAddress;
    private readonly string _fromName;
    private readonly bool _notificationsEnabled;
    private readonly DatabaseHelper _db;

    public NotificationService()
    {
        // Load SMTP configuration from Web.config
        _smtpHost = ConfigurationManager.AppSettings["SMTP.Host"] ?? "smtp.gmail.com";
        _smtpPort = int.Parse(ConfigurationManager.AppSettings["SMTP.Port"] ?? "587");
        _enableSsl = bool.Parse(ConfigurationManager.AppSettings["SMTP.EnableSSL"] ?? "true");
        _smtpUsername = ConfigurationManager.AppSettings["SMTP.Username"];
        _smtpPassword = ConfigurationManager.AppSettings["SMTP.Password"];
        _fromAddress = ConfigurationManager.AppSettings["SMTP.FromAddress"] ?? "noreply@company.com";
        _fromName = ConfigurationManager.AppSettings["SMTP.FromName"] ?? "Incident Management System";
        _notificationsEnabled = bool.Parse(ConfigurationManager.AppSettings["Features.EmailNotifications"] ?? "true");

        _db = new DatabaseHelper();
    }

    #region Critical Incident Alerts

    /// <summary>
    /// Sends email alert for critical incidents
    /// </summary>
    public void SendCriticalIncidentAlert(int incidentId, string title, int severity, int departmentId)
    {
        if (!_notificationsEnabled)
        {
            Logger.LogInfo("NotificationService", "Email notifications are disabled.");
            return;
        }

        try
        {
            // Get recipient emails
            string recipients = ConfigurationManager.AppSettings["AlertEmail.Recipients"] ?? "safety@company.com";

            // Get incident details
            DataRow incident = GetIncidentDetails(incidentId);

            // Build email
            string subject = $"CRITICAL INCIDENT ALERT - Severity {severity}: {title}";
            string body = BuildCriticalIncidentEmail(incident);

            // Send email
            SendEmail(recipients, subject, body, isHtml: true);

            Logger.LogInfo("NotificationService", $"Critical incident alert sent for incident {incidentId}");
        }
        catch (Exception ex)
        {
            Logger.LogError("NotificationService.SendCriticalIncidentAlert", ex);
            throw;
        }
    }

    /// <summary>
    /// Builds HTML email body for critical incident
    /// </summary>
    private string BuildCriticalIncidentEmail(DataRow incident)
    {
        StringBuilder sb = new StringBuilder();

        sb.Append("<html><head><style>");
        sb.Append("body { font-family: Arial, sans-serif; }");
        sb.Append(".container { max-width: 600px; margin: 0 auto; padding: 20px; }");
        sb.Append(".header { background-color: #dc3545; color: white; padding: 15px; border-radius: 5px; }");
        sb.Append(".content { background-color: #f8f9fa; padding: 20px; margin-top: 10px; border-radius: 5px; }");
        sb.Append(".field { margin-bottom: 10px; }");
        sb.Append(".label { font-weight: bold; color: #495057; }");
        sb.Append(".value { color: #212529; }");
        sb.Append(".severity-badge { display: inline-block; padding: 5px 10px; border-radius: 3px; color: white; }");
        sb.Append(".severity-high { background-color: #fd7e14; }");
        sb.Append(".severity-critical { background-color: #dc3545; }");
        sb.Append("</style></head><body>");

        sb.Append("<div class='container'>");
        sb.Append("<div class='header'><h2>⚠️ Critical Incident Alert</h2></div>");
        sb.Append("<div class='content'>");

        sb.AppendFormat("<div class='field'><span class='label'>Incident ID:</span> <span class='value'>#{0}</span></div>",
            incident["IncidentID"]);

        sb.AppendFormat("<div class='field'><span class='label'>Title:</span> <span class='value'>{0}</span></div>",
            Server.HtmlEncode(incident["Title"].ToString()));

        int severity = Convert.ToInt32(incident["Severity"]);
        string severityClass = severity >= 5 ? "severity-critical" : "severity-high";
        sb.AppendFormat("<div class='field'><span class='label'>Severity:</span> <span class='severity-badge {0}'>{1} - {2}</span></div>",
            severityClass, severity, IncidentManager.GetSeverityLabel(severity));

        sb.AppendFormat("<div class='field'><span class='label'>Date:</span> <span class='value'>{0:MMM dd, yyyy HH:mm}</span></div>",
            incident["IncidentDate"]);

        sb.AppendFormat("<div class='field'><span class='label'>Location:</span> <span class='value'>{0}</span></div>",
            Server.HtmlEncode(incident["LocationName"].ToString()));

        sb.AppendFormat("<div class='field'><span class='label'>Department:</span> <span class='value'>{0}</span></div>",
            Server.HtmlEncode(incident["DepartmentName"].ToString()));

        sb.AppendFormat("<div class='field'><span class='label'>Category:</span> <span class='value'>{0}</span></div>",
            Server.HtmlEncode(incident["CategoryName"].ToString()));

        sb.AppendFormat("<div class='field'><span class='label'>Reported By:</span> <span class='value'>{0}</span></div>",
            Server.HtmlEncode(incident["ReportedBy"].ToString()));

        if (incident["Description"] != DBNull.Value && !string.IsNullOrWhiteSpace(incident["Description"].ToString()))
        {
            sb.AppendFormat("<div class='field'><span class='label'>Description:</span><br/><span class='value'>{0}</span></div>",
                Server.HtmlEncode(incident["Description"].ToString()));
        }

        sb.Append("</div>");
        sb.Append("<p style='margin-top: 20px; color: #6c757d; font-size: 12px;'>This is an automated notification from the Incident Management System.</p>");
        sb.Append("</div>");
        sb.Append("</body></html>");

        return sb.ToString();
    }

    /// <summary>
    /// Helper method to get incident details
    /// </summary>
    private DataRow GetIncidentDetails(int incidentId)
    {
        SqlParameter[] parameters = new SqlParameter[]
        {
            _db.CreateParameter("@IncidentID", incidentId)
        };

        DataTable dt = _db.ExecuteStoredProcedure("sp_GetIncidentById", parameters);

        if (dt.Rows.Count == 0)
        {
            throw new ApplicationException($"Incident {incidentId} not found.");
        }

        return dt.Rows[0];
    }

    #endregion

    #region Action Assignment Notifications

    /// <summary>
    /// Sends notification when action is assigned to a user
    /// </summary>
    public void SendActionAssignmentNotification(int actionId, int assignedToUserId, string actionDescription, DateTime? dueDate)
    {
        if (!_notificationsEnabled)
        {
            return;
        }

        try
        {
            // Get user email
            string userEmail = GetUserEmail(assignedToUserId);

            if (string.IsNullOrEmpty(userEmail))
            {
                Logger.LogInfo("NotificationService", $"No email found for user {assignedToUserId}");
                return;
            }

            // Build email
            string subject = "New Action Assigned to You";
            string body = BuildActionAssignmentEmail(actionId, actionDescription, dueDate);

            // Send email async to avoid blocking
            Task.Run(() => SendEmail(userEmail, subject, body, isHtml: true));

            Logger.LogInfo("NotificationService", $"Action assignment notification sent for action {actionId}");
        }
        catch (Exception ex)
        {
            Logger.LogError("NotificationService.SendActionAssignmentNotification", ex);
            // Don't throw - notification failure shouldn't break the application
        }
    }

    /// <summary>
    /// Builds HTML email for action assignment
    /// </summary>
    private string BuildActionAssignmentEmail(int actionId, string actionDescription, DateTime? dueDate)
    {
        StringBuilder sb = new StringBuilder();

        sb.Append("<html><head><style>");
        sb.Append("body { font-family: Arial, sans-serif; }");
        sb.Append(".container { max-width: 600px; margin: 0 auto; padding: 20px; }");
        sb.Append(".header { background-color: #007bff; color: white; padding: 15px; border-radius: 5px; }");
        sb.Append(".content { background-color: #f8f9fa; padding: 20px; margin-top: 10px; border-radius: 5px; }");
        sb.Append("</style></head><body>");

        sb.Append("<div class='container'>");
        sb.Append("<div class='header'><h2>📋 New Action Assigned</h2></div>");
        sb.Append("<div class='content'>");

        sb.AppendFormat("<p><strong>Action ID:</strong> #{0}</p>", actionId);
        sb.AppendFormat("<p><strong>Description:</strong> {0}</p>", Server.HtmlEncode(actionDescription));

        if (dueDate.HasValue)
        {
            sb.AppendFormat("<p><strong>Due Date:</strong> {0:MMM dd, yyyy}</p>", dueDate.Value);

            if (dueDate.Value < DateTime.Now.AddDays(3))
            {
                sb.Append("<p style='color: #dc3545;'><strong>⚠️ This action is due soon!</strong></p>");
            }
        }

        sb.Append("<p>Please log in to the Incident Management System to view details and take action.</p>");

        sb.Append("</div>");
        sb.Append("<p style='margin-top: 20px; color: #6c757d; font-size: 12px;'>This is an automated notification from the Incident Management System.</p>");
        sb.Append("</div>");
        sb.Append("</body></html>");

        return sb.ToString();
    }

    #endregion

    #region Overdue Action Reminders

    /// <summary>
    /// Sends daily digest of overdue actions
    /// </summary>
    public void SendOverdueActionsDigest()
    {
        if (!_notificationsEnabled)
        {
            return;
        }

        try
        {
            DataTable overdueActions = _db.ExecuteStoredProcedure("sp_GetOverdueActions");

            if (overdueActions.Rows.Count == 0)
            {
                Logger.LogInfo("NotificationService", "No overdue actions to report.");
                return;
            }

            // Group by assignee
            var groupedActions = overdueActions.AsEnumerable()
                .GroupBy(row => new
                {
                    UserId = row.Field<int>("AssignedToUserID"),
                    Email = row.Field<string>("AssigneeEmail"),
                    Name = row.Field<string>("AssignedTo")
                });

            foreach (var group in groupedActions)
            {
                string subject = $"Overdue Actions Reminder - {group.Count()} Action(s)";
                string body = BuildOverdueActionsEmail(group.Key.Name, group.ToList());

                Task.Run(() => SendEmail(group.Key.Email, subject, body, isHtml: true));
            }

            Logger.LogInfo("NotificationService", $"Overdue actions digest sent to {groupedActions.Count()} users");
        }
        catch (Exception ex)
        {
            Logger.LogError("NotificationService.SendOverdueActionsDigest", ex);
        }
    }

    /// <summary>
    /// Builds HTML email for overdue actions digest
    /// </summary>
    private string BuildOverdueActionsEmail(string userName, List<DataRow> actions)
    {
        StringBuilder sb = new StringBuilder();

        sb.Append("<html><head><style>");
        sb.Append("body { font-family: Arial, sans-serif; }");
        sb.Append(".container { max-width: 600px; margin: 0 auto; padding: 20px; }");
        sb.Append(".header { background-color: #ffc107; color: #212529; padding: 15px; border-radius: 5px; }");
        sb.Append(".content { background-color: #f8f9fa; padding: 20px; margin-top: 10px; border-radius: 5px; }");
        sb.Append(".action-item { background: white; padding: 10px; margin-bottom: 10px; border-left: 3px solid #dc3545; }");
        sb.Append("</style></head><body>");

        sb.Append("<div class='container'>");
        sb.AppendFormat("<div class='header'><h2>⏰ Overdue Actions Reminder</h2><p>Hello {0},</p></div>", Server.HtmlEncode(userName));
        sb.Append("<div class='content'>");

        sb.AppendFormat("<p>You have <strong>{0}</strong> overdue action(s) that require attention:</p>", actions.Count);

        foreach (DataRow action in actions)
        {
            sb.Append("<div class='action-item'>");
            sb.AppendFormat("<p><strong>Action ID:</strong> #{0}</p>", action["ActionID"]);
            sb.AppendFormat("<p><strong>Description:</strong> {0}</p>", Server.HtmlEncode(action["ActionDescription"].ToString()));
            sb.AppendFormat("<p><strong>Incident:</strong> {0}</p>", Server.HtmlEncode(action["IncidentTitle"].ToString()));
            sb.AppendFormat("<p><strong>Due Date:</strong> {0:MMM dd, yyyy} ", action["DueDate"]);
            sb.AppendFormat("(<strong style='color: #dc3545;'>{0} days overdue</strong>)</p>", action["DaysOverdue"]);
            sb.Append("</div>");
        }

        sb.Append("<p style='margin-top: 20px;'>Please log in to the system to update the status of these actions.</p>");

        sb.Append("</div>");
        sb.Append("<p style='margin-top: 20px; color: #6c757d; font-size: 12px;'>This is an automated daily reminder from the Incident Management System.</p>");
        sb.Append("</div>");
        sb.Append("</body></html>");

        return sb.ToString();
    }

    #endregion

    #region Email Sending

    /// <summary>
    /// Sends an email message
    /// </summary>
    private void SendEmail(string to, string subject, string body, bool isHtml = false)
    {
        if (string.IsNullOrEmpty(_smtpUsername) || string.IsNullOrEmpty(_smtpPassword))
        {
            Logger.LogInfo("NotificationService", "SMTP credentials not configured. Email not sent.");
            return;
        }

        try
        {
            using (MailMessage message = new MailMessage())
            {
                message.From = new MailAddress(_fromAddress, _fromName);

                // Handle multiple recipients
                string[] recipients = to.Split(new[] { ',', ';' }, StringSplitOptions.RemoveEmptyEntries);
                foreach (string recipient in recipients)
                {
                    message.To.Add(recipient.Trim());
                }

                message.Subject = subject;
                message.Body = body;
                message.IsBodyHtml = isHtml;

                using (SmtpClient smtp = new SmtpClient(_smtpHost, _smtpPort))
                {
                    smtp.EnableSsl = _enableSsl;
                    smtp.Credentials = new NetworkCredential(_smtpUsername, _smtpPassword);
                    smtp.Timeout = 30000; // 30 seconds

                    smtp.Send(message);
                }
            }

            Logger.LogInfo("NotificationService", $"Email sent successfully to {to}");
        }
        catch (Exception ex)
        {
            Logger.LogError("NotificationService.SendEmail", ex);
            throw new ApplicationException($"Failed to send email: {ex.Message}", ex);
        }
    }

    #endregion

    #region Helper Methods

    /// <summary>
    /// Gets user email by user ID
    /// </summary>
    private string GetUserEmail(int userId)
    {
        SqlParameter[] parameters = new SqlParameter[]
        {
            _db.CreateParameter("@Role", DBNull.Value)
        };

        DataTable users = _db.ExecuteStoredProcedure("sp_GetUsers", parameters);

        DataRow[] userRows = users.Select($"UserID = {userId}");

        if (userRows.Length > 0)
        {
            return userRows[0]["Email"].ToString();
        }

        return null;
    }

    /// <summary>
    /// HTML encodes text to prevent XSS
    /// </summary>
    private static class Server
    {
        public static string HtmlEncode(string text)
        {
            return System.Web.HttpUtility.HtmlEncode(text);
        }
    }

    #endregion
}
