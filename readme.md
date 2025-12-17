# Incident Management System

DataWise is a comprehensive web application built with ASP.NET Web Forms for tracking, managing, and analyzing organizational incidents. It provides a centralized platform for incident reporting, corrective action management, and data-driven insights to improve safety and operational efficiency.

## Features

- **Dashboard & Analytics**: A central dashboard with KPIs, charts, and visualizations for a quick overview of incident metrics.
- **Incident Reporting**: A detailed form to create and manage incidents, capturing essential information like severity, location, department, and description.
- **Dynamic Filtering & Search**: Robust filtering and search capabilities on the incident list page.
- **Data Export**: Export incident data to Excel for external analysis and reporting.
- **Email Notifications**: Automated email alerts for critical incidents and new assignments.

## Technical Architecture

The application follows a traditional n-tier architecture:

-   **Presentation Layer (UI)**: Built with ASP.NET Web Forms (`.aspx` pages and `.ascx` user controls). The UI is responsible for rendering data and capturing user input.
-   **Business Logic Layer (BLL)**: Encapsulated in `App_Logic/IncidentManager.cs`, this layer contains the core business rules, logic, and orchestrates data flow between the UI and the data layer.
-   **Data Access Layer (DAL)**: The `App_Logic/DatabaseHelper.cs` class manages all database interactions using stored procedures for enhanced security and performance.
-   **Database**: A SQL Server database serves as the data store. All schema, stored procedures, and initial data are defined in the `App_Data` directory.

## Getting Started

Follow these steps to set up and run the project locally.

### Prerequisites

-   Visual Studio 2019 or later
-   .NET Framework 4.7.2 or later
-   SQL Server (LocalDB or a full instance)

### Installation

1.  **Clone the repository:**
    ```bash
    git clone <repository-url>
    ```
2.  **Database Setup:**
    -   Open SQL Server Management Studio (SSMS) or use the `sqlcmd` utility.
    -   Execute the `App_Data/DatabaseSetup.sql` script to create the `IncidentManagement` database and tables.
    -   Execute `App_Data/StoredProcedures.sql` to create the necessary stored procedures.
    -   (Optional) Run `App_Data/SeedData.sql` to populate the database with initial lookup data.

3.  **Configure Connection String:**
    -   Open the `Web.config` file.
    -   Locate the `IncidentDB` connection string and update the `Server` attribute to point to your SQL Server instance. For SQL Express, you might use `.\SQLEXPRESS`.
    ```xml
    <connectionStrings>
      <add name="IncidentDB"
           connectionString="Server=(localdb)\MSSQLLocalDB;Database=IncidentManagement;Integrated Security=true;"
           providerName="System.Data.SqlClient" />
    </connectionStrings>
    ```

4.  **Run the Application:**
    -   Open the `datawise.sln` file in Visual Studio.
    -   Set `Default.aspx` as the start page.
    -   Press `F5` to build and run the project. The application will open in your default browser.

## Roadmap

This section outlines potential future enhancements based on the initial project requirements.

-   **AI Integration**: Implement AI-powered features for automatic incident categorization and trend analysis.
-   **Advanced Reporting**: Add drill-down capabilities to KPIs and dashboards.
-   **Offline Support**: Develop offline capabilities for data entry in environments with limited connectivity.
-   **Web API**: Create a separate Web API using Microservices architecture for modern client integrations.
-   **File Uploads**: Allow users to attach images and documents to incident reports.


