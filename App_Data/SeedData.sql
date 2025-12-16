-- =============================================
-- Incident Management System - Seed Data
-- Version: 1.0
-- Description: Populates database with test data
-- =============================================

USE IncidentManagement;
GO

-- =============================================
-- Insert Departments
-- =============================================
SET IDENTITY_INSERT dbo.Departments ON;

INSERT INTO dbo.Departments (DepartmentID, DepartmentName, DepartmentCode, ManagerUserID, IsActive)
VALUES
    (1, 'Manufacturing', 'MFG', NULL, 1),
    (2, 'Warehouse & Logistics', 'WHL', NULL, 1),
    (3, 'Maintenance', 'MNT', NULL, 1),
    (4, 'Quality Assurance', 'QA', NULL, 1),
    (5, 'Administration', 'ADM', NULL, 1);

SET IDENTITY_INSERT dbo.Departments OFF;
GO

-- =============================================
-- Insert Users
-- =============================================
SET IDENTITY_INSERT dbo.Users ON;

INSERT INTO dbo.Users (UserID, Username, Email, FullName, Role, DepartmentID, IsActive)
VALUES
    (1, 'admin', 'admin@company.com', 'System Administrator', 'Admin', 5, 1),
    (2, 'jsafety', 'jsafety@company.com', 'John Safety', 'SafetyOfficer', 5, 1),
    (3, 'mmanager', 'mmanager@company.com', 'Mary Manager', 'Manager', 1, 1),
    (4, 'dsmith', 'dsmith@company.com', 'David Smith', 'Employee', 1, 1),
    (5, 'sjohnson', 'sjohnson@company.com', 'Sarah Johnson', 'Employee', 2, 1),
    (6, 'rbrown', 'rbrown@company.com', 'Robert Brown', 'Manager', 2, 1),
    (7, 'lwilliams', 'lwilliams@company.com', 'Lisa Williams', 'Employee', 3, 1),
    (8, 'kjones', 'kjones@company.com', 'Kevin Jones', 'Manager', 3, 1),
    (9, 'tgarcia', 'tgarcia@company.com', 'Thomas Garcia', 'Employee', 4, 1),
    (10, 'amartinez', 'amartinez@company.com', 'Anna Martinez', 'Manager', 4, 1);

SET IDENTITY_INSERT dbo.Users OFF;
GO

-- Update Department Managers
UPDATE dbo.Departments SET ManagerUserID = 3 WHERE DepartmentID = 1;
UPDATE dbo.Departments SET ManagerUserID = 6 WHERE DepartmentID = 2;
UPDATE dbo.Departments SET ManagerUserID = 8 WHERE DepartmentID = 3;
UPDATE dbo.Departments SET ManagerUserID = 10 WHERE DepartmentID = 4;
UPDATE dbo.Departments SET ManagerUserID = 1 WHERE DepartmentID = 5;
GO

-- =============================================
-- Insert Locations
-- =============================================
SET IDENTITY_INSERT dbo.Locations ON;

INSERT INTO dbo.Locations (LocationID, LocationName, LocationCode, Building, Floor, Description, IsActive)
VALUES
    (1, 'Production Floor A', 'PROD-A', 'Building 1', 'Ground', 'Main production line area', 1),
    (2, 'Production Floor B', 'PROD-B', 'Building 1', 'Ground', 'Secondary production line', 1),
    (3, 'Warehouse Zone 1', 'WH-Z1', 'Building 2', 'Ground', 'Raw materials storage', 1),
    (4, 'Warehouse Zone 2', 'WH-Z2', 'Building 2', 'Ground', 'Finished goods storage', 1),
    (5, 'Loading Dock', 'DOCK', 'Building 2', 'Ground', 'Shipping and receiving area', 1),
    (6, 'Maintenance Workshop', 'MNT-WS', 'Building 3', 'Ground', 'Equipment repair area', 1),
    (7, 'Chemical Storage', 'CHEM-ST', 'Building 1', 'Ground', 'Hazardous materials area', 1),
    (8, 'Office Area', 'OFFICE', 'Building 4', '2nd', 'Administrative offices', 1),
    (9, 'Parking Lot', 'PARK', 'Outdoor', 'N/A', 'Employee parking area', 1),
    (10, 'Cafeteria', 'CAFE', 'Building 4', '1st', 'Employee dining area', 1);

SET IDENTITY_INSERT dbo.Locations OFF;
GO

-- =============================================
-- Insert Categories
-- =============================================
SET IDENTITY_INSERT dbo.Categories ON;

