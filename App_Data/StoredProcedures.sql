-- =============================================
-- Incident Management System - Stored Procedures
-- Version: 1.0
-- Description: All stored procedures for CRUD operations and reporting
-- =============================================

USE IncidentManagement;
GO

-- =============================================
-- DROP EXISTING STORED PROCEDURES
-- =============================================
IF OBJECT_ID('sp_GetAllIncidents', 'P') IS NOT NULL DROP PROCEDURE sp_GetAllIncidents;
IF OBJECT_ID('sp_GetIncidentById', 'P') IS NOT NULL DROP PROCEDURE sp_GetIncidentById;
IF OBJECT_ID('sp_InsertIncident', 'P') IS NOT NULL DROP PROCEDURE sp_InsertIncident;
IF OBJECT_ID('sp_UpdateIncident', 'P') IS NOT NULL DROP PROCEDURE sp_UpdateIncident;
IF OBJECT_ID('sp_DeleteIncident', 'P') IS NOT NULL DROP PROCEDURE sp_DeleteIncident;
IF OBJECT_ID('sp_SearchIncidents', 'P') IS NOT NULL DROP PROCEDURE sp_SearchIncidents;
IF OBJECT_ID('sp_GetIncidentActions', 'P') IS NOT NULL DROP PROCEDURE sp_GetIncidentActions;
IF OBJECT_ID('sp_InsertIncidentAction', 'P') IS NOT NULL DROP PROCEDURE sp_InsertIncidentAction;
IF OBJECT_ID('sp_UpdateIncidentAction', 'P') IS NOT NULL DROP PROCEDURE sp_UpdateIncidentAction;
IF OBJECT_ID('sp_GetDashboardMetrics', 'P') IS NOT NULL DROP PROCEDURE sp_GetDashboardMetrics;
IF OBJECT_ID('sp_GetIncidentsByMonth', 'P') IS NOT NULL DROP PROCEDURE sp_GetIncidentsByMonth;
IF OBJECT_ID('sp_GetIncidentsByDepartment', 'P') IS NOT NULL DROP PROCEDURE sp_GetIncidentsByDepartment;
IF OBJECT_ID('sp_GetIncidentsBySeverity', 'P') IS NOT NULL DROP PROCEDURE sp_GetIncidentsBySeverity;
IF OBJECT_ID('sp_GetTopCategories', 'P') IS NOT NULL DROP PROCEDURE sp_GetTopCategories;
IF OBJECT_ID('sp_GetDepartments', 'P') IS NOT NULL DROP PROCEDURE sp_GetDepartments;
IF OBJECT_ID('sp_GetLocations', 'P') IS NOT NULL DROP PROCEDURE sp_GetLocations;
IF OBJECT_ID('sp_GetCategories', 'P') IS NOT NULL DROP PROCEDURE sp_GetCategories;
IF OBJECT_ID('sp_GetUsers', 'P') IS NOT NULL DROP PROCEDURE sp_GetUsers;
IF OBJECT_ID('sp_GetOverdueActions', 'P') IS NOT NULL DROP PROCEDURE sp_GetOverdueActions;
GO

-- =============================================
-- INCIDENT CRUD OPERATIONS
-- =============================================

-- Get All Incidents with Pagination and Sorting
CREATE PROCEDURE sp_GetAllIncidents
    @PageNumber INT = 1,
    @PageSize INT = 20,
    @SortColumn NVARCHAR(50) = 'IncidentDate',
    @SortDirection NVARCHAR(4) = 'DESC'
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Offset INT = (@PageNumber - 1) * @PageSize;

    -- Build dynamic SQL for sorting
    DECLARE @SQL NVARCHAR(MAX);
    SET @SQL = '
    SELECT
        i.IncidentID,
        i.Title,
        i.Description,
        i.Severity,
        i.IncidentDate,
        i.Status,
        i.InjuriesReported,
        i.WitnessCount,
        i.EstimatedCost,
        d.DepartmentName,
        l.LocationName,
        c.CategoryName,
        u.FullName AS ReportedBy,
        i.CreatedDate,
        i.LastModifiedDate,
        COUNT(*) OVER() AS TotalRecords
    FROM dbo.Incidents i
    INNER JOIN dbo.Departments d ON i.DepartmentID = d.DepartmentID
    INNER JOIN dbo.Locations l ON i.LocationID = l.LocationID
    INNER JOIN dbo.Categories c ON i.CategoryID = c.CategoryID
    INNER JOIN dbo.Users u ON i.ReportedByUserID = u.UserID
    WHERE i.Status <> ''Archived''
    ORDER BY ' + QUOTENAME(@SortColumn) + ' ' + @SortDirection + '
    OFFSET @Offset ROWS
    FETCH NEXT @PageSize ROWS ONLY';

    EXEC sp_executesql @SQL, N'@Offset INT, @PageSize INT', @Offset, @PageSize;
