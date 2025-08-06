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
  e.preventDefault();

  // Add loading state
  this.style.opacity = '0.6';
  this.style.pointerEvents = 'none';

  // Reset after a short delay (replace with actual navigation)
  setTimeout(() => {
    this.style.opacity = '1';
    this.style.pointerEvents = 'auto';
  }, 1000);

  // Add your navigation logic here
  // const subjectId = this.closest('.subject-item').dataset.subjectId;
  // window.location.href = `/courses/${courseId}/subjects/${subjectId}/detail`;
}