INSERT INTO dbo.Categories (CategoryID, CategoryName, CategoryCode, Description, IsActive)
VALUES
    (1, 'Slip, Trip & Fall', 'FALL', 'Incidents involving slipping, tripping, or falling', 1),
    (2, 'Equipment Malfunction', 'EQUIP', 'Machinery or equipment failure', 1),
    (3, 'Chemical Spill', 'CHEM', 'Hazardous material spill or exposure', 1),
    (4, 'Fire/Explosion', 'FIRE', 'Fire or explosion incidents', 1),
    (5, 'Struck By Object', 'STRUCK', 'Injury from falling or flying objects', 1),
    (6, 'Electrical Hazard', 'ELEC', 'Electrical shock or hazard', 1),
    (7, 'Vehicle Accident', 'VEH', 'Forklift or vehicle-related incidents', 1),
    (8, 'Ergonomic Injury', 'ERGO', 'Repetitive strain or lifting injuries', 1),
    (9, 'Near Miss', 'NEAR', 'Incident with potential for injury but no harm occurred', 1),
    (10, 'Other', 'OTHER', 'Other safety incidents', 1);

SET IDENTITY_INSERT dbo.Categories OFF;
GO

-- =============================================
-- Insert Sample Incidents (50 incidents)
-- =============================================
SET IDENTITY_INSERT dbo.Incidents ON;

DECLARE @StartDate DATE = DATEADD(MONTH, -6, GETDATE());

-- Month 1 Incidents
INSERT INTO dbo.Incidents (IncidentID, Title, Description, Severity, IncidentDate, LocationID, DepartmentID, CategoryID, ReportedByUserID, Status, InjuriesReported, WitnessCount)
VALUES
    (1, 'Wet Floor Slip in Production Area', 'Employee slipped on wet floor near workstation 5. Minor bruising reported.', 2, DATEADD(DAY, 5, @StartDate), 1, 1, 1, 4, 'Closed', 1, 2),
    (2, 'Conveyor Belt Jam', 'Conveyor belt stopped unexpectedly causing production delay. No injuries.', 1, DATEADD(DAY, 8, @StartDate), 1, 1, 2, 3, 'Closed', 0, 0),
    (3, 'Chemical Leak in Storage', 'Minor chemical leak detected in storage area. Area evacuated and cleaned.', 4, DATEADD(DAY, 12, @StartDate), 7, 3, 3, 7, 'Closed', 0, 3),
    (4, 'Forklift Near Miss', 'Forklift nearly struck pedestrian in warehouse zone. Driver warned.', 3, DATEADD(DAY, 15, @StartDate), 3, 2, 9, 5, 'Closed', 0, 4),
    (5, 'Repetitive Strain Complaint', 'Employee reported wrist pain from repetitive packaging tasks.', 2, DATEADD(DAY, 18, @StartDate), 2, 1, 8, 4, 'In Progress', 0, 0);

-- Month 2 Incidents
INSERT INTO dbo.Incidents (IncidentID, Title, Description, Severity, IncidentDate, LocationID, DepartmentID, CategoryID, ReportedByUserID, Status, InjuriesReported, WitnessCount)
VALUES
    (6, 'Pallet Stack Collapse', 'Poorly stacked pallets fell in warehouse zone 2. No injuries.', 2, DATEADD(DAY, 35, @StartDate), 4, 2, 5, 5, 'Closed', 0, 2),
    (7, 'Electrical Panel Spark', 'Sparks observed from electrical panel in maintenance workshop. Power shut off immediately.', 4, DATEADD(DAY, 38, @StartDate), 6, 3, 6, 7, 'Closed', 0, 1),
    (8, 'Parking Lot Trip Hazard', 'Employee tripped over pothole in parking lot. Ankle sprain.', 2, DATEADD(DAY, 42, @StartDate), 9, 5, 1, 1, 'Closed', 1, 1),
    (9, 'Machine Guard Missing', 'Safety guard found missing on press machine. Machine tagged out.', 3, DATEADD(DAY, 45, @StartDate), 1, 1, 2, 3, 'Closed', 0, 0),
    (10, 'Chemical Fumes Complaint', 'Multiple employees reported strong chemical odors. Ventilation system checked.', 3, DATEADD(DAY, 48, @StartDate), 1, 1, 3, 4, 'Under Review', 0, 5);

-- Month 3 Incidents
INSERT INTO dbo.Incidents (IncidentID, Title, Description, Severity, IncidentDate, LocationID, DepartmentID, CategoryID, ReportedByUserID, Status, InjuriesReported, WitnessCount)
VALUES
    (11, 'Loading Dock Fall', 'Employee fell from loading dock. Fractured wrist reported.', 4, DATEADD(DAY, 65, @StartDate), 5, 2, 1, 5, 'Closed', 1, 3),
    (12, 'Spilled Oil in Workshop', 'Oil spill in maintenance workshop. Cleaned up within 30 minutes.', 1, DATEADD(DAY, 68, @StartDate), 6, 3, 3, 7, 'Closed', 0, 1),
    (13, 'Cafeteria Slip', 'Employee slipped on spilled beverage in cafeteria. No injury.', 1, DATEADD(DAY, 72, @StartDate), 10, 5, 1, 1, 'Closed', 0, 2),
    (14, 'Forklift Collision with Rack', 'Forklift driver collided with storage rack causing minor damage.', 3, DATEADD(DAY, 75, @StartDate), 3, 2, 7, 6, 'Closed', 0, 2),
    (15, 'Heat Stress Incident', 'Employee experienced heat exhaustion on production floor. First aid provided.', 3, DATEADD(DAY, 78, @StartDate), 1, 1, 10, 4, 'Closed', 1, 2);

