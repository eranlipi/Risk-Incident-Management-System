// Chart utilities for Incident Management System Dashboard

(function() {
    'use strict';

    // Default chart colors
    var chartColors = {
        primary: '#007bff',
        success: '#28a745',
        warning: '#ffc107',
        danger: '#dc3545',
        info: '#17a2b8',
        secondary: '#6c757d'
    };

    // Create a severity distribution chart
    window.createSeverityChart = function(canvasId, data) {
        var ctx = document.getElementById(canvasId);
        if (!ctx) return null;

        return new Chart(ctx, {
            type: 'doughnut',
            data: {
                labels: data.labels || ['Critical', 'High', 'Medium', 'Low'],
                datasets: [{
                    data: data.values || [0, 0, 0, 0],
                    backgroundColor: [
                        chartColors.danger,
                        chartColors.warning,
                        chartColors.info,
                        chartColors.success
                    ],
                    borderWidth: 2,
                    borderColor: '#fff'
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        position: 'bottom',
                        labels: {
                            padding: 15,
                            font: {
                                size: 12
                            }
                        }
                    },
                    tooltip: {
                        callbacks: {
                            label: function(context) {
                                var label = context.label || '';
                                var value = context.parsed || 0;
                                var total = context.dataset.data.reduce((a, b) => a + b, 0);
                                var percentage = total > 0 ? ((value / total) * 100).toFixed(1) : 0;
                                return label + ': ' + value + ' (' + percentage + '%)';
                            }
                        }
                    }
                }
            }
        });
    };

    // Create a status distribution chart
    window.createStatusChart = function(canvasId, data) {
        var ctx = document.getElementById(canvasId);
        if (!ctx) return null;

        return new Chart(ctx, {
            type: 'bar',
            data: {
                labels: data.labels || ['Open', 'In Progress', 'Resolved', 'Closed'],
                datasets: [{
                    label: 'Incidents',
                    data: data.values || [0, 0, 0, 0],
                    backgroundColor: [
                        chartColors.danger,
                        chartColors.warning,
                        chartColors.info,
                        chartColors.success
                    ],
                    borderWidth: 0
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        display: false
                    },
                    tooltip: {
                        callbacks: {
                            label: function(context) {
                                return 'Count: ' + context.parsed.y;
                            }
                        }
                    }
                },
                scales: {
                    y: {
                        beginAtZero: true,
                        ticks: {
                            stepSize: 1
                        }
                    }
                }
            }
        });
    };

    // Create a trends chart (line chart)
    window.createTrendsChart = function(canvasId, data) {
        var ctx = document.getElementById(canvasId);
        if (!ctx) return null;

        return new Chart(ctx, {
            type: 'line',
            data: {
                labels: data.labels || [],
                datasets: [{
                    label: 'Incidents',
                    data: data.values || [],
                    borderColor: chartColors.primary,
                    backgroundColor: 'rgba(0, 123, 255, 0.1)',
                    tension: 0.4,
                    fill: true,
                    pointRadius: 4,
                    pointHoverRadius: 6
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        display: false
                    },
                    tooltip: {
                        mode: 'index',
                        intersect: false
                    }
                },
                scales: {
                    y: {
                        beginAtZero: true,
                        ticks: {
                            stepSize: 1
                        }
                    }
                }
            }
        });
    };

    // Create a category distribution chart
    window.createCategoryChart = function(canvasId, data) {
        var ctx = document.getElementById(canvasId);
        if (!ctx) return null;

        return new Chart(ctx, {
            type: 'horizontalBar',
            data: {
                labels: data.labels || [],
                datasets: [{
                    label: 'Incidents by Category',
                    data: data.values || [],
                    backgroundColor: chartColors.primary,
                    borderWidth: 0
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                indexAxis: 'y',
                plugins: {
                    legend: {
                        display: false
                    }
                },
                scales: {
                    x: {
                        beginAtZero: true,
                        ticks: {
                            stepSize: 1
                        }
                    }
                }
            }
        });
    };

    // Utility function to update chart data
    window.updateChartData = function(chart, newData) {
        if (!chart) return;

        if (newData.labels) {
            chart.data.labels = newData.labels;
        }
        if (newData.values && chart.data.datasets[0]) {
            chart.data.datasets[0].data = newData.values;
        }

        chart.update();
    };

    // Utility function to destroy chart
    window.destroyChart = function(chart) {
        if (chart) {
            chart.destroy();
        }
    };

})();

// Added initializer to provide the missing initializeDashboardCharts function
(function () {
    'use strict';

    function readHiddenJson(suffixId) {
        try {
            var el = document.querySelector('[id$="' + suffixId + '"]');
            if (!el) return null;
            var raw = el.value || el.getAttribute('value') || '';
            if (!raw) return null;
            return JSON.parse(raw);
        } catch (e) {
            // If parsing fails, return null so callers can fallback
            if (window.console) console.warn('readHiddenJson parse failed for', suffixId, e);
            return null;
        }
    }

    function normalizeChartData(obj) {
        if (!obj) return { labels: [], values: [] };
        var labels = obj.labels || obj.label || [];
        var values = obj.values || obj.data || obj.values || [];
        return { labels: labels, values: values };
    }

    window.initializeDashboardCharts = function () {
        try {
            var monthDataRaw = readHiddenJson('hfIncidentsByMonth');
            var deptDataRaw = readHiddenJson('hfIncidentsByDepartment');
            var sevDataRaw = readHiddenJson('hfIncidentsBySeverity');
            var catDataRaw = readHiddenJson('hfTopCategories');

            var monthData = normalizeChartData(monthDataRaw);
            var deptData = normalizeChartData(deptDataRaw);
            var sevData = normalizeChartData(sevDataRaw);
            var catData = normalizeChartData(catDataRaw);

            // create* functions return Chart instances or null
            try { window.monthChart = window.createTrendsChart('chartIncidentsByMonth', monthData); } catch (e) { if (window.console) console.error(e); }
            try { window.deptChart = window.createStatusChart('chartIncidentsByDepartment', deptData); } catch (e) { if (window.console) console.error(e); }
            try { window.sevChart = window.createSeverityChart('chartIncidentsBySeverity', sevData); } catch (e) { if (window.console) console.error(e); }
            try { window.catChart = window.createCategoryChart('chartTopCategories', catData); } catch (e) { if (window.console) console.error(e); }
        } catch (err) {
            if (window.console) console.error('initializeDashboardCharts error', err);
        }
    };

})();
