document.addEventListener('DOMContentLoaded', function() {
  initializeSubjectsPage();
});

document.addEventListener('turbo:load', function() {
  initializeSubjectsPage();
});

function initializeSubjectsPage() {
  // Prevent dropdown menu from closing when clicking inside
  const dropdownMenus = document.querySelectorAll('.assessment-dropdown-menu');
  dropdownMenus.forEach(menu => {
    menu.removeEventListener('click', handleMenuClick);
    menu.addEventListener('click', handleMenuClick);
  });

  // Subject link click handler
  const subjectLinks = document.querySelectorAll('.subject-link');
  subjectLinks.forEach(link => {
    link.removeEventListener('click', handleSubjectLinkClick);
    link.addEventListener('click', handleSubjectLinkClick);
  });
}

function handleMenuClick(e) {
  e.stopPropagation();
}

function handleSubjectLinkClick(e) {
  // Don't prevent default - let the link work normally
  // Just add loading state for visual feedback
  
  // Add loading state
  this.style.opacity = '0.6';
  this.style.pointerEvents = 'none';
  
  // The browser will navigate to the href automatically
  // No need to prevent default or manually navigate
}
