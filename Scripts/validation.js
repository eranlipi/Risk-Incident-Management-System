// Client-side validation utilities for Incident Management System

(function() {
    'use strict';

    // Initialize validation on page load
    document.addEventListener('DOMContentLoaded', function() {
        initializeValidation();
    });

    function initializeValidation() {
        // Add validation to all forms
        var forms = document.querySelectorAll('form');
        forms.forEach(function(form) {
            // Add novalidate to prevent browser default validation
            form.setAttribute('novalidate', '');

            // Listen for submit events
            form.addEventListener('submit', function(event) {
                if (!validateForm(form)) {
                    event.preventDefault();
                    event.stopPropagation();
                }
            });
        });

        // Real-time validation for inputs
        var inputs = document.querySelectorAll('input[required], textarea[required], select[required]');
        inputs.forEach(function(input) {
            input.addEventListener('blur', function() {
                validateField(input);
            });
        });
    }

    function validateForm(form) {
        var isValid = true;
        var firstInvalidField = null;

        // Check all required fields
        var requiredFields = form.querySelectorAll('[required]');
        requiredFields.forEach(function(field) {
            if (!validateField(field)) {
                isValid = false;
                if (!firstInvalidField) {
                    firstInvalidField = field;
                }
            }
        });

        // Focus on first invalid field
        if (firstInvalidField) {
            firstInvalidField.focus();
        }

        return isValid;
    }

    function validateField(field) {
        var isValid = true;
        var errorMessage = '';

        // Remove existing error message
        removeFieldError(field);

        // Check if field is empty
        if (field.hasAttribute('required') && !field.value.trim()) {
            isValid = false;
            errorMessage = 'This field is required.';
        }
        // Check email format
        else if (field.type === 'email' && field.value) {
            var emailPattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            if (!emailPattern.test(field.value)) {
                isValid = false;
                errorMessage = 'Please enter a valid email address.';
            }
        }
        // Check number range
        else if (field.type === 'number' && field.value) {
            var value = parseFloat(field.value);
            if (field.hasAttribute('min') && value < parseFloat(field.getAttribute('min'))) {
                isValid = false;
                errorMessage = 'Value must be at least ' + field.getAttribute('min');
            }
            if (field.hasAttribute('max') && value > parseFloat(field.getAttribute('max'))) {
                isValid = false;
                errorMessage = 'Value must be at most ' + field.getAttribute('max');
            }
        }

        // Apply validation styling
        if (!isValid) {
            field.classList.add('is-invalid');
            field.classList.remove('is-valid');
            showFieldError(field, errorMessage);
        } else if (field.value) {
            field.classList.add('is-valid');
            field.classList.remove('is-invalid');
        }

        return isValid;
    }

    function showFieldError(field, message) {
        var errorDiv = document.createElement('div');
        errorDiv.className = 'invalid-feedback';
        errorDiv.textContent = message;
        errorDiv.setAttribute('data-validation-error', '');

        field.parentNode.appendChild(errorDiv);
    }

    function removeFieldError(field) {
        field.classList.remove('is-invalid', 'is-valid');
        var existingError = field.parentNode.querySelector('[data-validation-error]');
        if (existingError) {
            existingError.remove();
        }
    }

    // Export functions for use elsewhere
    window.IncidentValidation = {
        validateForm: validateForm,
        validateField: validateField
    };
})();
