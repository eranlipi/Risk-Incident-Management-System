<%@ Page Title="Incident Form" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeFile="IncidentForm.aspx.cs" Inherits="Pages_IncidentForm" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="incident-form">
        <!-- Page Header -->
        <div class="row mb-4">
            <div class="col-md-8">
                <h1>
                    <i class="fas fa-file-medical-alt"></i>
                    <asp:Label ID="lblPageTitle" runat="server" Text="New Incident Report"></asp:Label>
                </h1>
            </div>
            <div class="col-md-4 text-right">
                <a href="IncidentList.aspx" class="btn btn-outline-secondary">
                    <i class="fas fa-arrow-left"></i> Back to List
                </a>
            </div>
        </div>

        <!-- Alert Messages -->
        <asp:Panel ID="pnlSuccess" runat="server" CssClass="alert alert-success" Visible="false">
            <asp:Label ID="lblSuccess" runat="server"></asp:Label>
        </asp:Panel>
        <asp:Panel ID="pnlError" runat="server" CssClass="alert alert-danger" Visible="false">
            <asp:Label ID="lblError" runat="server"></asp:Label>
        </asp:Panel>

        <!-- Incident Form -->
        <div class="row">
            <div class="col-lg-8">
                <div class="card">
                    <div class="card-header">
                        <h5 class="mb-0">Incident Details</h5>
                    </div>
                    <div class="card-body">
                        <!-- Title -->
                        <div class="form-group">
                            <label for="txtTitle">Title <span class="text-danger">*</span></label>
                            <asp:TextBox ID="txtTitle" runat="server" CssClass="form-control"
                                         MaxLength="200" placeholder="Brief description of the incident"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="rfvTitle" runat="server"
                                ControlToValidate="txtTitle" ErrorMessage="Title is required"
                                CssClass="text-danger" Display="Dynamic"></asp:RequiredFieldValidator>
                        </div>

                        <!-- Description -->
                        <div class="form-group">
                            <label for="txtDescription">Description</label>
                            <asp:TextBox ID="txtDescription" runat="server" CssClass="form-control"
                                         TextMode="MultiLine" Rows="4"
                                         placeholder="Detailed description of what happened..."></asp:TextBox>
                        </div>

                        <!-- Row: Severity, Date, Status -->
                        <div class="row">
                            <div class="col-md-4">
                                <div class="form-group">
                                    <label for="ddlSeverity">Severity <span class="text-danger">*</span></label>
                                    <asp:DropDownList ID="ddlSeverity" runat="server" CssClass="form-control">
                                        <asp:ListItem Value="1">1 - Low</asp:ListItem>
                                        <asp:ListItem Value="2">2 - Moderate</asp:ListItem>
                                        <asp:ListItem Value="3" Selected="True">3 - Significant</asp:ListItem>
                                        <asp:ListItem Value="4">4 - High</asp:ListItem>
                                        <asp:ListItem Value="5">5 - Critical</asp:ListItem>
                                    </asp:DropDownList>
                                </div>
                            </div>
                            <div class="col-md-4">
                                <div class="form-group">
                                    <label for="txtIncidentDate">Incident Date <span class="text-danger">*</span></label>
                                    <asp:TextBox ID="txtIncidentDate" runat="server" CssClass="form-control"
                                                 TextMode="DateTimeLocal"></asp:TextBox>
                                    <asp:RequiredFieldValidator ID="rfvIncidentDate" runat="server"
                                        ControlToValidate="txtIncidentDate" ErrorMessage="Date is required"
                                        CssClass="text-danger" Display="Dynamic"></asp:RequiredFieldValidator>
                                    <asp:CustomValidator ID="cvIncidentDate" runat="server"
                                        ControlToValidate="txtIncidentDate"
                                        OnServerValidate="cvIncidentDate_ServerValidate"
                                        ErrorMessage="Incident date cannot be in the future"
                                        CssClass="text-danger" Display="Dynamic"></asp:CustomValidator>
                                </div>
                            </div>
                            <div class="col-md-4">
                                <div class="form-group">
                                    <label for="ddlStatus">Status</label>
                                    <asp:DropDownList ID="ddlStatus" runat="server" CssClass="form-control">
                                        <asp:ListItem Value="Open" Selected="True">Open</asp:ListItem>
                                        <asp:ListItem Value="In Progress">In Progress</asp:ListItem>
                                        <asp:ListItem Value="Under Review">Under Review</asp:ListItem>
                                        <asp:ListItem Value="Closed">Closed</asp:ListItem>
                                    </asp:DropDownList>
                                </div>
                            </div>
                        </div>

                        <!-- Row: Department, Location, Category -->
                        <div class="row">
                            <div class="col-md-4">
                                <div class="form-group">
                                    <label for="ddlDepartment">Department <span class="text-danger">*</span></label>
                                    <asp:DropDownList ID="ddlDepartment" runat="server" CssClass="form-control">
                                    </asp:DropDownList>
                                    <asp:RequiredFieldValidator ID="rfvDepartment" runat="server"
                                        ControlToValidate="ddlDepartment" InitialValue=""
                                        ErrorMessage="Department is required"
                                        CssClass="text-danger" Display="Dynamic"></asp:RequiredFieldValidator>
                                </div>
                            </div>
                            <div class="col-md-4">
                                <div class="form-group">
                                    <label for="ddlLocation">Location <span class="text-danger">*</span></label>
                                    <asp:DropDownList ID="ddlLocation" runat="server" CssClass="form-control">
                                    </asp:DropDownList>
                                    <asp:RequiredFieldValidator ID="rfvLocation" runat="server"
                                        ControlToValidate="ddlLocation" InitialValue=""
                                        ErrorMessage="Location is required"
                                        CssClass="text-danger" Display="Dynamic"></asp:RequiredFieldValidator>
                                </div>
                            </div>
                            <div class="col-md-4">
                                <div class="form-group">
                                    <label for="ddlCategory">Category <span class="text-danger">*</span></label>
                                    <asp:DropDownList ID="ddlCategory" runat="server" CssClass="form-control">
                                    </asp:DropDownList>
                                    <asp:RequiredFieldValidator ID="rfvCategory" runat="server"
                                        ControlToValidate="ddlCategory" InitialValue=""
                                        ErrorMessage="Category is required"
                                        CssClass="text-danger" Display="Dynamic"></asp:RequiredFieldValidator>
                                </div>
                            </div>
                        </div>

                        <!-- Row: Additional Info -->
                        <div class="row">
                            <div class="col-md-4">
                                <div class="form-group">
                                    <div class="custom-control custom-checkbox">
                                        <asp:CheckBox ID="chkInjuries" runat="server" CssClass="custom-control-input" />
                                        <label class="custom-control-label" for="chkInjuries">
                                            Injuries Reported
                                        </label>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-4">
                                <div class="form-group">
                                    <label for="txtWitnessCount">Witness Count</label>
                                    <asp:TextBox ID="txtWitnessCount" runat="server" CssClass="form-control"
                                                 TextMode="Number" Text="0"></asp:TextBox>
                                    <asp:RangeValidator ID="rvWitnessCount" runat="server"
                                        ControlToValidate="txtWitnessCount"
                                        MinimumValue="0" MaximumValue="100" Type="Integer"
                                        ErrorMessage="Witness count must be between 0 and 100"
                                        CssClass="text-danger" Display="Dynamic"></asp:RangeValidator>
                                </div>
                            </div>
                            <div class="col-md-4">
                                <div class="form-group">
                                    <label for="txtEstimatedCost">Estimated Cost ($)</label>
                                    <asp:TextBox ID="txtEstimatedCost" runat="server" CssClass="form-control"
                                                 TextMode="Number" step="0.01"></asp:TextBox>
                                </div>
                            </div>
                        </div>

                        <!-- Root Cause Analysis -->
                        <asp:Panel ID="pnlRootCause" runat="server" Visible="false">
                            <div class="form-group">
                                <label for="txtRootCause">Root Cause Analysis</label>
                                <asp:TextBox ID="txtRootCause" runat="server" CssClass="form-control"
                                             TextMode="MultiLine" Rows="3"
                                             placeholder="Analysis of root causes..."></asp:TextBox>
                            </div>
                        </asp:Panel>

                        <!-- Action Buttons -->
                        <asp:Panel ID="pnlButtons" runat="server">
                            <div class="form-group mt-4">
                                <asp:Button ID="btnSave" runat="server" Text="Save Incident"
                                            CssClass="btn btn-primary btn-lg" OnClick="btnSave_Click" />
                                <asp:Button ID="btnCancel" runat="server" Text="Cancel"
                                            CssClass="btn btn-secondary btn-lg ml-2"
                                            CausesValidation="false" OnClick="btnCancel_Click" />
                            </div>
                        </asp:Panel>
                    </div>
                </div>
            </div>

            <!-- Sidebar -->
            <div class="col-lg-4">
                <!-- Incident Info (View Mode) -->
                <asp:Panel ID="pnlIncidentInfo" runat="server" Visible="false">
                    <div class="card mb-3">
                        <div class="card-header">
                            <h5 class="mb-0">Incident Information</h5>
                        </div>
                        <div class="card-body">
                            <p>
                                <strong>Incident ID:</strong>
                                <asp:Label ID="lblIncidentId" runat="server"></asp:Label>
                            </p>
                            <p>
                                <strong>Created:</strong>
                                <asp:Label ID="lblCreatedDate" runat="server"></asp:Label>
                            </p>
                            <p>
                                <strong>Last Modified:</strong>
                                <asp:Label ID="lblLastModified" runat="server"></asp:Label>
                            </p>
                            <p>
                                <strong>Reported By:</strong>
                                <asp:Label ID="lblReportedBy" runat="server"></asp:Label>
                            </p>
                        </div>
                    </div>
                </asp:Panel>

                <!-- Help Card -->
                <div class="card">
                    <div class="card-header bg-info text-white">
                        <h5 class="mb-0"><i class="fas fa-info-circle"></i> Guidelines</h5>
                    </div>
                    <div class="card-body">
                        <h6>Severity Levels:</h6>
                        <ul class="small">
                            <li><strong>1-Low:</strong> Minor issue, no injuries</li>
                            <li><strong>2-Moderate:</strong> Property damage, minor injury</li>
                            <li><strong>3-Significant:</strong> Notable impact, injury requiring treatment</li>
                            <li><strong>4-High:</strong> Serious injury, significant property damage</li>
                            <li><strong>5-Critical:</strong> Fatality, major accident</li>
                        </ul>

                        <hr />

                        <h6>Required Fields:</h6>
                        <p class="small">
                            Title, Incident Date, Severity, Department, Location, and Category are required.
                        </p>
                    </div>
                </div>
            </div>
        </div>

        <!-- Corrective Actions (Edit/View Mode) -->
        <asp:Panel ID="pnlActions" runat="server" Visible="false" CssClass="mt-4">
            <div class="card">
                <div class="card-header">
                    <h5 class="mb-0"><i class="fas fa-tasks"></i> Corrective Actions</h5>
                </div>
                <div class="card-body">
                    <asp:GridView ID="gvActions" runat="server" CssClass="table table-bordered"
                                  AutoGenerateColumns="False" GridLines="None">
                        <Columns>
                            <asp:BoundField DataField="ActionID" HeaderText="ID" />
                            <asp:BoundField DataField="ActionDescription" HeaderText="Description" />
                            <asp:BoundField DataField="ActionType" HeaderText="Type" />
                            <asp:BoundField DataField="AssignedTo" HeaderText="Assigned To" />
                            <asp:BoundField DataField="DueDate" HeaderText="Due Date" DataFormatString="{0:MMM dd, yyyy}" />
                            <asp:BoundField DataField="Status" HeaderText="Status" />
                        </Columns>
                        <EmptyDataTemplate>
                            <p class="text-muted">No corrective actions assigned yet.</p>
                        </EmptyDataTemplate>
                    </asp:GridView>
                </div>
            </div>
        </asp:Panel>
    </div>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="ScriptsContent" runat="server">
</asp:Content>
