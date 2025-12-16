-- =============================================
-- Incident Management System - Database Setup
-- Version: 1.0
-- Description: Creates database schema with all tables, indexes, and constraints
-- =============================================

USE master;
GO

-- Create Database
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'IncidentManagement')
BEGIN
    CREATE DATABASE IncidentManagement;
    PRINT 'Database IncidentManagement created successfully.';
END
ELSE
BEGIN
    PRINT 'Database IncidentManagement already exists.';
END
GO

USE IncidentManagement;
GO

-- =============================================
-- Drop existing tables (for clean reinstall)
-- =============================================
IF OBJECT_ID('dbo.IncidentActions', 'U') IS NOT NULL DROP TABLE dbo.IncidentActions;
IF OBJECT_ID('dbo.Incidents', 'U') IS NOT NULL DROP TABLE dbo.Incidents;
IF OBJECT_ID('dbo.Categories', 'U') IS NOT NULL DROP TABLE dbo.Categories;
IF OBJECT_ID('dbo.Locations', 'U') IS NOT NULL DROP TABLE dbo.Locations;
IF OBJECT_ID('dbo.Departments', 'U') IS NOT NULL DROP TABLE dbo.Departments;
IF OBJECT_ID('dbo.Users', 'U') IS NOT NULL DROP TABLE dbo.Users;
GO

-- =============================================
-- Create Tables
-- =============================================

-- Users Table
CREATE TABLE dbo.Users (
    UserID INT IDENTITY(1,1) PRIMARY KEY,
    Username NVARCHAR(100) NOT NULL UNIQUE,
    Email NVARCHAR(255) NOT NULL,
    FullName NVARCHAR(200) NOT NULL,
    Role NVARCHAR(50) NOT NULL, -- 'Admin', 'SafetyOfficer', 'Manager', 'Employee'
    DepartmentID INT NULL,
    IsActive BIT NOT NULL DEFAULT 1,
    CreatedDate DATETIME NOT NULL DEFAULT GETDATE(),
    LastLoginDate DATETIME NULL,
    CONSTRAINT CHK_Users_Role CHECK (Role IN ('Admin', 'SafetyOfficer', 'Manager', 'Employee'))
);

-- Departments Table
CREATE TABLE dbo.Departments (
    DepartmentID INT IDENTITY(1,1) PRIMARY KEY,
    DepartmentName NVARCHAR(200) NOT NULL,
    DepartmentCode NVARCHAR(50) NOT NULL UNIQUE,
    ManagerUserID INT NULL,
    IsActive BIT NOT NULL DEFAULT 1,
    CreatedDate DATETIME NOT NULL DEFAULT GETDATE()
);

-- Locations Table
CREATE TABLE dbo.Locations (
    LocationID INT IDENTITY(1,1) PRIMARY KEY,
    LocationName NVARCHAR(200) NOT NULL,
    LocationCode NVARCHAR(50) NOT NULL UNIQUE,
    Building NVARCHAR(100) NULL,
    Floor NVARCHAR(50) NULL,
    Description NVARCHAR(500) NULL,
    IsActive BIT NOT NULL DEFAULT 1,
    CreatedDate DATETIME NOT NULL DEFAULT GETDATE()
);

-- Categories Table
CREATE TABLE dbo.Categories (
    CategoryID INT IDENTITY(1,1) PRIMARY KEY,
    CategoryName NVARCHAR(200) NOT NULL,
    CategoryCode NVARCHAR(50) NOT NULL UNIQUE,
    Description NVARCHAR(500) NULL,
    IsActive BIT NOT NULL DEFAULT 1,
    CreatedDate DATETIME NOT NULL DEFAULT GETDATE()
);

