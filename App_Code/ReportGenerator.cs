using System;
using System.Configuration;
using System.Data;
using System.IO;
using System.Text;
using System.Web;

/// <summary>
/// Report Generator - Handles Excel and PDF exports
/// Generates formatted reports from incident data
/// </summary>
public class ReportGenerator
{
    private readonly IncidentManager _incidentManager;
    private readonly int _maxExportRecords;

    public ReportGenerator()
    {
        _incidentManager = new IncidentManager();
        _maxExportRecords = int.Parse(ConfigurationManager.AppSettings["MaxExportRecords"] ?? "10000");
    }

    #region Excel Export

    /// <summary>
    /// Exports incidents to Excel format
    /// </summary>
    public void ExportIncidentsToExcel(DataTable incidents, HttpResponse response, string filename = "Incidents")
    {
        try
        {
            // Validate data
            if (incidents == null || incidents.Rows.Count == 0)
            {
                throw new ApplicationException("No data available to export.");
            }

            if (incidents.Rows.Count > _maxExportRecords)
            {
                throw new ApplicationException($"Export limited to {_maxExportRecords} records. Please filter your results.");
            }

            // Set response headers for Excel download
            response.Clear();
            response.ClearHeaders();
            response.ClearContent();
            response.ContentType = "application/vnd.ms-excel";
            response.AddHeader("Content-Disposition", $"attachment; filename={filename}_{DateTime.Now:yyyyMMdd_HHmmss}.xls");
            response.Charset = "UTF-8";
            response.ContentEncoding = Encoding.UTF8;

            // Generate Excel content using HTML table format
            StringBuilder sb = new StringBuilder();

            // Excel XML header for better formatting
            sb.Append("<?xml version=\"1.0\"?>\n");
            sb.Append("<?mso-application progid=\"Excel.Sheet\"?>\n");
            sb.Append("<Workbook xmlns=\"urn:schemas-microsoft-com:office:spreadsheet\"\n");
            sb.Append(" xmlns:ss=\"urn:schemas-microsoft-com:office:spreadsheet\">\n");

            // Styles
            sb.Append("<Styles>\n");
            sb.Append("<Style ss:ID=\"HeaderStyle\">\n");
            sb.Append("<Font ss:Bold=\"1\" ss:Color=\"#FFFFFF\"/>\n");
            sb.Append("<Interior ss:Color=\"#4472C4\" ss:Pattern=\"Solid\"/>\n");
            sb.Append("</Style>\n");
            sb.Append("<Style ss:ID=\"SeverityCritical\">\n");
            sb.Append("<Interior ss:Color=\"#FFC7CE\" ss:Pattern=\"Solid\"/>\n");
            sb.Append("<Font ss:Bold=\"1\" ss:Color=\"#9C0006\"/>\n");
            sb.Append("</Style>\n");
            sb.Append("<Style ss:ID=\"SeverityHigh\">\n");
            sb.Append("<Interior ss:Color=\"#FFEB9C\" ss:Pattern=\"Solid\"/>\n");
            sb.Append("<Font ss:Color=\"#9C5700\"/>\n");
            sb.Append("</Style>\n");
            sb.Append("<Style ss:ID=\"DateStyle\">\n");
            sb.Append("<NumberFormat ss:Format=\"mm/dd/yyyy hh:mm\"/>\n");
            sb.Append("</Style>\n");
            sb.Append("</Styles>\n");

            // Worksheet
            sb.Append("<Worksheet ss:Name=\"Incidents\">\n");
            sb.Append("<Table>\n");

            // Column widths
            sb.Append("<Column ss:Width=\"60\"/>\n");   // ID
            sb.Append("<Column ss:Width=\"200\"/>\n");  // Title
            sb.Append("<Column ss:Width=\"80\"/>\n");   // Severity
            sb.Append("<Column ss:Width=\"120\"/>\n");  // Date
            sb.Append("<Column ss:Width=\"100\"/>\n");  // Status
            sb.Append("<Column ss:Width=\"150\"/>\n");  // Department
            sb.Append("<Column ss:Width=\"150\"/>\n");  // Location
            sb.Append("<Column ss:Width=\"120\"/>\n");  // Category
            sb.Append("<Column ss:Width=\"150\"/>\n");  // Reported By
            sb.Append("<Column ss:Width=\"80\"/>\n");   // Injuries

            // Header row
            sb.Append("<Row>\n");
            sb.Append("<Cell ss:StyleID=\"HeaderStyle\"><Data ss:Type=\"String\">Incident ID</Data></Cell>\n");
            sb.Append("<Cell ss:StyleID=\"HeaderStyle\"><Data ss:Type=\"String\">Title</Data></Cell>\n");
            sb.Append("<Cell ss:StyleID=\"HeaderStyle\"><Data ss:Type=\"String\">Severity</Data></Cell>\n");
            sb.Append("<Cell ss:StyleID=\"HeaderStyle\"><Data ss:Type=\"String\">Incident Date</Data></Cell>\n");
            sb.Append("<Cell ss:StyleID=\"HeaderStyle\"><Data ss:Type=\"String\">Status</Data></Cell>\n");
            sb.Append("<Cell ss:StyleID=\"HeaderStyle\"><Data ss:Type=\"String\">Department</Data></Cell>\n");
            sb.Append("<Cell ss:StyleID=\"HeaderStyle\"><Data ss:Type=\"String\">Location</Data></Cell>\n");
            sb.Append("<Cell ss:StyleID=\"HeaderStyle\"><Data ss:Type=\"String\">Category</Data></Cell>\n");
            sb.Append("<Cell ss:StyleID=\"HeaderStyle\"><Data ss:Type=\"String\">Reported By</Data></Cell>\n");
            sb.Append("<Cell ss:StyleID=\"HeaderStyle\"><Data ss:Type=\"String\">Injuries</Data></Cell>\n");
            sb.Append("</Row>\n");

            // Data rows
            foreach (DataRow row in incidents.Rows)
            {
                int severity = Convert.ToInt32(row["Severity"]);
                string severityStyle = severity >= 5 ? "SeverityCritical" : (severity >= 4 ? "SeverityHigh" : "");

                sb.Append("<Row>\n");

                sb.AppendFormat("<Cell><Data ss:Type=\"Number\">{0}</Data></Cell>\n",
                    row["IncidentID"]);

                sb.AppendFormat("<Cell><Data ss:Type=\"String\">{0}</Data></Cell>\n",
                    EscapeXml(row["Title"].ToString()));

                if (!string.IsNullOrEmpty(severityStyle))
                {
                    sb.AppendFormat("<Cell ss:StyleID=\"{0}\"><Data ss:Type=\"String\">{1} - {2}</Data></Cell>\n",
                        severityStyle, severity, IncidentManager.GetSeverityLabel(severity));
                }
                else
                {
                    sb.AppendFormat("<Cell><Data ss:Type=\"String\">{0} - {1}</Data></Cell>\n",
                        severity, IncidentManager.GetSeverityLabel(severity));
                }

                sb.AppendFormat("<Cell ss:StyleID=\"DateStyle\"><Data ss:Type=\"DateTime\">{0:yyyy-MM-ddTHH:mm:ss}</Data></Cell>\n",
                    row["IncidentDate"]);

                sb.AppendFormat("<Cell><Data ss:Type=\"String\">{0}</Data></Cell>\n",
                    EscapeXml(row["Status"].ToString()));

                sb.AppendFormat("<Cell><Data ss:Type=\"String\">{0}</Data></Cell>\n",
                    EscapeXml(row["DepartmentName"].ToString()));

                sb.AppendFormat("<Cell><Data ss:Type=\"String\">{0}</Data></Cell>\n",
                    EscapeXml(row["LocationName"].ToString()));

                sb.AppendFormat("<Cell><Data ss:Type=\"String\">{0}</Data></Cell>\n",
                    EscapeXml(row["CategoryName"].ToString()));

                sb.AppendFormat("<Cell><Data ss:Type=\"String\">{0}</Data></Cell>\n",
                    EscapeXml(row["ReportedBy"].ToString()));

                sb.AppendFormat("<Cell><Data ss:Type=\"String\">{0}</Data></Cell>\n",
                    Convert.ToBoolean(row["InjuriesReported"]) ? "Yes" : "No");

                sb.Append("</Row>\n");
            }

            sb.Append("</Table>\n");
            sb.Append("</Worksheet>\n");
            sb.Append("</Workbook>");

            // Write to response
            response.Write(sb.ToString());
            response.End();

            Logger.LogInfo("ReportGenerator", $"Exported {incidents.Rows.Count} incidents to Excel");
        }
        catch (Exception ex)
        {
            Logger.LogError("ReportGenerator.ExportIncidentsToExcel", ex);
            throw;
        }
    }