-- Month 4 Incidents
INSERT INTO dbo.Incidents (IncidentID, Title, Description, Severity, IncidentDate, LocationID, DepartmentID, CategoryID, ReportedByUserID, Status, InjuriesReported, WitnessCount)
VALUES
    (16, 'Broken Staircase Railing', 'Railing found broken on staircase to office area. Repaired immediately.', 2, DATEADD(DAY, 95, @StartDate), 8, 5, 1, 1, 'Closed', 0, 0),
    (17, 'Compressed Air Hose Burst', 'Air hose burst causing loud noise and near miss. No injuries.', 2, DATEADD(DAY, 98, @StartDate), 6, 3, 2, 7, 'Closed', 0, 3),
    (18, 'Box Cutter Injury', 'Employee cut finger while opening carton. Minor laceration treated on-site.', 2, DATEADD(DAY, 102, @StartDate), 4, 2, 5, 5, 'Closed', 1, 1),
    (19, 'Emergency Exit Blocked', 'Emergency exit found blocked by equipment. Cleared immediately.', 3, DATEADD(DAY, 105, @StartDate), 2, 1, 10, 3, 'Closed', 0, 0),
    (20, 'Smoke Detector Malfunction', 'Smoke detector triggered false alarm in chemical storage. System tested.', 2, DATEADD(DAY, 108, @StartDate), 7, 3, 4, 7, 'Closed', 0, 4);

-- Month 5 Incidents
INSERT INTO dbo.Incidents (IncidentID, Title, Description, Severity, IncidentDate, LocationID, DepartmentID, CategoryID, ReportedByUserID, Status, InjuriesReported, WitnessCount)
VALUES
    (21, 'Overhead Crane Near Miss', 'Load swung dangerously close to worker. Operator retraining scheduled.', 4, DATEADD(DAY, 125, @StartDate), 1, 1, 5, 4, 'In Progress', 0, 2),
    (22, 'Dust Accumulation Fire Risk', 'Excessive dust buildup noted in production area. Cleaning scheduled.', 3, DATEADD(DAY, 128, @StartDate), 1, 1, 4, 3, 'Open', 0, 0),
    (23, 'Improper Lifting Technique', 'Employee observed using improper lifting technique. Training provided.', 1, DATEADD(DAY, 132, @StartDate), 4, 2, 8, 6, 'Closed', 0, 1),
    (24, 'First Aid Kit Empty', 'First aid kit found depleted in warehouse. Restocked immediately.', 2, DATEADD(DAY, 135, @StartDate), 3, 2, 10, 5, 'Closed', 0, 0),
    (25, 'Welding Spark Fire', 'Small fire started from welding sparks. Extinguished quickly by staff.', 4, DATEADD(DAY, 138, @StartDate), 6, 3, 4, 7, 'Closed', 0, 3);

-- Month 6 Incidents (Recent)
INSERT INTO dbo.Incidents (IncidentID, Title, Description, Severity, IncidentDate, LocationID, DepartmentID, CategoryID, ReportedByUserID, Status, InjuriesReported, WitnessCount)
VALUES
    (26, 'Power Tool Malfunction', 'Power drill malfunctioned during use. No injury but equipment damaged.', 2, DATEADD(DAY, 155, @StartDate), 6, 3, 2, 7, 'Open', 0, 1),
    (27, 'Vehicle Backup Incident', 'Delivery truck nearly backed into employee. Increased signage implemented.', 3, DATEADD(DAY, 158, @StartDate), 5, 2, 7, 6, 'In Progress', 0, 2),
    (28, 'Allergic Reaction to Cleaner', 'Employee had mild allergic reaction to new cleaning product. Product changed.', 3, DATEADD(DAY, 162, @StartDate), 8, 5, 3, 1, 'Closed', 1, 0),
    (29, 'Strained Back from Lifting', 'Employee strained back lifting heavy component. Medical attention received.', 3, DATEADD(DAY, 165, @StartDate), 1, 1, 8, 4, 'Open', 1, 1),
    (30, 'Inadequate Lighting Complaint', 'Multiple complaints about poor lighting in warehouse zone 1.', 2, DATEADD(DAY, 168, @StartDate), 3, 2, 10, 5, 'Open', 0, 0),
    (31, 'Pressurized Line Rupture', 'Hydraulic line ruptured spraying fluid. Area cleaned and line replaced.', 4, DATEADD(DAY, 170, @StartDate), 6, 3, 3, 8, 'Under Review', 0, 2),
    (32, 'Noise Level Concern', 'Noise levels measured above safe threshold in production area B.', 2, DATEADD(DAY, 172, @StartDate), 2, 1, 10, 3, 'Open', 0, 0),
    (33, 'Falling Tools from Height', 'Tools fell from elevated work platform. Safety protocols reviewed.', 3, DATEADD(DAY, 174, @StartDate), 1, 3, 5, 7, 'In Progress', 0, 2),
    (34, 'PPE Non-Compliance', 'Multiple employees observed not wearing required safety glasses.', 2, DATEADD(DAY, 176, @StartDate), 1, 1, 10, 3, 'Open', 0, 5),
    (35, 'Electrical Extension Cord Damage', 'Damaged extension cord discovered in use. Removed from service.', 2, DATEADD(DAY, 178, @StartDate), 6, 3, 6, 7, 'Closed', 0, 0);

