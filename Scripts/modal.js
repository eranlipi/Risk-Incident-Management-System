$(document).ready(function () {
    // Use event delegation for GridView buttons since they might be inside UpdatePanel
    $(document).on('click', '.view-incident-btn', function () {
        var btn = $(this);
        var modal = $('#viewIncidentModal');
        
        modal.find('#modalIncidentId').text(btn.data('id'));
        modal.find('#modalTitle').text(btn.data('title'));
        modal.find('#modalDescription').text(btn.data('description'));
        modal.find('#modalSeverity').text(btn.data('severity'));
        modal.find('#modalDate').text(btn.data('date'));
        modal.find('#modalStatus').text(btn.data('status'));
        modal.find('#modalDepartment').text(btn.data('department'));
        modal.find('#modalLocation').text(btn.data('location'));
        modal.find('#modalReportedBy').text(btn.data('reportedby'));
        
        var injuries = btn.data('injuries');
        modal.find('#modalInjuries').text(injuries === 'True' || injuries === true ? 'Yes' : 'No');
        
        modal.modal('show');
    });
});