-- Incidents Table
CREATE TABLE dbo.Incidents (
    IncidentID INT IDENTITY(1,1) PRIMARY KEY,
    Title NVARCHAR(200) NOT NULL,
    Description NVARCHAR(MAX) NULL,
    Severity TINYINT NOT NULL, -- 1 (Low) to 5 (Critical)
    IncidentDate DATETIME NOT NULL,
    LocationID INT NOT NULL,
    DepartmentID INT NOT NULL,
    CategoryID INT NOT NULL,
    ReportedByUserID INT NOT NULL,
    Status NVARCHAR(50) NOT NULL DEFAULT 'Open',
    RootCause NVARCHAR(MAX) NULL,
    InjuriesReported BIT NOT NULL DEFAULT 0,
    WitnessCount INT NOT NULL DEFAULT 0,
    EstimatedCost DECIMAL(18,2) NULL,
    CreatedDate DATETIME NOT NULL DEFAULT GETDATE(),
    LastModifiedDate DATETIME NOT NULL DEFAULT GETDATE(),
    ClosedDate DATETIME NULL,
    ClosedByUserID INT NULL,

    CONSTRAINT FK_Incidents_Locations FOREIGN KEY (LocationID) REFERENCES dbo.Locations(LocationID),
    CONSTRAINT FK_Incidents_Departments FOREIGN KEY (DepartmentID) REFERENCES dbo.Departments(DepartmentID),
    CONSTRAINT FK_Incidents_Categories FOREIGN KEY (CategoryID) REFERENCES dbo.Categories(CategoryID),
    CONSTRAINT FK_Incidents_ReportedByUser FOREIGN KEY (ReportedByUserID) REFERENCES dbo.Users(UserID),
    CONSTRAINT FK_Incidents_ClosedByUser FOREIGN KEY (ClosedByUserID) REFERENCES dbo.Users(UserID),
    CONSTRAINT CHK_Incidents_Severity CHECK (Severity BETWEEN 1 AND 5),
    CONSTRAINT CHK_Incidents_Status CHECK (Status IN ('Open', 'In Progress', 'Under Review', 'Closed', 'Archived'))
);

-- IncidentActions Table
CREATE TABLE dbo.IncidentActions (
    ActionID INT IDENTITY(1,1) PRIMARY KEY,
    IncidentID INT NOT NULL,
    ActionDescription NVARCHAR(500) NOT NULL,
    ActionType NVARCHAR(50) NOT NULL, -- 'Corrective', 'Preventive', 'Investigation'
    AssignedToUserID INT NOT NULL,
    CreatedByUserID INT NOT NULL,
    DueDate DATETIME NULL,
    CompletedDate DATETIME NULL,
    Status NVARCHAR(50) NOT NULL DEFAULT 'Pending',
    Notes NVARCHAR(MAX) NULL,
    CreatedDate DATETIME NOT NULL DEFAULT GETDATE(),
    LastModifiedDate DATETIME NOT NULL DEFAULT GETDATE(),

    CONSTRAINT FK_IncidentActions_Incidents FOREIGN KEY (IncidentID) REFERENCES dbo.Incidents(IncidentID) ON DELETE CASCADE,
    CONSTRAINT FK_IncidentActions_AssignedToUser FOREIGN KEY (AssignedToUserID) REFERENCES dbo.Users(UserID),
    CONSTRAINT FK_IncidentActions_CreatedByUser FOREIGN KEY (CreatedByUserID) REFERENCES dbo.Users(UserID),
    CONSTRAINT CHK_IncidentActions_Status CHECK (Status IN ('Pending', 'In Progress', 'Completed', 'Cancelled')),
    CONSTRAINT CHK_IncidentActions_ActionType CHECK (ActionType IN ('Corrective', 'Preventive', 'Investigation'))
);

GO

-- =============================================
-- Create Indexes for Performance
-- =============================================

-- Incidents Table Indexes
CREATE NONCLUSTERED INDEX IX_Incidents_Status ON dbo.Incidents(Status) INCLUDE (IncidentDate, Severity);
CREATE NONCLUSTERED INDEX IX_Incidents_IncidentDate ON dbo.Incidents(IncidentDate DESC) INCLUDE (Status, Severity);
CREATE NONCLUSTERED INDEX IX_Incidents_Severity ON dbo.Incidents(Severity DESC) INCLUDE (Status, IncidentDate);
CREATE NONCLUSTERED INDEX IX_Incidents_Department ON dbo.Incidents(DepartmentID) INCLUDE (Status, IncidentDate);
CREATE NONCLUSTERED INDEX IX_Incidents_Category ON dbo.Incidents(CategoryID) INCLUDE (Status, IncidentDate);
CREATE NONCLUSTERED INDEX IX_Incidents_Location ON dbo.Incidents(LocationID) INCLUDE (Status, IncidentDate);
CREATE NONCLUSTERED INDEX IX_Incidents_ReportedBy ON dbo.Incidents(ReportedByUserID) INCLUDE (Status, IncidentDate);

-- IncidentActions Table Indexes
CREATE NONCLUSTERED INDEX IX_IncidentActions_Incident ON dbo.IncidentActions(IncidentID) INCLUDE (Status, DueDate);
CREATE NONCLUSTERED INDEX IX_IncidentActions_AssignedTo ON dbo.IncidentActions(AssignedToUserID) INCLUDE (Status, DueDate);
CREATE NONCLUSTERED INDEX IX_IncidentActions_Status ON dbo.IncidentActions(Status) INCLUDE (DueDate);
CREATE NONCLUSTERED INDEX IX_IncidentActions_DueDate ON dbo.IncidentActions(DueDate) INCLUDE (Status);

