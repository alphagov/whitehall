window.GOVUK = window.GOVUK || {}
window.GOVUK.Modules = window.GOVUK.Modules || {};

(function (Modules) {
  function DocumentHistory (module) {
    this.module = module
  }

  DocumentHistory.prototype.init = function () {
    this.setupEventListeners()
  }

  DocumentHistory.prototype.setupEventListeners = function () {
    var documentHistoryTab = document.querySelector('#history_tab')

    document.addEventListener('click', function (e) {
      var newerLink = document.querySelector('.app-component-document-history-tab__newer-pagination-link')
      var olderLink = document.querySelector('.app-component-document-history-tab__older-pagination-link')

      if (newerLink && newerLink.contains(event.target)) {
        e.preventDefault()
        Rails.ajax({
          url: newerLink.dataset['remotePagination'],
          type: "get",
          success: function(data) {
            documentHistoryTab.innerHTML = data;
          }
        })
      } else if (olderLink && olderLink.contains(event.target)) {
        e.preventDefault()
        Rails.ajax({
          url: olderLink.dataset['remotePagination'],
          type: "get",
          success: function(data) {
            documentHistoryTab.innerHTML = data;
          }
        })
      }
    })
  }

  Modules.DocumentHistory = DocumentHistory
})(window.GOVUK.Modules)
