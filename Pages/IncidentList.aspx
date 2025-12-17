<%@ Page Title="Incident List" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeFile="IncidentList.aspx.cs" Inherits="Pages_IncidentList" %>
<%@ Register Src="~/Controls/FilterPanel.ascx" TagPrefix="uc" TagName="FilterPanel" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="incident-list">
        <!-- Page Header -->
        <div class="row mb-4">
            <div class="col-md-8">
                <h1><i class="fas fa-list"></i> Incident List</h1>
                <p class="text-muted">View and manage all reported incidents</p>
            </div>
            <div class="col-md-4 text-right">
                <a href="IncidentForm.aspx" class="btn btn-primary">
                    <i class="fas fa-plus-circle"></i> New Incident
                </a>
            </div>
        </div>

        <asp:UpdatePanel ID="UpdatePanelMain" runat="server" UpdateMode="Conditional">
            <ContentTemplate>
                <!-- Filter Panel -->
                <div class="row mb-4">
                    <div class="col-12">
                        <uc:FilterPanel ID="FilterPanel1" runat="server" />
                    </div>
                </div>

                <!-- Incidents GridView -->
                <div class="row">
                    <div class="col-12">
                        <div class="card">
                            <div class="card-header">
                                <div class="row">
                                    <div class="col-md-6">
                                        <h5 class="mb-0">
                                            <i class="fas fa-table"></i> Incidents
                                            <asp:Label ID="lblRecordCount" runat="server" CssClass="badge badge-secondary ml-2"></asp:Label>
                                        </h5>
                                    </div>
                                    <div class="col-md-6 text-right">
                                        <asp:Button ID="btnExportExcel" runat="server" Text="Export to Excel"
                                                    CssClass="btn btn-sm btn-success" OnClick="btnExportExcel_Click" />
                                    </div>
                                </div>
                            </div>
                            <div class="card-body p-0">
                                <asp:GridView ID="gvIncidents" runat="server" CssClass="table table-striped table-hover mb-0"
                                              AutoGenerateColumns="False" AllowPaging="False" AllowSorting="True"
                                              PageSize="5000" GridLines="None" EnableViewState="false"
                                              OnPageIndexChanging="gvIncidents_PageIndexChanging"
                                              OnSorting="gvIncidents_Sorting"
                                              OnRowCommand="gvIncidents_RowCommand">
                                    <Columns>
                                        <asp:TemplateField HeaderText="ID" SortExpression="IncidentID">
                                            <ItemTemplate>
                                                <a href='IncidentForm.aspx?id=<%# Eval("IncidentID") %>&mode=view'>
                                                    #<%# Eval("IncidentID") %>
                                                </a>
                                            </ItemTemplate>
                                        </asp:TemplateField>

                                        <asp:TemplateField HeaderText="Title" SortExpression="Title">
                                            <ItemTemplate>
                                                <strong><%# Eval("Title") %></strong>
                                                <asp:Panel ID="pnlDescription" runat="server" Visible='<%# !string.IsNullOrEmpty(Eval("Description").ToString()) %>'>
                                                    <small class="text-muted d-block">
                                                        <%# TruncateText(Eval("Description").ToString(), 100) %>
                                                    </small>
                                                </asp:Panel>
                                            </ItemTemplate>
                                        </asp:TemplateField>

                                        <asp:TemplateField HeaderText="Severity" SortExpression="Severity">
                                            <ItemTemplate>
                                                <span class='<%# GetSeverityBadgeClass(Eval("Severity")) %>'>
                                                    <%# Eval("Severity") %> - <%# IncidentManager.GetSeverityLabel(Convert.ToInt32(Eval("Severity"))) %>
                                                </span>
                                            </ItemTemplate>
                                        </asp:TemplateField>

                                        <asp:BoundField DataField="IncidentDate" HeaderText="Date"
                                                        SortExpression="IncidentDate"
                                                        DataFormatString="{0:MMM dd, yyyy}" />

                                        <asp:TemplateField HeaderText="Status" SortExpression="Status">
                                            <ItemTemplate>
                                                <span class='<%# IncidentManager.GetStatusClass(Eval("Status").ToString()) %>'>
                                                    <%# Eval("Status") %>
                                                </span>
                                            </ItemTemplate>
                                        </asp:TemplateField>

                                        <asp:BoundField DataField="DepartmentName" HeaderText="Department"
                                                        SortExpression="DepartmentName" />

                                        <asp:BoundField DataField="LocationName" HeaderText="Location"
                                                        SortExpression="LocationName" />

                                        <asp:BoundField DataField="CategoryName" HeaderText="Category" 
                                                        ItemStyle-CssClass="d-none" HeaderStyle-CssClass="d-none" />

                                        <asp:BoundField DataField="ReportedBy" HeaderText="Reported By" />

                                        <asp:TemplateField HeaderText="Injuries">
                                            <ItemTemplate>
                                                <span class='<%# Convert.ToBoolean(Eval("InjuriesReported")) ? "text-danger" : "text-muted" %>'>
                                                    <%# Convert.ToBoolean(Eval("InjuriesReported")) ? "Yes" : "No" %>
                                                </span>
                                            </ItemTemplate>
                                        </asp:TemplateField>

                                        <asp:TemplateField HeaderText="Actions">
                                            <ItemTemplate>
                                                <div class="btn-group" role="group">
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
                                                    <a href='IncidentForm.aspx?id=<%# Eval("IncidentID") %>&mode=edit'
                                                       class="btn btn-sm btn-outline-secondary" title="Edit">
                                                        <i class="fas fa-edit"></i>
                                                    </a>
                                                    <asp:LinkButton ID="btnDelete" runat="server"
                                                                    CssClass="btn btn-sm btn-outline-danger"
                                                                    CommandName="DeleteIncident"
                                                                    CommandArgument='<%# Eval("IncidentID") %>'
                                                                    OnClientClick="return confirm('Are you sure you want to archive this incident?');"
                                                                    title="Archive"
                                                                    Text="Delete" />
                                                </div>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                    </Columns>

                                    <PagerSettings Mode="NumericFirstLast" PageButtonCount="10"
                                                   FirstPageText="First" LastPageText="Last" />

                                    <PagerStyle CssClass="pagination-ys" HorizontalAlign="Center" />

                                    <EmptyDataTemplate>
                                        <div class="alert alert-info m-3">
                                            <i class="fas fa-info-circle"></i> No incidents found matching your criteria.
                                        </div>
                                    </EmptyDataTemplate>
                                </asp:GridView>
                            </div>
                        </div>

                        <asp:Label ID="lblMessage" runat="server" CssClass="alert alert-success mt-3 d-block"
                                   Visible="false"></asp:Label>
                        <asp:Label ID="lblError" runat="server" CssClass="alert alert-danger mt-3 d-block"
                                   Visible="false"></asp:Label>
                    </div>
                </div>
            </ContentTemplate>
        </asp:UpdatePanel>
    </div>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="ScriptsContent" runat="server">
    <script src="../Scripts/incident-filter.js"></script>
</asp:Content>