-- Users Table Index
CREATE NONCLUSTERED INDEX IX_Users_Department ON dbo.Users(DepartmentID) INCLUDE (IsActive);
CREATE NONCLUSTERED INDEX IX_Users_Email ON dbo.Users(Email);

GO

-- =============================================
-- Create Foreign Key for Department Manager
-- =============================================
ALTER TABLE dbo.Departments
ADD CONSTRAINT FK_Departments_ManagerUser FOREIGN KEY (ManagerUserID) REFERENCES dbo.Users(UserID);

ALTER TABLE dbo.Users
ADD CONSTRAINT FK_Users_Departments FOREIGN KEY (DepartmentID) REFERENCES dbo.Departments(DepartmentID);

GO

-- =============================================
-- Create Triggers for LastModifiedDate
-- =============================================

-- Trigger for Incidents
CREATE TRIGGER trg_Incidents_UpdateModifiedDate
ON dbo.Incidents
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.Incidents
    SET LastModifiedDate = GETDATE()
    FROM dbo.Incidents i
    INNER JOIN inserted ins ON i.IncidentID = ins.IncidentID;
END
GO

-- Trigger for IncidentActions
CREATE TRIGGER trg_IncidentActions_UpdateModifiedDate
ON dbo.IncidentActions
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.IncidentActions
    SET LastModifiedDate = GETDATE()
    FROM dbo.IncidentActions ia
    INNER JOIN inserted ins ON ia.ActionID = ins.ActionID;
END
GO

-- Trigger to update Incident ClosedDate when Status changes to Closed
CREATE TRIGGER trg_Incidents_SetClosedDate
ON dbo.Incidents
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.Incidents
    SET ClosedDate = GETDATE()
    FROM dbo.Incidents i
    INNER JOIN inserted ins ON i.IncidentID = ins.IncidentID
    INNER JOIN deleted del ON i.IncidentID = del.IncidentID
    WHERE ins.Status = 'Closed' AND del.Status <> 'Closed' AND i.ClosedDate IS NULL;
END
GO

-- =============================================
-- Create Views for Common Queries
-- =============================================

-- View for Open Incidents with Details
CREATE VIEW vw_OpenIncidents AS
SELECT
    i.IncidentID,
    i.Title,
    i.Description,
    i.Severity,
    i.IncidentDate,
    i.Status,
    d.DepartmentName,
    l.LocationName,
    c.CategoryName,
    u.FullName AS ReportedBy,
    u.Email AS ReporterEmail,
    i.CreatedDate,
    i.LastModifiedDate,
    DATEDIFF(DAY, i.IncidentDate, GETDATE()) AS DaysOpen
FROM dbo.Incidents i
INNER JOIN dbo.Departments d ON i.DepartmentID = d.DepartmentID
INNER JOIN dbo.Locations l ON i.LocationID = l.LocationID
INNER JOIN dbo.Categories c ON i.CategoryID = c.CategoryID
INNER JOIN dbo.Users u ON i.ReportedByUserID = u.UserID
WHERE i.Status IN ('Open', 'In Progress', 'Under Review');
GO

-- View for Overdue Actions
CREATE VIEW vw_OverdueActions AS
SELECT
    ia.ActionID,
    ia.ActionDescription,
    ia.ActionType,
    ia.DueDate,
    ia.Status,
    i.IncidentID,
    i.Title AS IncidentTitle,
    i.Severity AS IncidentSeverity,
    u.FullName AS AssignedTo,
    u.Email AS AssigneeEmail,
    DATEDIFF(DAY, ia.DueDate, GETDATE()) AS DaysOverdue
FROM dbo.IncidentActions ia
INNER JOIN dbo.Incidents i ON ia.IncidentID = i.IncidentID
INNER JOIN dbo.Users u ON ia.AssignedToUserID = u.UserID
WHERE ia.Status IN ('Pending', 'In Progress')
    AND ia.DueDate < GETDATE();
GO

-- =============================================
-- Grant Permissions
-- =============================================

-- Grant execute permissions on stored procedures (will be created separately)
-- Grant select, insert, update permissions on tables

PRINT 'Database schema created successfully!';
PRINT 'Tables created: Users, Departments, Locations, Categories, Incidents, IncidentActions';
PRINT 'Indexes created for optimal query performance';
PRINT 'Triggers created for automatic timestamp updates';
PRINT 'Views created for common queries';
GO
