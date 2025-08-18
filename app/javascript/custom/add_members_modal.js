document.addEventListener('turbo:load', function() {
  const modalEl = document.getElementById('addMembersModal');
  if (!modalEl) return;

  const searchInput = document.getElementById('member-search-input');
  const resultsEl = document.getElementById('member-search-results');
  const tagsEl = document.getElementById('selected-tags');
  const confirmBtn = document.getElementById('confirm-add-members');
  const openTraineesBtn = document.getElementById('open-add-trainees-modal');
  const openTrainersBtn = document.getElementById('open-add-trainers-modal');

  let memberType = null; // 'trainee' | 'trainer'
  let selectedMap = new Map();
  let searchDebounceTimer = null;

  function showModal() {
    // Bootstrap 5 module API
    if (window.bootstrap && typeof window.bootstrap.Modal !== 'undefined') {
      const modal = window.bootstrap.Modal.getOrCreateInstance(modalEl);
      modal.show();
      return;
    }
    // Bootstrap 3 jQuery plugin
    if (window.$ && typeof window.$(modalEl).modal === 'function') {
      window.$(modalEl).modal('show');
      return;
    }
    // Fallback
    modalEl.classList.add('show');
    modalEl.style.display = 'block';
  }

  function hideModal() {
    if (window.bootstrap && typeof window.bootstrap.Modal !== 'undefined') {
      const modal = window.bootstrap.Modal.getOrCreateInstance(modalEl);
      modal.hide();
      return;
    }
    if (window.$ && typeof window.$(modalEl).modal === 'function') {
      window.$(modalEl).modal('hide');
      return;
    }
    modalEl.classList.remove('show');
    modalEl.style.display = 'none';
  }

  function openModal(type) {
    memberType = type;
    selectedMap.clear();
    renderSelectedTags();
    renderResults([]);
    if (searchInput) searchInput.value = '';
    const title = modalEl.querySelector('.modal-title');
    if (title) {
      title.textContent = type === 'trainer'
        ? title.getAttribute('data-trainer-title')
        : title.getAttribute('data-trainee-title');
    }
    showModal();
    updateConfirmState();
  }

  function renderSelectedTags() {
    if (!tagsEl) return;
    tagsEl.innerHTML = '';
    selectedMap.forEach((user, id) => {
      const tag = document.createElement('span');
      tag.className = 'badge bg-secondary me-2 mb-2';
      tag.textContent = user.name + ' ';
      const btn = document.createElement('button');
      btn.type = 'button';
      btn.className = 'btn-close btn-close-white btn-sm ms-1';
      btn.setAttribute('aria-label', 'Remove');
      btn.addEventListener('click', () => { selectedMap.delete(id); renderSelectedTags(); updateConfirmState(); });
      tag.appendChild(btn);
      tagsEl.appendChild(tag);
    });
  }

  function renderResults(users) {
    if (!resultsEl) return;
    resultsEl.innerHTML = '';
    const list = document.createElement('div');
    list.className = 'list-group';
    users.forEach(user => {
      const item = document.createElement('button');
      item.type = 'button';
      item.className = 'list-group-item list-group-item-action';
      item.textContent = `${user.name} ${user.email ? '(' + user.email + ')' : ''}`;
      item.addEventListener('click', () => {
        selectedMap.set(user.id, user);
        renderSelectedTags();
        updateConfirmState();
      });
      list.appendChild(item);
    });
    resultsEl.appendChild(list);
  }

  function updateConfirmState() {
    if (confirmBtn) confirmBtn.disabled = selectedMap.size === 0;
  }

  function performSearch(q) {
    const pathParts = window.location.pathname.split('/').filter(Boolean);
    let idx = 0;
    let locale = null;
    if (pathParts[0] === 'vi' || pathParts[0] === 'en') {
      locale = '/' + pathParts[0];
      idx = 1;
    } else {
      locale = '';
    }
    const courseId = pathParts[idx + 2]; // supervisor/courses/:id/members
    fetch(`${locale}/supervisor/courses/${courseId}/search_members?q=${encodeURIComponent(q)}&type=${encodeURIComponent(memberType)}`, {
      headers: { 'Accept': 'application/json' }
    }).then(r => r.json())
      .then(renderResults)
      .catch(() => renderResults([]));
  }

  if (searchInput) {
    searchInput.addEventListener('input', function() {
      const q = this.value;
      if (searchDebounceTimer) clearTimeout(searchDebounceTimer);
      searchDebounceTimer = setTimeout(() => performSearch(q), 200);
    });
  }

  if (confirmBtn) {
    confirmBtn.addEventListener('click', function() {
      const ids = Array.from(selectedMap.keys());
      if (ids.length === 0) return;

      const pathParts = window.location.pathname.split('/').filter(Boolean);
      let idx = 0;
      let locale = null;
      if (pathParts[0] === 'vi' || pathParts[0] === 'en') {
        locale = '/' + pathParts[0];
        idx = 1;
      } else {
        locale = '';
      }
      const courseId = pathParts[idx + 2];
      const url = memberType === 'trainer'
        ? `${locale}/supervisor/courses/${courseId}/supervisors`
        : `${locale}/supervisor/courses/${courseId}/user_courses`;

      fetch(url, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
        },
        body: JSON.stringify({ user_ids: ids })
      }).then(response => response.json())
        .then(data => {
          if (data.error) {
            // Show error message
            alert(data.error);
          } else {
            // Success - hide modal and reload
            hideModal();
            window.location.reload();
          }
        })
        .catch(error => {
          console.error('Error:', error);
          alert('An error occurred while adding members. Please try again.');
        });
    });
  }

  if (openTraineesBtn) openTraineesBtn.addEventListener('click', () => openModal('trainee'));
  if (openTrainersBtn) openTrainersBtn.addEventListener('click', () => openModal('trainer'));

  // Ensure close button works even on Bootstrap 3 fallback
  const closeBtn = modalEl.querySelector('.btn-close');
  if (closeBtn) {
    closeBtn.addEventListener('click', hideModal);
  }
});


