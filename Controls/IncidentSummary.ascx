<%@ Control Language="C#" AutoEventWireup="true" CodeFile="IncidentSummary.ascx.cs" Inherits="Controls_IncidentSummary" %>

<div class="card incident-summary mb-3">
    <div class="card-header <%= GetSeverityClass() %>">
        <div class="row">
            <div class="col-md-8">
                <h5 class="card-title mb-0">
                    <i class="fas fa-exclamation-triangle"></i>
                    <asp:Label ID="lblTitle" runat="server"></asp:Label>
                </h5>
            </div>
            <div class="col-md-4 text-right">
                <span class="badge badge-light">
                    <asp:Label ID="lblIncidentId" runat="server"></asp:Label>
                </span>
            </div>
        </div>
    </div>
    <div class="card-body">
        <div class="row">
            <div class="col-md-6">
                <p class="mb-2">
                    <strong><i class="fas fa-calendar-alt"></i> Date:</strong>
                    <asp:Label ID="lblIncidentDate" runat="server"></asp:Label>
                </p>
                <p class="mb-2">
                    <strong><i class="fas fa-building"></i> Department:</strong>
                    <asp:Label ID="lblDepartment" runat="server"></asp:Label>
                </p>
                <p class="mb-2">
                    <strong><i class="fas fa-map-marker-alt"></i> Location:</strong>
                    <asp:Label ID="lblLocation" runat="server"></asp:Label>
                </p>
            </div>
            <div class="col-md-6">
                <p class="mb-2">
                    <strong><i class="fas fa-tag"></i> Category:</strong>
                    <asp:Label ID="lblCategory" runat="server"></asp:Label>
                </p>
                <p class="mb-2">
                    <strong><i class="fas fa-thermometer-half"></i> Severity:</strong>
                    <span class="<%= GetSeverityBadgeClass() %>">
                        <asp:Label ID="lblSeverity" runat="server"></asp:Label>
                    </span>
                </p>
                <p class="mb-2">
                    <strong><i class="fas fa-info-circle"></i> Status:</strong>
                    <span class="<%= GetStatusBadgeClass() %>">
                        <asp:Label ID="lblStatus" runat="server"></asp:Label>
                    </span>
                </p>
            </div>
        </div>

        <asp:Panel ID="pnlDescription" runat="server" CssClass="mt-2" Visible="false">
            <p class="text-muted">
                <asp:Label ID="lblDescription" runat="server"></asp:Label>
            </p>
        </asp:Panel>

        <div class="mt-3">
            <asp:HyperLink ID="lnkViewDetails" runat="server" CssClass="btn btn-sm btn-primary">
                <i class="fas fa-eye"></i> View Details
            </asp:HyperLink>
            <asp:HyperLink ID="lnkEdit" runat="server" CssClass="btn btn-sm btn-secondary ml-2">
                <i class="fas fa-edit"></i> Edit
            </asp:HyperLink>
        </div>
    </div>
    <div class="card-footer text-muted">
        <small>
            <i class="fas fa-user"></i> Reported by:
            <asp:Label ID="lblReportedBy" runat="server"></asp:Label>
        </small>
    </div>
</div>