    /// <summary>
    /// Exports incident with actions to Excel (detailed report)
    /// </summary>
    public void ExportIncidentDetailToExcel(int incidentId, HttpResponse response)
    {
        try
        {
            DataRow incident = _incidentManager.GetIncidentById(incidentId);
            DataTable actions = _incidentManager.GetIncidentActions(incidentId);

            // Set response headers
            response.Clear();
            response.ClearHeaders();
            response.ClearContent();
            response.ContentType = "application/vnd.ms-excel";
            response.AddHeader("Content-Disposition", $"attachment; filename=Incident_{incidentId}_{DateTime.Now:yyyyMMdd_HHmmss}.xls");
            response.Charset = "UTF-8";
            response.ContentEncoding = Encoding.UTF8;

            StringBuilder sb = new StringBuilder();

            // Start HTML
            sb.Append("<html><head><style>");
            sb.Append("body { font-family: Calibri, Arial; }");
            sb.Append("h1 { color: #2c3e50; }");
            sb.Append("h2 { color: #34495e; margin-top: 20px; }");
            sb.Append("table { border-collapse: collapse; width: 100%; margin-top: 10px; }");
            sb.Append("th { background-color: #4472C4; color: white; padding: 10px; text-align: left; }");
            sb.Append("td { border: 1px solid #ddd; padding: 8px; }");
            sb.Append(".label { font-weight: bold; background-color: #f2f2f2; width: 200px; }");
            sb.Append(".severity-critical { background-color: #FFC7CE; font-weight: bold; }");
            sb.Append(".severity-high { background-color: #FFEB9C; }");
            sb.Append("</style></head><body>");

            // Incident details
            sb.Append("<h1>Incident Report</h1>");

            sb.Append("<table>");
            sb.AppendFormat("<tr><td class='label'>Incident ID</td><td>#{0}</td></tr>", incident["IncidentID"]);
            sb.AppendFormat("<tr><td class='label'>Title</td><td>{0}</td></tr>", EscapeHtml(incident["Title"].ToString()));

            int severity = Convert.ToInt32(incident["Severity"]);
            string severityClass = severity >= 5 ? "severity-critical" : (severity >= 4 ? "severity-high" : "");
            sb.AppendFormat("<tr><td class='label'>Severity</td><td class='{0}'>{1} - {2}</td></tr>",
                severityClass, severity, IncidentManager.GetSeverityLabel(severity));

            sb.AppendFormat("<tr><td class='label'>Incident Date</td><td>{0:MMM dd, yyyy HH:mm}</td></tr>", incident["IncidentDate"]);
            sb.AppendFormat("<tr><td class='label'>Status</td><td>{0}</td></tr>", EscapeHtml(incident["Status"].ToString()));
            sb.AppendFormat("<tr><td class='label'>Department</td><td>{0}</td></tr>", EscapeHtml(incident["DepartmentName"].ToString()));
            sb.AppendFormat("<tr><td class='label'>Location</td><td>{0}</td></tr>", EscapeHtml(incident["LocationName"].ToString()));
            sb.AppendFormat("<tr><td class='label'>Category</td><td>{0}</td></tr>", EscapeHtml(incident["CategoryName"].ToString()));
            sb.AppendFormat("<tr><td class='label'>Reported By</td><td>{0}</td></tr>", EscapeHtml(incident["ReportedBy"].ToString()));
            sb.AppendFormat("<tr><td class='label'>Injuries Reported</td><td>{0}</td></tr>", Convert.ToBoolean(incident["InjuriesReported"]) ? "Yes" : "No");

            if (incident["Description"] != DBNull.Value && !string.IsNullOrWhiteSpace(incident["Description"].ToString()))
            {
                sb.AppendFormat("<tr><td class='label'>Description</td><td>{0}</td></tr>", EscapeHtml(incident["Description"].ToString()));
            }

            if (incident["RootCause"] != DBNull.Value && !string.IsNullOrWhiteSpace(incident["RootCause"].ToString()))
            {
                sb.AppendFormat("<tr><td class='label'>Root Cause</td><td>{0}</td></tr>", EscapeHtml(incident["RootCause"].ToString()));
            }

            sb.Append("</table>");

            // Corrective actions
            if (actions.Rows.Count > 0)
            {
                sb.Append("<h2>Corrective Actions</h2>");
                sb.Append("<table>");
                sb.Append("<tr>");
                sb.Append("<th>Action ID</th>");
                sb.Append("<th>Description</th>");
                sb.Append("<th>Type</th>");
                sb.Append("<th>Assigned To</th>");
                sb.Append("<th>Due Date</th>");
                sb.Append("<th>Status</th>");
                sb.Append("</tr>");

                foreach (DataRow action in actions.Rows)
                {
                    sb.Append("<tr>");
                    sb.AppendFormat("<td>#{0}</td>", action["ActionID"]);
                    sb.AppendFormat("<td>{0}</td>", EscapeHtml(action["ActionDescription"].ToString()));
                    sb.AppendFormat("<td>{0}</td>", EscapeHtml(action["ActionType"].ToString()));
                    sb.AppendFormat("<td>{0}</td>", EscapeHtml(action["AssignedTo"].ToString()));
                    sb.AppendFormat("<td>{0}</td>", action["DueDate"] != DBNull.Value ? Convert.ToDateTime(action["DueDate"]).ToString("MMM dd, yyyy") : "N/A");
                    sb.AppendFormat("<td>{0}</td>", EscapeHtml(action["Status"].ToString()));
                    sb.Append("</tr>");
                }

                sb.Append("</table>");
            }

            sb.Append("<p style='margin-top: 30px; color: #7f8c8d; font-size: 11px;'>");
            sb.AppendFormat("Generated on {0:MMM dd, yyyy HH:mm} by Incident Management System", DateTime.Now);
            sb.Append("</p>");

            sb.Append("</body></html>");

            response.Write(sb.ToString());
            response.End();

            Logger.LogInfo("ReportGenerator", $"Exported incident {incidentId} detail to Excel");
        }
        catch (Exception ex)
        {
            Logger.LogError("ReportGenerator.ExportIncidentDetailToExcel", ex);
            throw;
        }
    }

