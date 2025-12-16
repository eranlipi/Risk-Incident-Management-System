<%@ Control Language="C#" AutoEventWireup="true" CodeFile="FilterPanel.ascx.cs" Inherits="Controls_FilterPanel" %>

<asp:UpdatePanel ID="UpdatePanelFilter" runat="server" UpdateMode="Conditional">
    <ContentTemplate>
        <div class="card filter-panel">
            <div class="card-header bg-light">
                <h5 class="mb-0">
                    <i class="fas fa-filter"></i> Search & Filter
                    <button type="button" class="btn btn-sm btn-link float-right" data-toggle="collapse" data-target="#collapseFilter">
                        <i class="fas fa-chevron-down"></i>
                    </button>
                </h5>
            </div>
            <div id="collapseFilter" class="collapse show">
                <div class="card-body">
                    <div class="row">
                        <!-- Keyword Search -->
                        <div class="col-md-4 mb-3">
                            <label for="txtKeyword">
                                <i class="fas fa-search"></i> Keyword
                            </label>
                            <asp:TextBox ID="txtKeyword" runat="server" CssClass="form-control"
                                         placeholder="Search title or description..."></asp:TextBox>
                        </div>

                        <!-- Department Filter -->
                        <div class="col-md-4 mb-3">
                            <label for="ddlDepartment">
                                <i class="fas fa-building"></i> Department
                            </label>
                            <asp:DropDownList ID="ddlDepartment" runat="server" CssClass="form-control">
                                <asp:ListItem Text="All Departments" Value=""></asp:ListItem>
                            </asp:DropDownList>
                        </div>

                        <!-- Location Filter -->
                        <div class="col-md-4 mb-3">
                            <label for="ddlLocation">
                                <i class="fas fa-map-marker-alt"></i> Location
                            </label>
                            <asp:DropDownList ID="ddlLocation" runat="server" CssClass="form-control">
                                <asp:ListItem Text="All Locations" Value=""></asp:ListItem>
                            </asp:DropDownList>
                        </div>
                    </div>

                    <div class="row">
                        <!-- Category Filter -->
                        <div class="col-md-3 mb-3">
                            <label for="ddlCategory">
                                <i class="fas fa-tag"></i> Category
                            </label>
                            <asp:DropDownList ID="ddlCategory" runat="server" CssClass="form-control">
                                <asp:ListItem Text="All Categories" Value=""></asp:ListItem>
                            </asp:DropDownList>
                        </div>

                        <!-- Severity Filter -->
                        <div class="col-md-3 mb-3">
                            <label for="ddlSeverity">
                                <i class="fas fa-thermometer-half"></i> Severity
                            </label>
                            <asp:DropDownList ID="ddlSeverity" runat="server" CssClass="form-control">
                                <asp:ListItem Text="All Severities" Value=""></asp:ListItem>
                                <asp:ListItem Text="5 - Critical" Value="5"></asp:ListItem>
                                <asp:ListItem Text="4 - High" Value="4"></asp:ListItem>
                                <asp:ListItem Text="3 - Significant" Value="3"></asp:ListItem>
                                <asp:ListItem Text="2 - Moderate" Value="2"></asp:ListItem>
                                <asp:ListItem Text="1 - Low" Value="1"></asp:ListItem>
                            </asp:DropDownList>
                        </div>

                        <!-- Status Filter -->
                        <div class="col-md-3 mb-3">
                            <label for="ddlStatus">
                                <i class="fas fa-info-circle"></i> Status
                            </label>
                            <asp:DropDownList ID="ddlStatus" runat="server" CssClass="form-control">
                                <asp:ListItem Text="All Statuses" Value=""></asp:ListItem>
                                <asp:ListItem Text="Open" Value="Open"></asp:ListItem>
                                <asp:ListItem Text="In Progress" Value="In Progress"></asp:ListItem>
                                <asp:ListItem Text="Under Review" Value="Under Review"></asp:ListItem>
                                <asp:ListItem Text="Closed" Value="Closed"></asp:ListItem>
                            </asp:DropDownList>
                        </div>

                        <!-- Date Range -->
                        <div class="col-md-3 mb-3">
                            <label for="ddlDateRange">
                                <i class="fas fa-calendar-alt"></i> Date Range
                            </label>
                            <asp:DropDownList ID="ddlDateRange" runat="server" CssClass="form-control"
                                              AutoPostBack="false" OnSelectedIndexChanged="ddlDateRange_SelectedIndexChanged">
                                <asp:ListItem Text="All Time" Value="all"></asp:ListItem>
                                <asp:ListItem Text="Today" Value="today"></asp:ListItem>
                                <asp:ListItem Text="Last 7 Days" Value="7days" Selected="True"></asp:ListItem>
                                <asp:ListItem Text="Last 30 Days" Value="30days"></asp:ListItem>
                                <asp:ListItem Text="Last 3 Months" Value="3months"></asp:ListItem>
                                <asp:ListItem Text="Last 6 Months" Value="6months"></asp:ListItem>
                                <asp:ListItem Text="Custom Range" Value="custom"></asp:ListItem>
                            </asp:DropDownList>
                        </div>
                    </div>

                    <!-- Custom Date Range (initially hidden) -->
                    <asp:Panel ID="pnlCustomDateRange" runat="server" CssClass="row" Visible="false">
                        <div class="col-md-3 mb-3">
                            <label for="txtStartDate">Start Date</label>
                            <asp:TextBox ID="txtStartDate" runat="server" CssClass="form-control"
                                         TextMode="Date"></asp:TextBox>
                        </div>
                        <div class="col-md-3 mb-3">
                            <label for="txtEndDate">End Date</label>
                            <asp:TextBox ID="txtEndDate" runat="server" CssClass="form-control"
                                         TextMode="Date"></asp:TextBox>
                        </div>
                    </asp:Panel>

                    <!-- Action Buttons -->
                    <div class="row">
                        <div class="col-12">
                            <asp:Button ID="btnSearch" runat="server" Text="Search"
                                        CssClass="btn btn-primary" OnClick="btnSearch_Click">
                                <i class="fas fa-search"></i>
                            </asp:Button>
                            <asp:Button ID="btnClear" runat="server" Text="Clear Filters"
                                        CssClass="btn btn-secondary ml-2" OnClick="btnClear_Click">
                                <i class="fas fa-times"></i>
                            </asp:Button>

                            <span class="ml-3">
                                <asp:Label ID="lblResultCount" runat="server" CssClass="badge badge-info"
                                           Text="0 results" Visible="false"></asp:Label>
                            </span>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </ContentTemplate>
</asp:UpdatePanel>