-- Additional incidents to reach 50
INSERT INTO dbo.Incidents (IncidentID, Title, Description, Severity, IncidentDate, LocationID, DepartmentID, CategoryID, ReportedByUserID, Status, InjuriesReported, WitnessCount)
VALUES
    (36, 'Carpal Tunnel Complaint', 'Employee reported symptoms of carpal tunnel syndrome.', 2, DATEADD(DAY, 20, @StartDate), 2, 1, 8, 4, 'Closed', 0, 0),
    (37, 'Forklift Seat Belt Not Used', 'Forklift operator observed not using seat belt. Written warning issued.', 1, DATEADD(DAY, 50, @StartDate), 4, 2, 9, 6, 'Closed', 0, 1),
    (38, 'Lockout/Tagout Violation', 'Equipment found running during maintenance. Serious safety violation.', 5, DATEADD(DAY, 80, @StartDate), 1, 1, 2, 3, 'Closed', 0, 2),
    (39, 'Compressed Gas Cylinder Unsecured', 'Gas cylinder found unsecured in workshop. Immediately secured.', 2, DATEADD(DAY, 110, @StartDate), 6, 3, 10, 7, 'Closed', 0, 0),
    (40, 'Loose Concrete in Walkway', 'Tripping hazard from damaged concrete in walkway. Repair scheduled.', 2, DATEADD(DAY, 140, @StartDate), 9, 5, 1, 1, 'Open', 0, 0),
    (41, 'Inadequate Machine Guarding', 'Rotating parts accessible without proper guarding. Machine shut down.', 4, DATEADD(DAY, 25, @StartDate), 1, 1, 2, 3, 'Closed', 0, 1),
    (42, 'Material Handling Injury', 'Employee injured shoulder moving heavy materials without mechanical aid.', 3, DATEADD(DAY, 55, @StartDate), 4, 2, 8, 5, 'Closed', 1, 1),
    (43, 'Solvent Vapor Exposure', 'Employee exposed to solvent vapors due to inadequate ventilation.', 4, DATEADD(DAY, 85, @StartDate), 7, 3, 3, 7, 'Closed', 1, 2),
    (44, 'Defective Safety Harness', 'Safety harness found with frayed straps. Removed from service.', 3, DATEADD(DAY, 115, @StartDate), 1, 3, 2, 8, 'Closed', 0, 0),
    (45, 'Ice on Walkway', 'Employee slipped on icy walkway. Salt and sand applied.', 2, DATEADD(DAY, 145, @StartDate), 9, 5, 1, 1, 'Closed', 1, 2),
    (46, 'Unauthorized Chemical Storage', 'Chemicals found stored in unapproved location. Relocated immediately.', 3, DATEADD(DAY, 30, @StartDate), 2, 1, 3, 4, 'Closed', 0, 0),
    (47, 'Machine Start-up Surprise', 'Machine started unexpectedly startling nearby worker. No injury.', 2, DATEADD(DAY, 60, @StartDate), 1, 1, 9, 4, 'Closed', 0, 1),
    (48, 'Insufficient Aisle Width', 'Materials stored reducing aisle width below safe minimum.', 2, DATEADD(DAY, 90, @StartDate), 3, 2, 10, 5, 'Closed', 0, 0),
    (49, 'Burn from Hot Surface', 'Employee burned hand on hot equipment surface. First aid provided.', 2, DATEADD(DAY, 120, @StartDate), 1, 1, 10, 4, 'Closed', 1, 1),
    (50, 'Respirator Fit Test Overdue', 'Multiple employees found with expired respirator fit tests.', 2, DATEADD(DAY, 150, @StartDate), 7, 3, 10, 7, 'In Progress', 0, 0);

SET IDENTITY_INSERT dbo.Incidents OFF;
GO

-- =============================================
-- Insert Corrective Actions (75 actions)
-- =============================================
SET IDENTITY_INSERT dbo.IncidentActions ON;

