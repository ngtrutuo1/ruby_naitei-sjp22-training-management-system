document.addEventListener('DOMContentLoaded', function() {
  initializeCourseEdit();
});

document.addEventListener('turbo:load', function() {
  initializeCourseEdit();
});

function initializeCourseEdit() {
  // Skip if not on course edit page
  if (!document.querySelector('.course-edit-page')) return;

  // Initialize sortable subjects
  initializeSortableSubjects();
  
  // Initialize task management
  initializeTaskManagement();
  
  // Initialize auto finish date calculation
  initializeAutoFinishDate();
}

async function initializeSortableSubjects() {
  const $ = window.jQuery;
  if (!$) return;

  // Dynamically import jQuery UI if needed
  if (!$.ui) {
    try {
      await import('jquery-ui');
      
      // Add jQuery UI CSS if not already loaded
      if (!document.querySelector('link[href*="jquery-ui"]')) {
        const link = document.createElement('link');
        link.rel = 'stylesheet';
        link.href = 'https://cdn.jsdelivr.net/npm/jquery-ui@1.13.2/dist/themes/ui-lightness/jquery-ui.css';
        document.head.appendChild(link);
      }
    } catch (error) {
      console.error('Failed to load jQuery UI:', error);
      return;
    }
  }

  $('#sortable-subjects').sortable({
    handle: '.subject-drag-handle',
    placeholder: 'subject-placeholder',
    helper: 'clone',
    opacity: 0.8,
    cursor: 'move',
    tolerance: 'pointer',
    update: function(event, ui) {
      // Update position inputs and names when order changes
      $('#sortable-subjects .subject-edit-card').each(function(index) {
        const $card = $(this);
        
        // Update position value and label
        $card.find('.position-input').val(index + 1);
        $card.find('.position-label').text('[' + (index + 1) + ']');
        
        // Update input names with new index
        $card.find('input[name*="course_subjects_attributes"]').each(function() {
          const name = $(this).attr('name');
          // Replace the first occurrence of [number] with new index
          const newName = name.replace(/\[(\d+)\]/, '[' + index + ']');
          $(this).attr('name', newName);
          
          // Update ID for finish date inputs
          if ($(this).attr('name').includes('[finish_date]')) {
            $(this).attr('id', 'course_course_subjects_attributes_' + index + '_finish_date');
          }
        });
        
        // Update data-finish-input attribute for start date inputs
        $card.find('.subject-start-date').attr('data-finish-input', 'course_course_subjects_attributes_' + index + '_finish_date');
      });
    },
    start: function(event, ui) {
      ui.helper.addClass('ui-sortable-helper');
    },
    stop: function(event, ui) {
      ui.item.removeClass('ui-sortable-helper');
    }
  });

  // Ensure placeholder class exists in CSS (no inline injection)
}

function initializeTaskManagement() {
  // Toggle task form visibility
  document.querySelectorAll('.toggle-task-form').forEach(button => {
    button.addEventListener('click', function() {
      const subjectId = this.dataset.subjectId;
      const form = document.getElementById(`tasks-form-${subjectId}`);
      if (!form) return;

      const isHidden = form.classList.contains('d-none');
      if (isHidden) {
        form.classList.remove('d-none');
        this.innerHTML = '<i class="fas fa-eye-slash"></i> Hide';
        this.classList.remove('btn-outline-success');
        this.classList.add('btn-outline-secondary');
      } else {
        form.classList.add('d-none');
        this.innerHTML = '<i class="fas fa-plus"></i> Fill more tasks';
        this.classList.remove('btn-outline-secondary');
        this.classList.add('btn-outline-success');
      }
    });
  });

  // Add new task functionality
  document.querySelectorAll('.add-new-task').forEach(button => {
    button.addEventListener('click', function() {
      const subjectId = this.dataset.subjectId;
      const container = this.closest('.new-tasks-form').querySelector('.new-tasks-list');
      const template = this.closest('.new-tasks-form').querySelector('.new-task-template');
      
      if (!template) return;
      
      const newTask = template.cloneNode(true);
      newTask.classList.remove('d-none');
      newTask.classList.remove('new-task-template');
      newTask.classList.add('new-task-item-active');
      
      // Update input names to be unique
      const timestamp = Date.now();
      const inputs = newTask.querySelectorAll('input');
      inputs.forEach(input => {
        const name = input.getAttribute('name');
        if (name) {
          const newName = name.replace('NEW_TASK_INDEX', timestamp);
          input.setAttribute('name', newName);
        }
        input.removeAttribute('disabled');
      });
      
      container.appendChild(newTask);
      
      // Focus on the first input
      const firstInput = newTask.querySelector('input[type="text"]');
      if (firstInput) {
        firstInput.focus();
      }
      
      // Add remove functionality to the new task
      const removeButton = newTask.querySelector('.remove-task');
      if (removeButton) {
        removeButton.addEventListener('click', function() {
          newTask.remove();
        });
      }
    });
  });

  // Remove task functionality for existing remove buttons
  document.querySelectorAll('.remove-task').forEach(button => {
    button.addEventListener('click', function() {
      this.closest('.new-task-item, .new-task-item-active').remove();
    });
  });
}

function initializeAutoFinishDate() {
  // Handle start date changes to auto-calculate finish date
  document.addEventListener('change', function(e) {
    if (!e.target.classList.contains('subject-start-date')) return;
    
    const startDateInput = e.target;
    const startDate = startDateInput.value;
    const durationDays = parseInt(startDateInput.dataset.durationDays);
    const finishInputId = startDateInput.dataset.finishInput;
    
    if (!startDate || !durationDays || !finishInputId) return;
    
    // Calculate finish date
    const startDateObj = new Date(startDate);
    const finishDateObj = new Date(startDateObj);
    finishDateObj.setDate(finishDateObj.getDate() + durationDays);
    
    // Format finish date for input (YYYY-MM-DD)
    const finishDateFormatted = finishDateObj.toISOString().split('T')[0];
    
    // Update hidden finish date input
    const finishInput = document.getElementById(finishInputId);
    if (finishInput) {
      finishInput.value = finishDateFormatted;
    }
    
    // Update displayed finish date (DD/MM/YYYY format)
    const finishDisplay = startDateInput.closest('.subject-dates').querySelector('.finish-date-display');
    if (finishDisplay) {
      const displayDate = finishDateObj.toLocaleDateString('vi-VN', {
        day: '2-digit',
        month: '2-digit', 
        year: 'numeric'
      });
      finishDisplay.textContent = displayDate;
    }
  });
  
  // Also handle when sortable reorders subjects - need to update data attributes
  document.addEventListener('sortupdate', function() {
    // Re-bind after sorting
    setTimeout(() => {
      initializeAutoFinishDate();
    }, 100);
  });
}

// Export for use in inline scripts
window.initializeCourseEdit = initializeCourseEdit;