    #endregion

    #region Helper Methods

    /// <summary>
    /// Escapes XML special characters
    /// </summary>
    private string EscapeXml(string text)
    {
        if (string.IsNullOrEmpty(text))
            return string.Empty;

        return text.Replace("&", "&amp;")
                   .Replace("<", "&lt;")
                   .Replace(">", "&gt;")
                   .Replace("\"", "&quot;")
                   .Replace("'", "&apos;");
    }

    /// <summary>
    /// Escapes HTML special characters
    /// </summary>
    private string EscapeHtml(string text)
    {
        if (string.IsNullOrEmpty(text))
            return string.Empty;

        return HttpUtility.HtmlEncode(text);
    }

    #endregion

    #region Summary Reports

    /// <summary>
    /// Generates a summary report for a date range
    /// </summary>
    public string GenerateSummaryReport(DateTime startDate, DateTime endDate)
    {
        try
        {
            IncidentManager manager = new IncidentManager();

            DataTable incidents = manager.SearchIncidents(
                startDate: startDate,
                endDate: endDate,
                pageSize: _maxExportRecords
            );

            StringBuilder sb = new StringBuilder();

            sb.AppendFormat("Incident Summary Report\n");
            sb.AppendFormat("Period: {0:MMM dd, yyyy} to {1:MMM dd, yyyy}\n\n", startDate, endDate);

            sb.AppendFormat("Total Incidents: {0}\n", incidents.Rows.Count);

            // Count by severity
            int critical = 0, high = 0, moderate = 0, low = 0;
            foreach (DataRow row in incidents.Rows)
            {
                int severity = Convert.ToInt32(row["Severity"]);
                if (severity >= 5) critical++;
                else if (severity == 4) high++;
                else if (severity == 3 || severity == 2) moderate++;
                else low++;
            }

            sb.AppendFormat("  - Critical (5): {0}\n", critical);
            sb.AppendFormat("  - High (4): {0}\n", high);
            sb.AppendFormat("  - Moderate (2-3): {0}\n", moderate);
            sb.AppendFormat("  - Low (1): {0}\n\n", low);

            sb.AppendFormat("Report generated on {0:MMM dd, yyyy HH:mm}\n", DateTime.Now);

            return sb.ToString();
        }
        catch (Exception ex)
        {
            Logger.LogError("ReportGenerator.GenerateSummaryReport", ex);
            throw;
        }
    }

    #endregion
}
