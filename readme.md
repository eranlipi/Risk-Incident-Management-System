# Risk & Incident Management System

## Overview

This project implements a comprehensive incident tracking and risk management solution for workplace safety officers. The system addresses the critical need to move from paper-based or spreadsheet-based incident reporting to a centralized, digital platform that enables real-time tracking, trend analysis, and proactive risk mitigation.

## Business Context

Safety officers face several operational challenges:
- Incident data scattered across multiple Excel files and paper forms
- Difficulty identifying patterns and recurring safety issues
- Manual report generation for regulatory compliance
- Delayed notification of critical incidents to management
- No systematic approach to tracking corrective actions

This system provides a single source of truth for all safety incidents, enabling data-driven decision making and improved workplace safety outcomes.

## Technical Stack

- **Framework**: ASP.NET Web Forms (.NET Framework 4.7.2+)
- **Database**: Microsoft SQL Server 2016+
- **UI Components**: Bootstrap 4.6 for responsive layout
- **Charting**: Chart.js for dashboard visualizations
- **Email**: System.Net.Mail for automated notifications

## Architecture

### Three-Tier Architecture (Improved)

```
Presentation Layer (ASPX Pages + User Controls)
    ↓
Business Logic Layer (/BusinessLogic)
    ↓
Data Access Layer (/DataAccess + /Models)
    ↓
Database (SQL Server)
```

### Key Components

**Presentation Layer:**
- `Default.aspx` - Dashboard with KPIs and trend charts
- `IncidentList.aspx` - GridView with filtering and pagination
- `IncidentForm.aspx` - Create/Edit incident reports
- `Reports.aspx` - Export functionality and custom reports
- `/UserControls/*` - Reusable UI components

**Business Logic Layer:**
- `IncidentManager.cs` - Core business rules and validation
- `NotificationService.cs` - Email alerts for critical incidents
- `ReportGenerator.cs` - PDF/Excel export logic

**Data Access Layer:**
- `DatabaseHelper.cs` - SQL connection management and base operations
- `IncidentRepository.cs` - All incident-related database operations
- `UserRepository.cs` - User authentication and management
- `/Models/*` - Plain C# objects representing database entities

**Database Scripts:**
- `DatabaseSetup.sql` - Schema creation and indexes
- `SeedData.sql` - Test data population
- `StoredProcedures.sql` - All stored procedures in one place

## Database Schema

### Core Tables

**Incidents**
```sql
- IncidentID (PK, INT, Identity)
- Title (NVARCHAR(200), Required)
- Description (NVARCHAR(MAX))
- Severity (TINYINT, 1-5 scale)
- IncidentDate (DATETIME)
- LocationID (FK)
- DepartmentID (FK)
- CategoryID (FK)
- ReportedByUserID (FK)
- Status (NVARCHAR(50), Default: 'Open')
- CreatedDate (DATETIME)
- LastModifiedDate (DATETIME)
```

**IncidentActions**
```sql
- ActionID (PK)
- IncidentID (FK)
- ActionDescription (NVARCHAR(500))
- AssignedToUserID (FK)
- DueDate (DATETIME)
- CompletedDate (DATETIME)
- Status (NVARCHAR(50))
```

**Supporting Tables:**
- Departments (organizational structure)
- Locations (physical areas/buildings)
- Categories (incident types: Fall, Fire, Chemical Spill, etc.)
- Users (staff and safety officers)

### Key Indexes

```sql
IX_Incidents_Status - Non-clustered on Status
IX_Incidents_IncidentDate - Non-clustered DESC on IncidentDate
IX_Incidents_Severity - Non-clustered on Severity
IX_Incidents_Department - Non-clustered on DepartmentID
```

## Features Implementation

### Phase 1: Core Functionality (Required)

#### 1. CRUD Operations
- Create new incident reports with full validation
- View incident details with related actions
- Update incident status and details
- Soft delete (Status = 'Archived')

#### 2. GridView with Advanced Features
- Server-side pagination (20 records per page)
- Multi-column sorting
- ViewState optimization to prevent bloat
- Inline editing for Status field

#### 3. Data Validation
- RequiredFieldValidator for mandatory fields
- RangeValidator for Severity (1-5)
- CustomValidator for IncidentDate (cannot be future)
- RegularExpressionValidator for email formats

#### 4. User Controls
- `IncidentSummary.ascx` - Reusable incident card
- `FilterPanel.ascx` - Search and filter controls
- `ActionTracker.ascx` - Corrective actions widget

### Phase 2: Advanced Features (Choose 3+)

#### 1. Dashboard with KPIs ✓
**Implementation:**
- Chart.js integration via CDN
- Real-time metrics: Total Incidents, Open vs Closed, Average Resolution Time
- Trend charts: Incidents by Month, Incidents by Department, Severity Distribution
- Top 5 recurring issue categories

**Technical Details:**
- AJAX UpdatePanel for async data refresh
- Stored procedure `sp_GetDashboardMetrics` for optimized queries
- JSON serialization for chart data binding

#### 2. Email Notifications ✓
**Implementation:**
- Automatic alerts on incident creation (Severity 4-5)
- Daily digest of open incidents to department managers
- Reminder emails for overdue corrective actions

**Technical Details:**
- Async email sending to avoid blocking UI
- SMTP configuration in Web.config
- HTML email templates with incident details
- Retry logic for failed deliveries

#### 3. Advanced Search & Filtering ✓
**Implementation:**
- Multi-criteria search (Date Range, Department, Severity, Status, Keyword)
- Real-time results update using AJAX
- Search history saved in Session
- Export filtered results to Excel