END
GO

-- Get Incident By ID with full details
CREATE PROCEDURE sp_GetIncidentById
    @IncidentID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        i.IncidentID,
        i.Title,
        i.Description,
        i.Severity,
        i.IncidentDate,
        i.LocationID,
        i.DepartmentID,
        i.CategoryID,
        i.ReportedByUserID,
        i.Status,
        i.RootCause,
        i.InjuriesReported,
        i.WitnessCount,
        i.EstimatedCost,
        i.CreatedDate,
        i.LastModifiedDate,
        i.ClosedDate,
        i.ClosedByUserID,
        d.DepartmentName,
        l.LocationName,
        c.CategoryName,
        u.FullName AS ReportedBy,
        u.Email AS ReporterEmail,
        cb.FullName AS ClosedBy
    FROM dbo.Incidents i
    INNER JOIN dbo.Departments d ON i.DepartmentID = d.DepartmentID
    INNER JOIN dbo.Locations l ON i.LocationID = l.LocationID
    INNER JOIN dbo.Categories c ON i.CategoryID = c.CategoryID
    INNER JOIN dbo.Users u ON i.ReportedByUserID = u.UserID
    LEFT JOIN dbo.Users cb ON i.ClosedByUserID = cb.UserID
    WHERE i.IncidentID = @IncidentID;
END
GO

-- Insert New Incident
CREATE PROCEDURE sp_InsertIncident
    @Title NVARCHAR(200),
    @Description NVARCHAR(MAX),
    @Severity TINYINT,
    @IncidentDate DATETIME,
    @LocationID INT,
    @DepartmentID INT,
    @CategoryID INT,
    @ReportedByUserID INT,
    @Status NVARCHAR(50) = 'Open',
    @RootCause NVARCHAR(MAX) = NULL,
    @InjuriesReported BIT = 0,
    @WitnessCount INT = 0,
    @EstimatedCost DECIMAL(18,2) = NULL,
    @NewIncidentID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.Incidents (
        Title, Description, Severity, IncidentDate,
        LocationID, DepartmentID, CategoryID, ReportedByUserID,
        Status, RootCause, InjuriesReported, WitnessCount, EstimatedCost
    )
    VALUES (
        @Title, @Description, @Severity, @IncidentDate,
        @LocationID, @DepartmentID, @CategoryID, @ReportedByUserID,
        @Status, @RootCause, @InjuriesReported, @WitnessCount, @EstimatedCost
    );

    SET @NewIncidentID = SCOPE_IDENTITY();

    SELECT @NewIncidentID AS IncidentID;
END
GO

-- Update Incident
CREATE PROCEDURE sp_UpdateIncident
    @IncidentID INT,
    @Title NVARCHAR(200),
    @Description NVARCHAR(MAX),
    @Severity TINYINT,
    @IncidentDate DATETIME,
    @LocationID INT,
    @DepartmentID INT,
    @CategoryID INT,
    @Status NVARCHAR(50),
    @RootCause NVARCHAR(MAX) = NULL,
    @InjuriesReported BIT,
    @WitnessCount INT,
    @EstimatedCost DECIMAL(18,2) = NULL,
    @ClosedByUserID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.Incidents
    SET
        Title = @Title,
        Description = @Description,
        Severity = @Severity,
        IncidentDate = @IncidentDate,
        LocationID = @LocationID,
        DepartmentID = @DepartmentID,
        CategoryID = @CategoryID,
        Status = @Status,
        RootCause = @RootCause,
        InjuriesReported = @InjuriesReported,
        WitnessCount = @WitnessCount,
        EstimatedCost = @EstimatedCost,
        ClosedByUserID = CASE WHEN @Status = 'Closed' THEN @ClosedByUserID ELSE ClosedByUserID END
    WHERE IncidentID = @IncidentID;

    SELECT @@ROWCOUNT AS RowsAffected;
