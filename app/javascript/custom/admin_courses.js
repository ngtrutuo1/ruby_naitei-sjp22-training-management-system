document.addEventListener('DOMContentLoaded', function() {
  initializeAdminCoursesPage();
});

document.addEventListener('turbo:load', function() {
  initializeAdminCoursesPage();
});

function initializeAdminCoursesPage() {
  // Initialize dropdown toggles
  initializeDropdowns();
  
  // Initialize action confirmations
  initializeActionConfirmations();
}

function initializeDropdowns() {
  const dropdownToggles = document.querySelectorAll('.dropdown-toggle');
  
  dropdownToggles.forEach(toggle => {
    toggle.removeEventListener('click', handleDropdownToggle);
    toggle.addEventListener('click', handleDropdownToggle);
  });

  // Close dropdowns when clicking outside
  document.removeEventListener('click', handleOutsideClick);
  document.addEventListener('click', handleOutsideClick);
}

function handleDropdownToggle(e) {
  e.preventDefault();
  e.stopPropagation();
  
  const dropdown = this.closest('.dropdown');
  const menu = dropdown.querySelector('.dropdown-menu');
  
  // Close all other dropdowns
  closeAllDropdowns();
  
  // Toggle current dropdown
  if (menu.style.display === 'block') {
    menu.style.display = 'none';
  } else {
    menu.style.display = 'block';
  }
}

function handleOutsideClick(e) {
  if (!e.target.closest('.dropdown')) {
    closeAllDropdowns();
  }
}

function closeAllDropdowns() {
  const dropdownMenus = document.querySelectorAll('.dropdown-menu');
  dropdownMenus.forEach(menu => {
    menu.style.display = 'none';
  });
}

function initializeActionConfirmations() {
  const confirmButtons = document.querySelectorAll('[data-confirm]');
  
  confirmButtons.forEach(button => {
    button.removeEventListener('click', handleConfirmAction);
    button.addEventListener('click', handleConfirmAction);
  });
}

function handleConfirmAction(e) {
  const confirmMessage = this.dataset.confirm;
  
  if (confirmMessage && !confirm(confirmMessage)) {
    e.preventDefault();
    e.stopPropagation();
    return false;
  }
  
  // Add loading state
  this.style.opacity = '0.6';
  this.style.pointerEvents = 'none';
  
  // Add loading text if it's a button
  if (this.tagName === 'BUTTON') {
    const originalText = this.textContent;
    this.textContent = 'Processing...';
    
    // Reset after timeout (in case of navigation failure)
    setTimeout(() => {
      this.textContent = originalText;
      this.style.opacity = '1';
      this.style.pointerEvents = 'auto';
    }, 5000);
  }
}

// Bootstrap dropdown compatibility
function initializeBootstrapDropdowns() {
  if (typeof bootstrap !== 'undefined') {
    const dropdownElementList = [].slice.call(document.querySelectorAll('.dropdown-toggle'));
    const dropdownList = dropdownElementList.map(function (dropdownToggleEl) {
      return new bootstrap.Dropdown(dropdownToggleEl);
    });
  }
}

// Initialize Bootstrap dropdowns if available
document.addEventListener('DOMContentLoaded', initializeBootstrapDropdowns);
document.addEventListener('turbo:load', initializeBootstrapDropdowns);
