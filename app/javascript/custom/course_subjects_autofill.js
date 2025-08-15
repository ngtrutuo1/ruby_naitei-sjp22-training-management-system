window.initSubjectForm = function() {
  console.log("initSubjectForm called");

  const container = document.getElementById("subject-list-container");
  const addBtn = document.getElementById("add-subject-row");
  const categorySelect = document.getElementById("category_id_for_subjects");

  if (!container || !addBtn) return;

  const template = container.firstElementChild ? container.firstElementChild.cloneNode(true) : null;
  if (!template) return;

  container.innerHTML = '';
  let rowIndex = 0;

  const subjectSelects = () => Array.from(container.querySelectorAll("select"));

  function updateDisabledOptions() {
    const allSelects = subjectSelects();

    allSelects.forEach(sel => {
      const selectedInOthers = allSelects
        .filter(s => s !== sel)
        .map(s => String(s.value))
        .filter(v => v);

      Array.from(sel.options).forEach(opt => {
        if (!opt.value) return; // skip empty option
        opt.disabled = selectedInOthers.includes(opt.value);
      });
    });
  }

  function addRow(subjectId = "", updateOptions = true) {
    const row = template.cloneNode(true);

    // update name với index
    row.querySelectorAll("input, select").forEach(el => {
      if (el.name) {
        // chuyển sang array style cho Rails
        el.name = el.name.replace(/\[\d+\]/, `[${rowIndex}]`);
        if (el.tagName === "INPUT") el.value = "";
      }
    });

    // gán giá trị nếu có subjectId
    if (window.subjectData && subjectId) {
      const subject = window.subjectData.find(s => s.id === subjectId);

      const sel = row.querySelector("select");
      if (sel) sel.value = String(subjectId);

      const positionInput = row.querySelector("input[name*='[position]']");
      if (subject && positionInput && categorySelect) {
        const categoryId = parseInt(categorySelect.value, 10);
        const category = subject.categories.find(c => c.id === categoryId);
        if (category) positionInput.value = category.position;
      }
    }

    container.appendChild(row);

    // add change event cho select mới
    const sel = row.querySelector("select");
    if (sel) sel.addEventListener("change", updateDisabledOptions);

    if (updateOptions) updateDisabledOptions();
    rowIndex++;
  }

  // init: tạo 1 row trống
  addRow();

  // add button
  addBtn.onclick = () => addRow();

  // remove row
  container.onclick = e => {
    if (e.target.classList.contains("remove-subject")) {
      if (container.children.length > 1) {
        e.target.closest(".subject-row").remove();
        updateDisabledOptions();
      }
    }
  };

  // category change
  if (categorySelect) {
    categorySelect.onchange = function() {
      const catId = parseInt(this.value, 10);
      container.innerHTML = '';
      rowIndex = 0;

      if (Number.isNaN(catId) || !window.subjectData) {
        addRow();
        return;
      }

      const subjectsInCat = window.subjectData.filter(s =>
        (s.categories || []).some(c => c.id === catId)
      );

      const added = new Set();
      subjectsInCat.forEach(s => {
        if (!added.has(s.id)) {
          addRow(s.id, false); // không update options từng row
          added.add(s.id);
        }
      });

      updateDisabledOptions(); // update once after all rows added
    };
  }

  updateDisabledOptions();
};

// tự động chạy khi DOM load xong
document.addEventListener("DOMContentLoaded", initSubjectForm);