END
GO

-- Soft Delete Incident (Archive)
CREATE PROCEDURE sp_DeleteIncident
    @IncidentID INT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.Incidents
    SET Status = 'Archived'
    WHERE IncidentID = @IncidentID;

    SELECT @@ROWCOUNT AS RowsAffected;
END
GO

-- Search Incidents with Multiple Filters
CREATE PROCEDURE sp_SearchIncidents
    @Keyword NVARCHAR(200) = NULL,
    @DepartmentID INT = NULL,
    @LocationID INT = NULL,
    @CategoryID INT = NULL,
    @Severity TINYINT = NULL,
    @Status NVARCHAR(50) = NULL,
    @StartDate DATETIME = NULL,
    @EndDate DATETIME = NULL,
    @PageNumber INT = 1,
    @PageSize INT = 20
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Offset INT = (@PageNumber - 1) * @PageSize;

    SELECT
        i.IncidentID,
        i.Title,
        i.Description,
        i.Severity,
        i.IncidentDate,
        i.Status,
        i.InjuriesReported,
        d.DepartmentName,
        l.LocationName,
        c.CategoryName,
        u.FullName AS ReportedBy,
        i.CreatedDate,
        COUNT(*) OVER() AS TotalRecords
    FROM dbo.Incidents i
    INNER JOIN dbo.Departments d ON i.DepartmentID = d.DepartmentID
    INNER JOIN dbo.Locations l ON i.LocationID = l.LocationID
    INNER JOIN dbo.Categories c ON i.CategoryID = c.CategoryID
    INNER JOIN dbo.Users u ON i.ReportedByUserID = u.UserID
    WHERE
        (@Keyword IS NULL OR i.Title LIKE '%' + @Keyword + '%' OR i.Description LIKE '%' + @Keyword + '%')
        AND (@DepartmentID IS NULL OR i.DepartmentID = @DepartmentID)
        AND (@LocationID IS NULL OR i.LocationID = @LocationID)
        AND (@CategoryID IS NULL OR i.CategoryID = @CategoryID)
        AND (@Severity IS NULL OR i.Severity = @Severity)
        AND (@Status IS NULL OR i.Status = @Status)
        AND (@StartDate IS NULL OR i.IncidentDate >= @StartDate)
        AND (@EndDate IS NULL OR i.IncidentDate <= @EndDate)
        AND i.Status <> 'Archived'
    ORDER BY i.IncidentDate DESC
    OFFSET @Offset ROWS
    FETCH NEXT @PageSize ROWS ONLY;
END
GO

-- =============================================
-- INCIDENT ACTIONS OPERATIONS
-- =============================================

-- Get Actions for an Incident
CREATE PROCEDURE sp_GetIncidentActions
    @IncidentID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        ia.ActionID,
        ia.IncidentID,
        ia.ActionDescription,
        ia.ActionType,
        ia.AssignedToUserID,
        ia.CreatedByUserID,
        ia.DueDate,
        ia.CompletedDate,
        ia.Status,
        ia.Notes,
        ia.CreatedDate,
        ia.LastModifiedDate,
        u1.FullName AS AssignedTo,
        u1.Email AS AssigneeEmail,
        u2.FullName AS CreatedBy
    FROM dbo.IncidentActions ia
    INNER JOIN dbo.Users u1 ON ia.AssignedToUserID = u1.UserID
    INNER JOIN dbo.Users u2 ON ia.CreatedByUserID = u2.UserID
    WHERE ia.IncidentID = @IncidentID
    ORDER BY ia.CreatedDate DESC;
END
GO

