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
                                    CssClass="btn btn-outline-primary" OnClick="btnRefresh_Click">
                            <i class="fas fa-sync-alt"></i>
                        </asp:Button>
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
                        <asp:GridView ID="gvRecentIncidents" runat="server" CssClass="table table-striped table-hover"
                                      AutoGenerateColumns="False" GridLines="None" EnableViewState="false">
                            <Columns>
                                <asp:BoundField DataField="IncidentID" HeaderText="ID" ItemStyle-Width="60px" />
                                <asp:BoundField DataField="Title" HeaderText="Title" />
                                <asp:TemplateField HeaderText="Severity">
                                    <ItemTemplate>
                                        <span class='<%# GetSeverityBadgeClass(Eval("Severity")) %>'>
                                            <%# Eval("Severity") %> - <%# IncidentManager.GetSeverityLabel(Convert.ToInt32(Eval("Severity"))) %>
                                        </span>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:BoundField DataField="IncidentDate" HeaderText="Date" DataFormatString="{0:MMM dd, yyyy}" />
                                <asp:BoundField DataField="DepartmentName" HeaderText="Department" />
                                <asp:TemplateField HeaderText="Status">
                                    <ItemTemplate>
                                        <span class='<%# IncidentManager.GetStatusClass(Eval("Status").ToString()) %>'>
                                            <%# Eval("Status") %>
                                        </span>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Actions">
                                    <ItemTemplate>
                                        <a href='IncidentForm.aspx?id=<%# Eval("IncidentID") %>&mode=view' class="btn btn-sm btn-outline-primary">
                                            <i class="fas fa-eye"></i>
                                        </a>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                            <EmptyDataTemplate>
                                <div class="alert alert-info">No recent incidents to display.</div>
                            </EmptyDataTemplate>
                        </asp:GridView>
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
            initializeDashboardCharts();
        });
    </script>
</asp:Content>