**Technical Details:**
- Dynamic SQL generation with parameterized queries (SQL injection prevention)
- Debounced text input to reduce server load
- GridView filtering without full page postback

#### 4. Excel Export
**Implementation:**
- Export incident list with all filters applied
- Formatted Excel with headers, borders, and conditional formatting
- Separate sheets for Incidents and Related Actions

**Technical Details:**
- ClosedXML library for Excel generation
- Stream response to browser without temp files
- Cell styling for severity levels (Red = Critical, Yellow = Moderate)

## Development Setup

### Prerequisites
- Visual Studio 2019/2022
- SQL Server 2016+ (Express Edition acceptable)
- IIS Express (included with Visual Studio)

### Database Setup

1. Execute `DatabaseSetup.sql` to create schema
2. Execute `SeedData.sql` to populate reference data
3. Update connection string in `Web.config`:

```xml
<connectionStrings>
    <add name="IncidentDB" 
         connectionString="Server=localhost;Database=IncidentManagement;Integrated Security=true;" 
         providerName="System.Data.SqlClient" />
</connectionStrings>
```

### Application Setup

1. Clone repository
2. Open `IncidentManagement.sln` in Visual Studio
3. Restore NuGet packages
4. Build solution (Ctrl+Shift+B)
5. Run (F5)

Default URL: `http://localhost:55123/`

### Configuration

**Web.config - AppSettings:**
```xml
<appSettings>
    <add key="AlertEmail.Enabled" value="true" />
    <add key="AlertEmail.CriticalSeverityThreshold" value="4" />
    <add key="AlertEmail.Recipients" value="safety@company.com" />
    <add key="SMTP.Host" value="smtp.gmail.com" />
    <add key="SMTP.Port" value="587" />
</appSettings>
```

## Code Standards

### Naming Conventions
- Page variables: `btnSave`, `txtTitle`, `ddlDepartment`
- Classes: PascalCase (`IncidentManager`)
- Methods: PascalCase (`GetIncidentById`)
- Private fields: `_fieldName`
- Constants: UPPER_CASE

### Error Handling
```csharp
try
{
    // Database operation
}
catch (SqlException sqlEx)
{
    // Log to file
    Logger.LogError(sqlEx);
    // Show user-friendly message
    lblError.Text = "Unable to process request. Please contact support.";
}
```

### Security
- Parameterized queries for all database operations
- Input validation on both client and server
- XSS prevention via `Server.HtmlEncode()`
- Role-based access control for sensitive operations

## Testing

### Test Data
The `SeedData.sql` script creates:
- 5 departments
- 10 users (including safety officers)
- 50 sample incidents across 6 months
- 75 corrective actions

### Manual Test Cases
1. Create incident with all required fields → Success
2. Create incident with Severity 5 → Email sent to safety@company.com
3. Filter incidents by date range → Correct results displayed
4. Export filtered results → Excel file downloads
5. Edit incident status to 'Closed' → LastModifiedDate updates

## Deployment

### Windows Server Setup

1. Install IIS with ASP.NET 4.7+ support
2. Create application pool (.NET Framework v4.0, Integrated Pipeline)
3. Deploy application files to `C:\inetpub\wwwroot\IncidentManagement`
4. Configure SQL Server connection (update Web.config)
5. Set folder permissions for IIS_IUSRS

### Connection String (Production)
```xml
<connectionStrings>
    <add name="IncidentDB" 
         connectionString="Server=prod-sql-server;Database=IncidentManagement;User Id=app_user;Password=***;" 
         providerName="System.Data.SqlClient" />
</connectionStrings>
```

## Performance Considerations

### Database Optimization
- Indexes on all foreign keys
- Stored procedures for complex queries (avoid N+1 problem)
- Pagination to limit result sets
- Archive old incidents (Status = 'Archived') to reduce table size

### ViewState Management
- Disabled ViewState on read-only controls
- GridView: `EnableViewState="false"` (data rebound on every postback)
- Use Session for large filter objects instead of ViewState

### Caching Strategy
```csharp
// Cache department list (rarely changes)
if (Cache["Departments"] == null)
{
    Cache["Departments"] = DatabaseHelper.GetDepartments();
    Cache.Timeout = TimeSpan.FromHours(24);
}
```

## Future Enhancements

- Mobile-responsive incident reporting form
- REST API for integration with other systems
- Advanced analytics with ML-based risk prediction
- Multi-language support (Hebrew/English)
- Document attachment (photos of incident scene)

## Project Structure

```
/IncidentManagement
├── /BusinessLogic
│   ├── IncidentManager.cs
│   ├── NotificationService.cs
│   └── ReportGenerator.cs
├── /DataAccess
│   ├── DatabaseHelper.cs
│   ├── IncidentRepository.cs
│   └── UserRepository.cs
├── /Models
│   ├── Incident.cs
│   ├── IncidentAction.cs
│   ├── Department.cs
│   └── User.cs
├── /UserControls
│   ├── IncidentSummary.ascx
│   ├── FilterPanel.ascx
│   └── ActionTracker.ascx
├── /Assets
│   ├── /css
│   │   └── site.css
│   ├── /js
│   │   ├── charts.js
│   │   └── validation.js
│   └── /images
├── /Database
│   ├── DatabaseSetup.sql
│   ├── SeedData.sql
│   └── StoredProcedures.sql
├── Default.aspx (Dashboard)
├── IncidentList.aspx
├── IncidentForm.aspx
├── Reports.aspx
├── Web.config
└── README.md
```


