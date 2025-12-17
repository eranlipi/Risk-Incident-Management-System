document.addEventListener('DOMContentLoaded', function() {
    // Initialize filter elements by their new CSS classes
    const filterInputs = {
        keyword: document.querySelector('.js-filter-keyword'),
        department: document.querySelector('.js-filter-dept'),
        location: document.querySelector('.js-filter-loc'),
        category: document.querySelector('.js-filter-cat'),
        severity: document.querySelector('.js-filter-sev'),
        status: document.querySelector('.js-filter-status'),
        dateRange: document.querySelector('.js-filter-date'),
        startDate: document.querySelector('.js-date-start'),
        endDate: document.querySelector('.js-date-end')
    };

    const customDatePanel = document.querySelector('.js-custom-date-panel');
    const table = document.querySelector('.table tbody');
    if (!table) return;

    const rows = Array.from(table.querySelectorAll('tr'));
    const countLabel = document.querySelector('[id$="lblRecordCount"]');

    function filterTable() {
        const criteria = {
            keyword: filterInputs.keyword ? filterInputs.keyword.value.toLowerCase() : '',
            department: filterInputs.department ? filterInputs.department.value.toLowerCase() : '',
            location: filterInputs.location ? filterInputs.location.value.toLowerCase() : '',
            category: filterInputs.category ? filterInputs.category.value.toLowerCase() : '',
            severity: filterInputs.severity ? filterInputs.severity.value : '',
            status: filterInputs.status ? filterInputs.status.value.toLowerCase() : '',
            dateRange: filterInputs.dateRange ? filterInputs.dateRange.value : 'all',
            startDate: filterInputs.startDate ? filterInputs.startDate.value : '',
            endDate: filterInputs.endDate ? filterInputs.endDate.value : ''
        };

        let visibleCount = 0;

        rows.forEach(row => {
            // Column Indices (based on IncidentList.aspx structure):
            // 1: Title/Desc, 2: Severity, 3: Date, 4: Status, 5: Dept, 6: Loc, 7: Category (Hidden)
            
            if (row.cells.length < 7) return;

            const textTitle = row.cells[1].innerText.toLowerCase();
            const textSeverity = row.cells[2].innerText.trim();
            const textDate = row.cells[3].innerText.trim();
            const textStatus = row.cells[4].innerText.toLowerCase();
            const textDept = row.cells[5].innerText.toLowerCase();
            const textLoc = row.cells[6].innerText.toLowerCase();
            const textCat = row.cells[7] ? row.cells[7].innerText.toLowerCase() : '';

            let isMatch = true;

            if (criteria.keyword && !textTitle.includes(criteria.keyword)) isMatch = false;
            if (isMatch && criteria.department && textDept !== criteria.department) isMatch = false;
            if (isMatch && criteria.location && textLoc !== criteria.location) isMatch = false;
            if (isMatch && criteria.category && textCat !== criteria.category) isMatch = false;
            if (isMatch && criteria.severity && !textSeverity.startsWith(criteria.severity)) isMatch = false;
            if (isMatch && criteria.status && !textStatus.includes(criteria.status)) isMatch = false;

            // Date Range Logic
            if (isMatch && criteria.dateRange !== 'all') {
                const rowDate = new Date(textDate);
                const today = new Date();
                today.setHours(0,0,0,0); // Normalize today

                if (criteria.dateRange === 'custom') {
                    if (criteria.startDate) {
                        const start = new Date(criteria.startDate);
                        if (rowDate < start) isMatch = false;
                    }
                    if (isMatch && criteria.endDate) {
                        const end = new Date(criteria.endDate);
                        end.setHours(23, 59, 59, 999); // End of day
                        if (rowDate > end) isMatch = false;
                    }
                } else {
                    const diffTime = Math.abs(today - rowDate);
                    const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));

                    if (criteria.dateRange === 'today' && diffDays > 1) isMatch = false;
                    if (criteria.dateRange === '7days' && diffDays > 7) isMatch = false;
                    if (criteria.dateRange === '30days' && diffDays > 30) isMatch = false;
                    if (criteria.dateRange === '3months' && diffDays > 90) isMatch = false;
                    if (criteria.dateRange === '6months' && diffDays > 180) isMatch = false;
                }
            }

            row.style.display = isMatch ? '' : 'none';
            if (isMatch) visibleCount++;
        });

        if (countLabel) {
            countLabel.innerText = visibleCount + ' visible';
        }
    }

    // Toggle Custom Date Panel
    if (filterInputs.dateRange) {
        filterInputs.dateRange.addEventListener('change', function() {
            if (customDatePanel) {
                customDatePanel.style.display = (this.value === 'custom') ? '' : 'none';
            }
            filterTable();
        });
    }

    // Attach Event Listeners
    Object.values(filterInputs).forEach(input => {
        if (input) {
            input.addEventListener('input', filterTable);
            input.addEventListener('change', filterTable);
        }
    });

    // Clear Button Logic
    const clearBtn = document.querySelector('.js-btn-clear');
    if (clearBtn) {
        clearBtn.addEventListener('click', function(e) {
            e.preventDefault();
            
            if (filterInputs.keyword) filterInputs.keyword.value = '';
            if (filterInputs.department) filterInputs.department.selectedIndex = 0;
            if (filterInputs.location) filterInputs.location.selectedIndex = 0;
            if (filterInputs.category) filterInputs.category.selectedIndex = 0;
            if (filterInputs.severity) filterInputs.severity.selectedIndex = 0;
            if (filterInputs.status) filterInputs.status.selectedIndex = 0;
            if (filterInputs.dateRange) filterInputs.dateRange.value = 'all';
            if (filterInputs.startDate) filterInputs.startDate.value = '';
            if (filterInputs.endDate) filterInputs.endDate.value = '';

            if (customDatePanel) customDatePanel.style.display = 'none';

            filterTable();
        });
    }
});