-- Insert New Action
CREATE PROCEDURE sp_InsertIncidentAction
    @IncidentID INT,
    @ActionDescription NVARCHAR(500),
    @ActionType NVARCHAR(50),
    @AssignedToUserID INT,
    @CreatedByUserID INT,
    @DueDate DATETIME = NULL,
    @Status NVARCHAR(50) = 'Pending',
    @Notes NVARCHAR(MAX) = NULL,
    @NewActionID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.IncidentActions (
        IncidentID, ActionDescription, ActionType,
        AssignedToUserID, CreatedByUserID, DueDate, Status, Notes
    )
    VALUES (
        @IncidentID, @ActionDescription, @ActionType,
        @AssignedToUserID, @CreatedByUserID, @DueDate, @Status, @Notes
    );

    SET @NewActionID = SCOPE_IDENTITY();

    SELECT @NewActionID AS ActionID;
END
GO

-- Update Action
CREATE PROCEDURE sp_UpdateIncidentAction
    @ActionID INT,
    @ActionDescription NVARCHAR(500),
    @ActionType NVARCHAR(50),
    @AssignedToUserID INT,
    @DueDate DATETIME = NULL,
    @CompletedDate DATETIME = NULL,
    @Status NVARCHAR(50),
    @Notes NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.IncidentActions
    SET
        ActionDescription = @ActionDescription,
        ActionType = @ActionType,
        AssignedToUserID = @AssignedToUserID,
        DueDate = @DueDate,
        CompletedDate = @CompletedDate,
        Status = @Status,
        Notes = @Notes
    WHERE ActionID = @ActionID;

    SELECT @@ROWCOUNT AS RowsAffected;
END
GO

-- Get Overdue Actions
CREATE PROCEDURE sp_GetOverdueActions
AS
BEGIN
    SET NOCOUNT ON;

    SELECT * FROM vw_OverdueActions
    ORDER BY DaysOverdue DESC;
END
GO

-- =============================================
-- DASHBOARD AND REPORTING PROCEDURES
-- =============================================

-- Get Dashboard Metrics
CREATE PROCEDURE sp_GetDashboardMetrics
AS
BEGIN
    SET NOCOUNT ON;

    -- Total Incidents (Last 6 months)
    SELECT COUNT(*) AS TotalIncidents
    FROM dbo.Incidents
    WHERE IncidentDate >= DATEADD(MONTH, -6, GETDATE())
        AND Status <> 'Archived';

    -- Open Incidents
    SELECT COUNT(*) AS OpenIncidents
    FROM dbo.Incidents
    WHERE Status IN ('Open', 'In Progress', 'Under Review');

    -- Closed Incidents
    SELECT COUNT(*) AS ClosedIncidents
    FROM dbo.Incidents
    WHERE Status = 'Closed'
        AND IncidentDate >= DATEADD(MONTH, -6, GETDATE());

    -- Average Resolution Time (Days)
    SELECT AVG(DATEDIFF(DAY, IncidentDate, ClosedDate)) AS AvgResolutionDays
    FROM dbo.Incidents
    WHERE Status = 'Closed'
        AND ClosedDate IS NOT NULL
        AND IncidentDate >= DATEADD(MONTH, -6, GETDATE());

    -- Critical Incidents (Severity 4-5)
    SELECT COUNT(*) AS CriticalIncidents
    FROM dbo.Incidents
    WHERE Severity >= 4
        AND IncidentDate >= DATEADD(MONTH, -6, GETDATE())
        AND Status <> 'Archived';

    -- Incidents with Injuries
    SELECT COUNT(*) AS IncidentsWithInjuries
    FROM dbo.Incidents
    WHERE InjuriesReported = 1
        AND IncidentDate >= DATEADD(MONTH, -6, GETDATE())
        AND Status <> 'Archived';

    -- Overdue Actions Count
    SELECT COUNT(*) AS OverdueActions
    FROM dbo.IncidentActions
    WHERE Status IN ('Pending', 'In Progress')
        AND DueDate < GETDATE();

    -- Pending Actions Count
    SELECT COUNT(*) AS PendingActions
    FROM dbo.IncidentActions
    WHERE Status IN ('Pending', 'In Progress');
END
GO

