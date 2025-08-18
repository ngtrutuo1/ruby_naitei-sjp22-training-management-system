// JS for Add Supervisor Page (new_supervisor)
document.addEventListener('turbo:load', function () {
  const searchInput = document.getElementById('traineeSearchInput');
  const searchResultsContainer = document.getElementById(
    'searchResultsContainer'
  );
  const searchResults = document.getElementById('searchResults');
  const selectedTraineeSection = document.getElementById(
    'selectedTraineeSection'
  );
  const selectedTraineeInfo = document.getElementById('selectedTraineeInfo');
  const addSupervisorBtn = document.getElementById('addSupervisorBtn');
  const addSupervisorForm = document.getElementById('addSupervisorForm');

  if (!searchInput) return;

  let selectedTrainees = [];

  // Gắn sự kiện click cho các trainee render sẵn từ server
  document.querySelectorAll('.search-result-item').forEach(item => {
    item.addEventListener('click', function () {
      const trainee = JSON.parse(this.getAttribute('data-trainee'));
      addTrainee(trainee);
    });
  });

  function addTrainee(trainee) {
    if (!selectedTrainees.some(t => t.id === trainee.id)) {
      selectedTrainees.push(trainee);
      updateSelectedTrainees();
    }
  }

  function removeTrainee(id) {
    selectedTrainees = selectedTrainees.filter(t => t.id !== id);
    updateSelectedTrainees();
  }

  function updateSelectedTrainees() {
    if (selectedTrainees.length === 0) {
      selectedTraineeSection.classList.add('d-none');
      selectedTraineeInfo.innerHTML = '';
      addSupervisorBtn.disabled = true;
      return;
    }
    selectedTraineeSection.classList.remove('d-none');
    selectedTraineeInfo.innerHTML = selectedTrainees
      .map(
        trainee => `
            <div class='selected-trainee-info d-flex align-items-center mb-2'>
                <div class='trainee-avatar me-3'>${trainee.name
                  .charAt(0)
                  .toUpperCase()}</div>
                <div class='trainee-details'>
                    <div class='fw-bold'>${escapeHtml(trainee.name)}</div>
                    <div class='text-muted small'>${escapeHtml(
                      trainee.email
                    )}</div>
                </div>
                <button type='button' class='remove-selection ms-auto btn btn-sm btn-outline-danger' data-id='${
                  trainee.id
                }' title='Bỏ chọn'><i class='fas fa-times'></i></button>
            </div>
        `
      )
      .join('');
    addSupervisorBtn.disabled = false;
    // Gắn lại sự kiện xóa trainee đã chọn
    selectedTraineeInfo.querySelectorAll('.remove-selection').forEach(btn => {
      btn.onclick = function () {
        removeTrainee(Number(this.getAttribute('data-id')));
      };
    });
  }

  // Gửi supervisor_ids qua form khi nhấn Add Supervisor
  addSupervisorBtn.addEventListener('click', function (e) {
    if (selectedTrainees.length > 0 && addSupervisorForm) {
      // Xóa tất cả input supervisor_ids[] cũ nếu có
      const oldInputs = addSupervisorForm.querySelectorAll(
        'input[name="supervisor_ids[]"]'
      );
      oldInputs.forEach(input => input.remove());

      // Tạo một input riêng cho mỗi trainee
      selectedTrainees.forEach(trainee => {
        const input = document.createElement('input');
        input.type = 'hidden';
        input.name = 'supervisor_ids[]';
        input.value = trainee.id;
        addSupervisorForm.appendChild(input);
      });

      // Đổi action sang đúng route add_role_supervisor
      addSupervisorForm.action = '/admin/users/add_role_supervisor';
      addSupervisorForm.method = 'post';
      // Thêm input _method=patch để Rails nhận đúng PATCH
      let methodInput = addSupervisorForm.querySelector(
        'input[name="_method"]'
      );
      if (!methodInput) {
        methodInput = document.createElement('input');
        methodInput.type = 'hidden';
        methodInput.name = '_method';
        methodInput.value = 'patch';
        addSupervisorForm.appendChild(methodInput);
      } else {
        methodInput.value = 'patch';
      }
      // Thêm CSRF token nếu cần
      const csrf = document.querySelector('meta[name="csrf-token"]');
      if (csrf) {
        let csrfInput = addSupervisorForm.querySelector(
          'input[name="authenticity_token"]'
        );
        if (!csrfInput) {
          csrfInput = document.createElement('input');
          csrfInput.type = 'hidden';
          csrfInput.name = 'authenticity_token';
          csrfInput.value = csrf.content;
          addSupervisorForm.appendChild(csrfInput);
        }
      }
      addSupervisorForm.submit();
    }
  });

  function escapeHtml(text) {
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
  }
});