-- Actions for various incidents
INSERT INTO dbo.IncidentActions (ActionID, IncidentID, ActionDescription, ActionType, AssignedToUserID, CreatedByUserID, DueDate, CompletedDate, Status)
VALUES
    -- Incident 1 Actions
    (1, 1, 'Install wet floor warning signs in production area', 'Corrective', 7, 2, DATEADD(DAY, 3, DATEADD(DAY, 5, @StartDate)), DATEADD(DAY, 2, DATEADD(DAY, 5, @StartDate)), 'Completed'),
    (2, 1, 'Review cleaning procedures with janitorial staff', 'Preventive', 8, 2, DATEADD(DAY, 7, DATEADD(DAY, 5, @StartDate)), DATEADD(DAY, 5, DATEADD(DAY, 5, @StartDate)), 'Completed'),

    -- Incident 2 Actions
    (3, 2, 'Perform full maintenance check on conveyor belt', 'Corrective', 7, 2, DATEADD(DAY, 2, DATEADD(DAY, 8, @StartDate)), DATEADD(DAY, 2, DATEADD(DAY, 8, @StartDate)), 'Completed'),
    (4, 2, 'Implement monthly conveyor inspection schedule', 'Preventive', 8, 2, DATEADD(DAY, 30, DATEADD(DAY, 8, @StartDate)), DATEADD(DAY, 25, DATEADD(DAY, 8, @StartDate)), 'Completed'),

    -- Incident 3 Actions
    (5, 3, 'Contain and clean chemical spill using proper procedures', 'Corrective', 7, 2, DATEADD(HOUR, 4, DATEADD(DAY, 12, @StartDate)), DATEADD(HOUR, 3, DATEADD(DAY, 12, @StartDate)), 'Completed'),
    (6, 3, 'Investigate root cause of chemical leak', 'Investigation', 8, 2, DATEADD(DAY, 3, DATEADD(DAY, 12, @StartDate)), DATEADD(DAY, 3, DATEADD(DAY, 12, @StartDate)), 'Completed'),
    (7, 3, 'Replace damaged chemical storage containers', 'Corrective', 7, 2, DATEADD(DAY, 7, DATEADD(DAY, 12, @StartDate)), DATEADD(DAY, 6, DATEADD(DAY, 12, @StartDate)), 'Completed'),
    (8, 3, 'Conduct chemical safety refresher training', 'Preventive', 2, 2, DATEADD(DAY, 14, DATEADD(DAY, 12, @StartDate)), DATEADD(DAY, 12, DATEADD(DAY, 12, @StartDate)), 'Completed'),

    -- Incident 4 Actions
    (9, 4, 'Retrain forklift operator on pedestrian awareness', 'Corrective', 6, 2, DATEADD(DAY, 7, DATEADD(DAY, 15, @StartDate)), DATEADD(DAY, 5, DATEADD(DAY, 15, @StartDate)), 'Completed'),
    (10, 4, 'Install additional pedestrian crossing signs in warehouse', 'Preventive', 7, 2, DATEADD(DAY, 14, DATEADD(DAY, 15, @StartDate)), DATEADD(DAY, 12, DATEADD(DAY, 15, @StartDate)), 'Completed'),

    -- Incident 5 Actions
    (11, 5, 'Conduct ergonomic assessment of packaging station', 'Investigation', 2, 2, DATEADD(DAY, 10, DATEADD(DAY, 18, @StartDate)), NULL, 'In Progress'),
    (12, 5, 'Provide ergonomic wrist support for affected employee', 'Corrective', 3, 2, DATEADD(DAY, 3, DATEADD(DAY, 18, @StartDate)), DATEADD(DAY, 2, DATEADD(DAY, 18, @StartDate)), 'Completed'),

    -- Incident 7 Actions
    (13, 7, 'Shut down and inspect electrical panel', 'Corrective', 7, 2, DATEADD(HOUR, 2, DATEADD(DAY, 38, @StartDate)), DATEADD(HOUR, 2, DATEADD(DAY, 38, @StartDate)), 'Completed'),
    (14, 7, 'Replace faulty electrical components', 'Corrective', 8, 2, DATEADD(DAY, 1, DATEADD(DAY, 38, @StartDate)), DATEADD(DAY, 1, DATEADD(DAY, 38, @StartDate)), 'Completed'),
    (15, 7, 'Schedule comprehensive electrical system audit', 'Preventive', 8, 2, DATEADD(DAY, 30, DATEADD(DAY, 38, @StartDate)), DATEADD(DAY, 28, DATEADD(DAY, 38, @StartDate)), 'Completed'),

    -- Incident 8 Actions
    (16, 8, 'Repair parking lot pothole', 'Corrective', 7, 2, DATEADD(DAY, 5, DATEADD(DAY, 42, @StartDate)), DATEADD(DAY, 4, DATEADD(DAY, 42, @StartDate)), 'Completed'),
    (17, 8, 'Conduct full parking lot surface inspection', 'Preventive', 7, 2, DATEADD(DAY, 14, DATEADD(DAY, 42, @StartDate)), DATEADD(DAY, 10, DATEADD(DAY, 42, @StartDate)), 'Completed'),

    -- Incident 9 Actions
    (18, 9, 'Locate and install missing machine guard', 'Corrective', 7, 2, DATEADD(HOUR, 4, DATEADD(DAY, 45, @StartDate)), DATEADD(HOUR, 3, DATEADD(DAY, 45, @StartDate)), 'Completed'),
    (19, 9, 'Implement daily machine guard inspection checklist', 'Preventive', 3, 2, DATEADD(DAY, 7, DATEADD(DAY, 45, @StartDate)), DATEADD(DAY, 5, DATEADD(DAY, 45, @StartDate)), 'Completed'),

    -- Incident 10 Actions
    (20, 10, 'Test and service ventilation system in production area', 'Investigation', 7, 2, DATEADD(DAY, 3, DATEADD(DAY, 48, @StartDate)), NULL, 'In Progress'),
    (21, 10, 'Measure air quality and chemical concentrations', 'Investigation', 2, 2, DATEADD(DAY, 5, DATEADD(DAY, 48, @StartDate)), NULL, 'Pending'),

    -- Incident 11 Actions
    (22, 11, 'Install safety railing on loading dock', 'Corrective', 7, 2, DATEADD(DAY, 14, DATEADD(DAY, 65, @StartDate)), DATEADD(DAY, 12, DATEADD(DAY, 65, @StartDate)), 'Completed'),
    (23, 11, 'Provide fall protection training for dock workers', 'Preventive', 2, 2, DATEADD(DAY, 21, DATEADD(DAY, 65, @StartDate)), DATEADD(DAY, 18, DATEADD(DAY, 65, @StartDate)), 'Completed'),
    (24, 11, 'Post warning signs and floor markings at dock edge', 'Corrective', 7, 2, DATEADD(DAY, 7, DATEADD(DAY, 65, @StartDate)), DATEADD(DAY, 5, DATEADD(DAY, 65, @StartDate)), 'Completed'),

    -- Incident 21 Actions
    (25, 21, 'Retrain overhead crane operator on load handling', 'Corrective', 3, 2, DATEADD(DAY, 7, DATEADD(DAY, 125, @StartDate)), NULL, 'In Progress'),
    (26, 21, 'Inspect crane rigging and safety systems', 'Investigation', 8, 2, DATEADD(DAY, 3, DATEADD(DAY, 125, @StartDate)), NULL, 'In Progress'),

    -- Incident 22 Actions
    (27, 22, 'Deep clean production area to remove dust buildup', 'Corrective', 7, 2, DATEADD(DAY, 7, DATEADD(DAY, 128, @StartDate)), NULL, 'Pending'),
    (28, 22, 'Implement weekly dust control cleaning schedule', 'Preventive', 3, 2, DATEADD(DAY, 14, DATEADD(DAY, 128, @StartDate)), NULL, 'Pending'),

    -- Incident 25 Actions
    (29, 25, 'Review welding hot work permit procedures', 'Investigation', 2, 2, DATEADD(DAY, 3, DATEADD(DAY, 138, @StartDate)), DATEADD(DAY, 3, DATEADD(DAY, 138, @StartDate)), 'Completed'),
    (30, 25, 'Install additional fire extinguishers in welding area', 'Preventive', 7, 2, DATEADD(DAY, 7, DATEADD(DAY, 138, @StartDate)), DATEADD(DAY, 6, DATEADD(DAY, 138, @StartDate)), 'Completed'),

    -- Incident 26 Actions
    (31, 26, 'Inspect and repair power drill', 'Corrective', 7, 2, DATEADD(DAY, 2, DATEADD(DAY, 155, @StartDate)), NULL, 'Pending'),
    (32, 26, 'Review power tool maintenance schedule', 'Preventive', 8, 2, DATEADD(DAY, 7, DATEADD(DAY, 155, @StartDate)), NULL, 'Pending'),

    -- Incident 27 Actions
    (33, 27, 'Install backup alarm on delivery truck if missing', 'Corrective', 6, 2, DATEADD(DAY, 3, DATEADD(DAY, 158, @StartDate)), NULL, 'In Progress'),
    (34, 27, 'Add convex mirrors at blind corners', 'Preventive', 7, 2, DATEADD(DAY, 14, DATEADD(DAY, 158, @StartDate)), NULL, 'Pending'),

    -- Incident 29 Actions
    (35, 29, 'Evaluate mechanical lifting aids for heavy components', 'Investigation', 8, 2, DATEADD(DAY, 10, DATEADD(DAY, 165, @StartDate)), NULL, 'Pending'),
    (36, 29, 'Provide refresher training on proper lifting techniques', 'Preventive', 2, 2, DATEADD(DAY, 7, DATEADD(DAY, 165, @StartDate)), NULL, 'Pending'),

    -- Incident 30 Actions
    (37, 30, 'Measure light levels in warehouse zone 1', 'Investigation', 8, 2, DATEADD(DAY, 5, DATEADD(DAY, 168, @StartDate)), NULL, 'Pending'),
    (38, 30, 'Install additional lighting fixtures if needed', 'Corrective', 7, 2, DATEADD(DAY, 14, DATEADD(DAY, 168, @StartDate)), NULL, 'Pending'),

    -- Incident 31 Actions
    (39, 31, 'Investigate cause of hydraulic line rupture', 'Investigation', 8, 2, DATEADD(DAY, 3, DATEADD(DAY, 170, @StartDate)), NULL, 'In Progress'),
    (40, 31, 'Inspect all hydraulic lines for wear and damage', 'Preventive', 8, 2, DATEADD(DAY, 7, DATEADD(DAY, 170, @StartDate)), NULL, 'Pending'),

    -- Incident 32 Actions
    (41, 32, 'Conduct comprehensive noise level survey', 'Investigation', 2, 2, DATEADD(DAY, 10, DATEADD(DAY, 172, @StartDate)), NULL, 'Pending'),
    (42, 32, 'Evaluate noise control engineering options', 'Preventive', 8, 2, DATEADD(DAY, 21, DATEADD(DAY, 172, @StartDate)), NULL, 'Pending'),

    -- Incident 33 Actions
    (43, 33, 'Review tool storage procedures for elevated work', 'Investigation', 8, 2, DATEADD(DAY, 3, DATEADD(DAY, 174, @StartDate)), NULL, 'In Progress'),
    (44, 33, 'Implement tool tethering policy for work at height', 'Preventive', 2, 2, DATEADD(DAY, 14, DATEADD(DAY, 174, @StartDate)), NULL, 'Pending'),

    -- Incident 34 Actions
    (45, 34, 'Conduct safety eyewear compliance enforcement meeting', 'Corrective', 3, 2, DATEADD(DAY, 2, DATEADD(DAY, 176, @StartDate)), NULL, 'Pending'),
    (46, 34, 'Issue written warnings for PPE non-compliance', 'Corrective', 2, 2, DATEADD(DAY, 1, DATEADD(DAY, 176, @StartDate)), NULL, 'Pending'),

    -- Incident 38 Actions (Critical - Lockout/Tagout)
    (47, 38, 'Investigate circumstances of lockout/tagout violation', 'Investigation', 2, 2, DATEADD(DAY, 1, DATEADD(DAY, 80, @StartDate)), DATEADD(DAY, 1, DATEADD(DAY, 80, @StartDate)), 'Completed'),
    (48, 38, 'Retrain all maintenance staff on LOTO procedures', 'Corrective', 8, 2, DATEADD(DAY, 14, DATEADD(DAY, 80, @StartDate)), DATEADD(DAY, 12, DATEADD(DAY, 80, @StartDate)), 'Completed'),
    (49, 38, 'Audit all LOTO points and equipment tags', 'Preventive', 2, 2, DATEADD(DAY, 21, DATEADD(DAY, 80, @StartDate)), DATEADD(DAY, 20, DATEADD(DAY, 80, @StartDate)), 'Completed'),
    (50, 38, 'Implement daily LOTO compliance checks', 'Preventive', 8, 2, DATEADD(DAY, 30, DATEADD(DAY, 80, @StartDate)), DATEADD(DAY, 28, DATEADD(DAY, 80, @StartDate)), 'Completed'),

    -- Incident 40 Actions
    (51, 40, 'Repair damaged concrete in walkway', 'Corrective', 7, 2, DATEADD(DAY, 14, DATEADD(DAY, 140, @StartDate)), NULL, 'Pending'),

    -- Incident 41 Actions
    (52, 41, 'Shut down machine and install proper guarding', 'Corrective', 7, 2, DATEADD(HOUR, 4, DATEADD(DAY, 25, @StartDate)), DATEADD(HOUR, 3, DATEADD(DAY, 25, @StartDate)), 'Completed'),
    (53, 41, 'Conduct machine guarding audit of all equipment', 'Preventive', 2, 2, DATEADD(DAY, 30, DATEADD(DAY, 25, @StartDate)), DATEADD(DAY, 28, DATEADD(DAY, 25, @StartDate)), 'Completed'),

    -- Incident 43 Actions
    (54, 43, 'Improve ventilation in chemical storage area', 'Corrective', 8, 2, DATEADD(DAY, 7, DATEADD(DAY, 85, @StartDate)), DATEADD(DAY, 7, DATEADD(DAY, 85, @StartDate)), 'Completed'),
    (55, 43, 'Provide respirators for chemical handling tasks', 'Corrective', 2, 2, DATEADD(DAY, 3, DATEADD(DAY, 85, @StartDate)), DATEADD(DAY, 2, DATEADD(DAY, 85, @StartDate)), 'Completed'),

    -- Incident 50 Actions
    (56, 50, 'Schedule respirator fit testing for all affected employees', 'Corrective', 2, 2, DATEADD(DAY, 14, DATEADD(DAY, 150, @StartDate)), NULL, 'In Progress'),
    (57, 50, 'Implement fit test reminder system', 'Preventive', 2, 2, DATEADD(DAY, 30, DATEADD(DAY, 150, @StartDate)), NULL, 'Pending'),

    -- Additional preventive actions across departments
    (58, 1, 'Quarterly slip/trip/fall hazard walkthrough', 'Preventive', 2, 2, DATEADD(DAY, 90, DATEADD(DAY, 5, @StartDate)), DATEADD(DAY, 85, DATEADD(DAY, 5, @StartDate)), 'Completed'),
    (59, 6, 'Implement pallet stacking height restrictions', 'Preventive', 6, 2, DATEADD(DAY, 14, DATEADD(DAY, 35, @StartDate)), DATEADD(DAY, 12, DATEADD(DAY, 35, @StartDate)), 'Completed'),
    (60, 14, 'Forklift refresher training for all operators', 'Preventive', 6, 2, DATEADD(DAY, 30, DATEADD(DAY, 75, @StartDate)), DATEADD(DAY, 28, DATEADD(DAY, 75, @StartDate)), 'Completed'),
    (61, 15, 'Install additional fans in production area', 'Corrective', 7, 2, DATEADD(DAY, 14, DATEADD(DAY, 78, @StartDate)), DATEADD(DAY, 12, DATEADD(DAY, 78, @StartDate)), 'Completed'),
    (62, 15, 'Implement heat stress monitoring protocol', 'Preventive', 2, 2, DATEADD(DAY, 21, DATEADD(DAY, 78, @StartDate)), DATEADD(DAY, 20, DATEADD(DAY, 78, @StartDate)), 'Completed'),
    (63, 18, 'Provide safety knives with retractable blades', 'Preventive', 6, 2, DATEADD(DAY, 7, DATEADD(DAY, 102, @StartDate)), DATEADD(DAY, 5, DATEADD(DAY, 102, @StartDate)), 'Completed'),
    (64, 19, 'Conduct emergency exit access audit', 'Investigation', 2, 2, DATEADD(DAY, 7, DATEADD(DAY, 105, @StartDate)), DATEADD(DAY, 7, DATEADD(DAY, 105, @StartDate)), 'Completed'),
    (65, 20, 'Replace faulty smoke detector', 'Corrective', 7, 2, DATEADD(DAY, 2, DATEADD(DAY, 108, @StartDate)), DATEADD(DAY, 1, DATEADD(DAY, 108, @StartDate)), 'Completed'),
    (66, 23, 'Post proper lifting technique posters', 'Preventive', 6, 2, DATEADD(DAY, 7, DATEADD(DAY, 132, @StartDate)), DATEADD(DAY, 5, DATEADD(DAY, 132, @StartDate)), 'Completed'),
    (67, 24, 'Establish first aid kit inspection schedule', 'Preventive', 2, 2, DATEADD(DAY, 7, DATEADD(DAY, 135, @StartDate)), DATEADD(DAY, 7, DATEADD(DAY, 135, @StartDate)), 'Completed'),
    (68, 28, 'Switch to hypoallergenic cleaning products', 'Corrective', 1, 2, DATEADD(DAY, 7, DATEADD(DAY, 162, @StartDate)), DATEADD(DAY, 5, DATEADD(DAY, 162, @StartDate)), 'Completed'),
    (69, 35, 'Conduct electrical safety training', 'Preventive', 2, 2, DATEADD(DAY, 14, DATEADD(DAY, 178, @StartDate)), DATEADD(DAY, 12, DATEADD(DAY, 178, @StartDate)), 'Completed'),
    (70, 42, 'Purchase mechanical lifting equipment for warehouse', 'Corrective', 6, 2, DATEADD(DAY, 30, DATEADD(DAY, 55, @StartDate)), DATEADD(DAY, 28, DATEADD(DAY, 55, @StartDate)), 'Completed'),
    (71, 44, 'Inspect all fall protection equipment', 'Preventive', 8, 2, DATEADD(DAY, 7, DATEADD(DAY, 115, @StartDate)), DATEADD(DAY, 7, DATEADD(DAY, 115, @StartDate)), 'Completed'),
    (72, 45, 'Implement winter walkway maintenance schedule', 'Preventive', 7, 2, DATEADD(DAY, 7, DATEADD(DAY, 145, @StartDate)), DATEADD(DAY, 5, DATEADD(DAY, 145, @StartDate)), 'Completed'),
    (73, 46, 'Update chemical storage location map', 'Corrective', 7, 2, DATEADD(DAY, 3, DATEADD(DAY, 30, @StartDate)), DATEADD(DAY, 2, DATEADD(DAY, 30, @StartDate)), 'Completed'),
    (74, 48, 'Reorganize warehouse to meet aisle width requirements', 'Corrective', 6, 2, DATEADD(DAY, 14, DATEADD(DAY, 90, @StartDate)), DATEADD(DAY, 12, DATEADD(DAY, 90, @StartDate)), 'Completed'),
    (75, 49, 'Install warning labels on hot equipment surfaces', 'Preventive', 7, 2, DATEADD(DAY, 7, DATEADD(DAY, 120, @StartDate)), DATEADD(DAY, 5, DATEADD(DAY, 120, @StartDate)), 'Completed');

SET IDENTITY_INSERT dbo.IncidentActions OFF;
GO

PRINT '===================================';
PRINT 'Seed data inserted successfully!';
PRINT '===================================';
PRINT 'Departments: 5';
PRINT 'Users: 10';
PRINT 'Locations: 10';
PRINT 'Categories: 10';
PRINT 'Incidents: 50';
PRINT 'Actions: 75';
PRINT '===================================';
PRINT 'Database is ready for testing!';
GO