-- Get Incidents By Month (Last 12 months)
CREATE PROCEDURE sp_GetIncidentsByMonth
    @MonthsBack INT = 12
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        YEAR(IncidentDate) AS Year,
        MONTH(IncidentDate) AS Month,
        DATENAME(MONTH, IncidentDate) AS MonthName,
        COUNT(*) AS IncidentCount
    FROM dbo.Incidents
    WHERE IncidentDate >= DATEADD(MONTH, -@MonthsBack, GETDATE())
        AND Status <> 'Archived'
    GROUP BY YEAR(IncidentDate), MONTH(IncidentDate), DATENAME(MONTH, IncidentDate)
    ORDER BY YEAR(IncidentDate), MONTH(IncidentDate);
END
GO

-- Get Incidents By Department
CREATE PROCEDURE sp_GetIncidentsByDepartment
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        d.DepartmentName,
        COUNT(*) AS IncidentCount,
        SUM(CASE WHEN i.Severity >= 4 THEN 1 ELSE 0 END) AS CriticalCount
    FROM dbo.Incidents i
    INNER JOIN dbo.Departments d ON i.DepartmentID = d.DepartmentID
    WHERE i.IncidentDate >= DATEADD(MONTH, -6, GETDATE())
        AND i.Status <> 'Archived'
    GROUP BY d.DepartmentName
    ORDER BY IncidentCount DESC;
END
GO

-- Get Incidents By Severity
CREATE PROCEDURE sp_GetIncidentsBySeverity
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        Severity,
        CASE Severity
            WHEN 1 THEN 'Low'
            WHEN 2 THEN 'Moderate'
            WHEN 3 THEN 'Significant'
            WHEN 4 THEN 'High'
            WHEN 5 THEN 'Critical'
        END AS SeverityLabel,
        COUNT(*) AS IncidentCount
    FROM dbo.Incidents
    WHERE IncidentDate >= DATEADD(MONTH, -6, GETDATE())
        AND Status <> 'Archived'
    GROUP BY Severity
    ORDER BY Severity;
END
GO

-- Get Top Categories
CREATE PROCEDURE sp_GetTopCategories
    @TopN INT = 5
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP (@TopN)
        c.CategoryName,
        COUNT(*) AS IncidentCount
    FROM dbo.Incidents i
    INNER JOIN dbo.Categories c ON i.CategoryID = c.CategoryID
    WHERE i.IncidentDate >= DATEADD(MONTH, -6, GETDATE())
        AND i.Status <> 'Archived'
    GROUP BY c.CategoryName
    ORDER BY IncidentCount DESC;
END
GO

-- =============================================
-- LOOKUP DATA PROCEDURES
-- =============================================

-- Get Departments
CREATE PROCEDURE sp_GetDepartments
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        DepartmentID,
        DepartmentName,
        DepartmentCode,
        ManagerUserID
    FROM dbo.Departments
    WHERE IsActive = 1
    ORDER BY DepartmentName;
END
GO

-- Get Locations
CREATE PROCEDURE sp_GetLocations
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        LocationID,
        LocationName,
        LocationCode,
        Building,
        Floor,
        Description
    FROM dbo.Locations
    WHERE IsActive = 1
    ORDER BY LocationName;
END
GO

-- Get Categories
CREATE PROCEDURE sp_GetCategories
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        CategoryID,
        CategoryName,
        CategoryCode,
        Description
    FROM dbo.Categories
    WHERE IsActive = 1
    ORDER BY CategoryName;
END
GO

-- Get Users
CREATE PROCEDURE sp_GetUsers
    @Role NVARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        UserID,
        Username,
        Email,
        FullName,
        Role,
        DepartmentID
    FROM dbo.Users
    WHERE IsActive = 1
        AND (@Role IS NULL OR Role = @Role)
    ORDER BY FullName;
END
GO

PRINT '===================================';
PRINT 'Stored Procedures created successfully!';
PRINT '===================================';
PRINT 'Total Procedures: 18';
PRINT '- Incident CRUD: 5';
PRINT '- Incident Actions: 4';
PRINT '- Dashboard Metrics: 5';
PRINT '- Lookup Data: 4';
PRINT '===================================';
GO
