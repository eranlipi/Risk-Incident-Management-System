<%@ Page Title="Dashboard" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeFile="Default.aspx.cs" Inherits="Pages_Default" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .metric-card {
            transition: transform 0.2s;
        }
        .metric-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 4px 8px rgba(0,0,0,0.1);
        }
        .metric-value {
            font-size: 2.5rem;
            font-weight: bold;
        }
        .chart-container {
            position: relative;
            height: 300px;
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="dashboard">
        <!-- Page Header -->
        <div class="row mb-4">
            <div class="col-12">
                <h1><i class="fas fa-chart-line"></i> Safety Dashboard</h1>
                <p class="text-muted">Real-time overview of incident management and key performance indicators</p>
            </div>
        </div>

        <!-- Session Demo -->
        <div class="row mb-4">
            <div class="col-12">
                <div class="card bg-light border-0">
                    <div class="card-body py-3">
                        <div class="form-inline">
                            <span class="mr-2">Welcome, <strong><asp:Label ID="lblWelcomeName" runat="server" Text="Guest"></asp:Label></strong>!</span>
                            <span class="text-muted mr-3 small border-right pr-3">Session Demo</span>
                            
                            <div class="input-group input-group-sm">
                                <asp:TextBox ID="txtUserName" runat="server" CssClass="form-control" placeholder="Enter your name"></asp:TextBox>
                                <div class="input-group-append">
                                    <asp:Button ID="btnSetUser" runat="server" Text="Set User" CssClass="btn btn-primary" OnClick="btnSetUser_Click" />
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- KPI Cards -->
        <asp:UpdatePanel ID="UpdatePanelMetrics" runat="server" UpdateMode="Conditional">
            <ContentTemplate>
                <div class="row mb-4">
                    <!-- Total Incidents -->
                    <div class="col-md-3 mb-3">
                        <div class="card metric-card bg-primary text-white">
                            <div class="card-body">
                                <div class="d-flex justify-content-between align-items-center">
                                    <div>
                                        <h6 class="card-title">Total Incidents</h6>
                                        <div class="metric-value">
                                            <asp:Label ID="lblTotalIncidents" runat="server" Text="0"></asp:Label>
                                        </div>
                                        <small>Last 6 months</small>
                                    </div>
                                    <div>
                                        <i class="fas fa-exclamation-triangle fa-3x opacity-50"></i>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Open Incidents -->
                    <div class="col-md-3 mb-3">
                        <div class="card metric-card bg-warning text-dark">
                            <div class="card-body">
                                <div class="d-flex justify-content-between align-items-center">
                                    <div>
                                        <h6 class="card-title">Open Incidents</h6>
                                        <div class="metric-value">
                                            <asp:Label ID="lblOpenIncidents" runat="server" Text="0"></asp:Label>
                                        </div>
                                        <small>Requiring attention</small>
                                    </div>
                                    <div>
                                        <i class="fas fa-folder-open fa-3x opacity-50"></i>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Critical Incidents -->
                    <div class="col-md-3 mb-3">
                        <div class="card metric-card bg-danger text-white">
                            <div class="card-body">
                                <div class="d-flex justify-content-between align-items-center">
                                    <div>
                                        <h6 class="card-title">Critical Incidents</h6>
                                        <div class="metric-value">
                                            <asp:Label ID="lblCriticalIncidents" runat="server" Text="0"></asp:Label>
                                        </div>
                                        <small>Severity 4-5</small>
                                    </div>
                                    <div>
                                        <i class="fas fa-fire fa-3x opacity-50"></i>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Avg Resolution Time -->
                    <div class="col-md-3 mb-3">
                        <div class="card metric-card bg-success text-white">
                            <div class="card-body">
                                <div class="d-flex justify-content-between align-items-center">
                                    <div>
                                        <h6 class="card-title">Avg Resolution</h6>
                                        <div class="metric-value">
                                            <asp:Label ID="lblAvgResolution" runat="server" Text="0"></asp:Label>
                                        </div>
                                        <small>Days to close</small>
                                    </div>
                                    <div>
                                        <i class="fas fa-clock fa-3x opacity-50"></i>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Additional Metrics Row -->
                <div class="row mb-4">
                    <div class="col-md-3 mb-3">
                        <div class="card">
                            <div class="card-body text-center">
                                <h6 class="text-muted">Incidents with Injuries</h6>
                                <h2 class="text-danger">
                                    <asp:Label ID="lblInjuries" runat="server" Text="0"></asp:Label>
                                </h2>
                            </div>
                        </div>
                    </div>

                    <div class="col-md-3 mb-3">
                        <div class="card">
                            <div class="card-body text-center">
                                <h6 class="text-muted">Overdue Actions</h6>
                                <h2 class="text-warning">
                                    <asp:Label ID="lblOverdueActions" runat="server" Text="0"></asp:Label>
                                </h2>
                            </div>
                        </div>
                    </div>

                    <div class="col-md-3 mb-3">
                        <div class="card">
                            <div class="card-body text-center">
                                <h6 class="text-muted">Pending Actions</h6>
                                <h2 class="text-info">
                                    <asp:Label ID="lblPendingActions" runat="server" Text="0"></asp:Label>
                                </h2>
                            </div>
                        </div>
                    </div>

                    <div class="col-md-3 mb-3">
                        <div class="card">
                            <div class="card-body text-center">
                                <h6 class="text-muted">Closed Incidents</h6>
                                <h2 class="text-success">
                                    <asp:Label ID="lblClosedIncidents" runat="server" Text="0"></asp:Label>
                                </h2>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="row mb-2">
                    <div class="col-12 text-right">
                        <asp:Button ID="btnRefresh" runat="server" Text="Refresh Data"
                                    CssClass="btn btn-outline-primary" OnClick="btnRefresh_Click" />
                        <small class="text-muted ml-2">
                            Last updated:
                            <asp:Label ID="lblLastUpdate" runat="server" Text=""></asp:Label>
                        </small>
                    </div>
                </div>
            </ContentTemplate>
        </asp:UpdatePanel>

        <!-- Charts Row -->
        <div class="row mb-4">
            <!-- Incidents by Month Chart -->
            <div class="col-md-6 mb-3">
                <div class="card">
                    <div class="card-header">
                        <h5><i class="fas fa-chart-line"></i> Incident Trends (Last 6 Months)</h5>
                    </div>
                    <div class="card-body">
                        <div class="chart-container">
                            <canvas id="chartIncidentsByMonth"></canvas>
                        </div>
                        <asp:HiddenField ID="hfIncidentsByMonth" runat="server" />
                    </div>
                </div>
            </div>

            <!-- Incidents by Department Chart -->
            <div class="col-md-6 mb-3">
                <div class="card">
                    <div class="card-header">
                        <h5><i class="fas fa-building"></i> Incidents by Department</h5>
                    </div>
                    <div class="card-body">
                        <div class="chart-container">
                            <canvas id="chartIncidentsByDepartment"></canvas>
                        </div>
                        <asp:HiddenField ID="hfIncidentsByDepartment" runat="server" />
                    </div>
                </div>
            </div>
        </div>

        <div class="row mb-4">
            <!-- Incidents by Severity Chart -->
            <div class="col-md-6 mb-3">
                <div class="card">
                    <div class="card-header">
                        <h5><i class="fas fa-chart-pie"></i> Incidents by Severity</h5>
                    </div>
                    <div class="card-body">
                        <div class="chart-container">
                            <canvas id="chartIncidentsBySeverity"></canvas>
                        </div>
                        <asp:HiddenField ID="hfIncidentsBySeverity" runat="server" />
                    </div>
                </div>
            </div>

            <!-- Top Categories Chart -->
            <div class="col-md-6 mb-3">
                <div class="card">
                    <div class="card-header">
                        <h5><i class="fas fa-list-ol"></i> Top 5 Incident Categories</h5>
                    </div>
                    <div class="card-body">
                        <div class="chart-container">
                            <canvas id="chartTopCategories"></canvas>
                        </div>
                        <asp:HiddenField ID="hfTopCategories" runat="server" />
                    </div>
                </div>
            </div>
        </div>

        <!-- Recent Incidents -->
        <div class="row">
            <div class="col-12">
                <div class="card">
                    <div class="card-header">
                        <h5><i class="fas fa-history"></i> Recent Incidents</h5>
                    </div>
                    <div class="card-body">
                        <asp:Repeater ID="rptRecentIncidents" runat="server">
                            <HeaderTemplate>
                                <table class="table table-striped table-hover">
                                    <thead>
                                        <tr>
                                            <th style="width: 60px;">ID</th>
                                            <th>Title</th>
                                            <th>Severity</th>
                                            <th>Date</th>
                                            <th>Department</th>
                                            <th>Status</th>
                                            <th>Actions</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                            </HeaderTemplate>
                            <ItemTemplate>
                                <tr>
                                    <td><%# Eval("IncidentID") %></td>
                                    <td><%# Eval("Title") %></td>
                                    <td>
                                        <span class='<%# GetSeverityBadgeClass(Eval("Severity")) %>'>
                                            <%# Eval("Severity") %> - <%# IncidentManager.GetSeverityLabel(Convert.ToInt32(Eval("Severity"))) %>
                                        </span>
                                    </td>
                                    <td><%# Eval("IncidentDate", "{0:MMM dd, yyyy}") %></td>
                                    <td><%# Eval("DepartmentName") %></td>
                                    <td>
                                        <span class='<%# IncidentManager.GetStatusClass(Eval("Status").ToString()) %>'>
                                            <%# Eval("Status") %>
                                        </span>
                                    </td>
                                    <td>
                                        <button type="button" class="btn btn-sm btn-outline-primary view-incident-btn" 
                                                data-id='<%# Eval("IncidentID") %>'
                                                data-title='<%# Eval("Title") %>'
                                                data-description='<%# HttpUtility.HtmlEncode(Eval("Description")) %>'
                                                data-severity='<%# Eval("Severity") %>'
                                                data-date='<%# Eval("IncidentDate", "{0:MMM dd, yyyy}") %>'
                                                data-status='<%# Eval("Status") %>'
                                                data-department='<%# Eval("DepartmentName") %>'
                                                data-location='<%# Eval("LocationName") %>'
                                                data-reportedby='<%# Eval("ReportedBy") %>'
                                                data-injuries='<%# Eval("InjuriesReported") %>'
                                                title="View">
                                            <i class="fas fa-eye"></i>
                                        </button>
                                    </td>
                                </tr>
                            </ItemTemplate>
                            <FooterTemplate>
                                    </tbody>
                                </table>
                            </FooterTemplate>
                        </asp:Repeater>
                        <asp:Panel ID="pnlNoIncidents" runat="server" Visible="false">
                            <div class="alert alert-info">No recent incidents to display.</div>
                        </asp:Panel>
                    </div>
                </div>
            </div>
        </div>
    </div>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="ScriptsContent" runat="server">
    <script>
        // Initialize charts when page loads
        $(document).ready(function () {
            if (typeof initializeDashboardCharts === 'function') {
                initializeDashboardCharts();
            } else {
                // Fallback: try after a short delay in case scripts are still loading
                console.warn('initializeDashboardCharts is not defined on DOM ready. Retrying shortly.');
                setTimeout(function () {
                    if (typeof initializeDashboardCharts === 'function') {
                        initializeDashboardCharts();
                    } else if (window.console) {
                        console.error('initializeDashboardCharts could not be found.');
                    }
                }, 200);
            }
        });
    </script>
</asp:Content>
