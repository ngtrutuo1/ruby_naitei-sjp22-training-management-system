document.addEventListener('turbo:load', function() {
  // Initialize dropdowns first
  initializeDropdowns();
  
  // Initialize submenu hover
  initializeSubmenu();

  // Initialize modal triggers
  initializeModalTriggers();

  function initializeModalTriggers() {
    // Handle modal trigger links
    const modalTriggers = document.querySelectorAll('[data-toggle="modal"], [data-bs-toggle="modal"]');
    modalTriggers.forEach(trigger => {
      trigger.addEventListener('click', function(e) {
        // Close all dropdowns immediately when modal trigger is clicked
        closeAllDropdowns();
        // Small delay to ensure dropdowns are closed
        setTimeout(() => {
          closeAllDropdowns();
        }, 10);
      });
    });
  }

  function closeAllDropdowns() {
    // Close all dropdown menus
    document.querySelectorAll('.dropdown').forEach(dropdown => {
      dropdown.classList.remove('open');
      const row = dropdown.closest('.trainee-row');
      if (row) row.classList.remove('dropdown-open');
    });
    
    // Hide all dropdown menus
    document.querySelectorAll('.dropdown-menu').forEach(menu => {
      menu.style.display = 'none';
    });
    
    // Remove all submenu displays
    document.querySelectorAll('.dropdown-submenu .dropdown-menu').forEach(submenu => {
      submenu.style.display = 'none';
    });
  }

  function initializeSubmenu() {
    const submenuItems = document.querySelectorAll('.dropdown-submenu');
    
    submenuItems.forEach(function(submenu) {
      const submenuToggle = submenu.querySelector('.dropdown-item');
      const submenuDropdown = submenu.querySelector('.dropdown-menu');
      
      if (submenuToggle && submenuDropdown) {
        submenuToggle.addEventListener('mouseenter', function() {
          submenuDropdown.style.display = 'block';
        });
        
        submenu.addEventListener('mouseleave', function() {
          submenuDropdown.style.display = 'none';
        });
      }
    });
  }

  function initializeDropdowns() {
    const dropdownToggles = document.querySelectorAll('.dropdown-toggle');
    dropdownToggles.forEach(toggle => {
      toggle.addEventListener('click', function(e) {
        e.preventDefault();
        e.stopPropagation();
        
        // Close all other dropdowns and remove z-index elevation from rows
        document.querySelectorAll('.dropdown').forEach(dropdown => {
          if (dropdown !== this.closest('.dropdown')) {
            dropdown.classList.remove('open');
            const row = dropdown.closest('.trainee-row');
            if (row) row.classList.remove('dropdown-open');
          }
        });
        
        // Toggle current dropdown
        const dropdown = this.closest('.dropdown');
        const row = this.closest('.trainee-row');
        
        if (dropdown) {
          const isOpening = !dropdown.classList.contains('open');
          dropdown.classList.toggle('open');
          
          // Add or remove z-index elevation to the row
          if (row) {
            if (isOpening) {
              row.classList.add('dropdown-open');
            } else {
              row.classList.remove('dropdown-open');
            }
          }
        }
      });
    });
    
    // Close dropdown when clicking outside
    document.addEventListener('click', function(e) {
      if (!e.target.closest('.dropdown')) {
        document.querySelectorAll('.dropdown').forEach(dropdown => {
          dropdown.classList.remove('open');
          const row = dropdown.closest('.trainee-row');
          if (row) row.classList.remove('dropdown-open');
        });
      }
    });
  }

  const selectAll = document.getElementById('select-all');
  const checkboxes = document.querySelectorAll('.trainee-checkbox');
  const bulkActions = document.querySelector('.bulk-actions');
  const bulkDeleteBtn = document.getElementById('bulk-delete-btn');
  const bulkDeactivateBtn = document.getElementById('bulk-deactivate-btn');
  const selectedCount = document.querySelector('.selected-count');
  const clearSearchBtn = document.querySelector('.clear-search');

  // Clear search functionality
  if (clearSearchBtn) {
    clearSearchBtn.addEventListener('click', function() {
      const searchInput = document.querySelector('.search-input');
      searchInput.value = '';
      searchInput.form.submit();
    });
  }

  // Select/Deselect all functionality
  selectAll.addEventListener('change', function() {
    checkboxes.forEach(checkbox => {
      checkbox.checked = this.checked;
    });
    updateBulkActions();
  });

  // Individual checkbox change
  checkboxes.forEach(checkbox => {
    checkbox.addEventListener('change', function() {
      const checkedCount = document.querySelectorAll('.trainee-checkbox:checked').length;
      selectAll.checked = checkedCount === checkboxes.length;
      selectAll.indeterminate = checkedCount > 0 && checkedCount < checkboxes.length;
      updateBulkActions();
    });
  });

  function updateBulkActions() {
    const checkedCount = document.querySelectorAll('.trainee-checkbox:checked').length;
    const anyChecked = checkedCount > 0;
    
    bulkActions.style.display = anyChecked ? 'block' : 'none';
    if (selectedCount) {
      selectedCount.textContent = checkedCount;
    }
  }

  // Bulk deactivate functionality
  bulkDeactivateBtn.addEventListener('click', function() {
    const selectedIds = getSelectedIds();
    if (selectedIds.length === 0) {
      alert('<%= t("supervisor.users.no_selection") %>');
      return;
    }

    performBulkAction('supervisor/users/bulk_deactivate', selectedIds, 'PATCH');
  });

  function getSelectedIds() {
    const checkedBoxes = document.querySelectorAll('.trainee-checkbox:checked');
    return Array.from(checkedBoxes).map(checkbox => checkbox.value);
  }

  function performBulkAction(url, ids, method) {
    const form = document.createElement('form');
    form.method = 'POST';
    form.action = url;

    // Add CSRF token
    const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content');
    const csrfInput = document.createElement('input');
    csrfInput.type = 'hidden';
    csrfInput.name = 'authenticity_token';
    csrfInput.value = csrfToken;
    form.appendChild(csrfInput);

    // Add method override for PATCH/DELETE
    if (method !== 'POST') {
      const methodInput = document.createElement('input');
      methodInput.type = 'hidden';
      methodInput.name = '_method';
      methodInput.value = method;
      form.appendChild(methodInput);
    }

    // Add selected IDs
    ids.forEach(id => {
      const idInput = document.createElement('input');
      idInput.type = 'hidden';
      idInput.name = 'trainee_ids[]';
      idInput.value = id;
      form.appendChild(idInput);    
    });

    document.body.appendChild(form);
    form.submit();
  }

  // Edit Profile Modal functionality
  const editProfileModal = document.getElementById('editProfileModal');
  const editProfileForm = document.getElementById('editProfileForm');

  if (editProfileModal && editProfileForm) {
    // Multiple event listeners to ensure dropdowns close
    // Bootstrap 4 syntax (jQuery)
    if (window.$ && window.$.fn.modal) {
      $(editProfileModal).on('show.bs.modal', function() {
        closeAllDropdowns();
        clearFormErrors();
      });
    }

    // Bootstrap 5 syntax (vanilla JS)
    editProfileModal.addEventListener('show.bs.modal', function() {
      closeAllDropdowns();
      clearFormErrors();
    });

    // Backup - close dropdowns when modal is fully shown
    editProfileModal.addEventListener('shown.bs.modal', function() {
      closeAllDropdowns();
    });

    // Handle form submission (regular form submission, not AJAX)
    editProfileForm.addEventListener('submit', function(event) {
      // Let the form submit normally to the server
      // No need to prevent default - we want regular form submission
    });

    function clearFormErrors() {
      const invalidFields = document.querySelectorAll('.is-invalid');
      const feedbackElements = document.querySelectorAll('.invalid-feedback');
      
      invalidFields.forEach(field => field.classList.remove('is-invalid'));
      feedbackElements.forEach(feedback => feedback.textContent = '');
    }
  }
});
