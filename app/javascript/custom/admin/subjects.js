// // Admin Subjects Show Page JavaScript

// // Confirm delete comment function
// window.confirmDeleteComment = function (
//   commentId,
//   deleteUrl,
//   confirmMessage,
//   csrfToken,
//   userId
// ) {
//   if (confirm(confirmMessage)) {
//     // Create form and submit
//     const form = document.createElement("form");
//     form.method = "POST";
//     form.action = deleteUrl;

//     const methodInput = document.createElement("input");
//     methodInput.type = "hidden";
//     methodInput.name = "_method";
//     methodInput.value = "DELETE";

//     const tokenInput = document.createElement("input");
//     tokenInput.type = "hidden";
//     tokenInput.name = "authenticity_token";
//     tokenInput.value = csrfToken;

//     const commentIdInput = document.createElement("input");
//     commentIdInput.type = "hidden";
//     commentIdInput.name = "comment_id";
//     commentIdInput.value = commentId;

//     const userIdInput = document.createElement("input");
//     userIdInput.type = "hidden";
//     userIdInput.name = "user_id";
//     userIdInput.value = userId;

//     form.appendChild(methodInput);
//     form.appendChild(tokenInput);
//     form.appendChild(commentIdInput);
//     form.appendChild(userIdInput);

//     document.body.appendChild(form);
//     form.submit();
//   }
// };

// // Initialize page when DOM is loaded
// document.addEventListener("DOMContentLoaded", function () {
//   // Initialize Bootstrap tooltips if they exist
//   if (typeof bootstrap !== "undefined" && bootstrap.Tooltip) {
//     var tooltipTriggerList = [].slice.call(
//       document.querySelectorAll('[data-bs-toggle="tooltip"]')
//     );
//     var tooltipList = tooltipTriggerList.map(function (tooltipTriggerEl) {
//       return new bootstrap.Tooltip(tooltipTriggerEl);
//     });
//   }

//   // Initialize Bootstrap modals if they exist
//   if (typeof bootstrap !== "undefined" && bootstrap.Modal) {
//     // Auto-focus on modal inputs when opened
//     var modals = document.querySelectorAll(".modal");
//     modals.forEach(function (modal) {
//       modal.addEventListener("shown.bs.modal", function () {
//         var input = modal.querySelector('input[type="text"], textarea');
//         if (input) {
//           input.focus();
//         }
//       });
//     });
//   }

//   // Smooth scroll for any anchor links
//   var anchorLinks = document.querySelectorAll('a[href^="#"]');
//   anchorLinks.forEach(function (link) {
//     link.addEventListener("click", function (e) {
//       e.preventDefault();
//       var target = document.querySelector(this.getAttribute("href"));
//       if (target) {
//         target.scrollIntoView({
//           behavior: "smooth",
//         });
//       }
//     });
//   });
// });
