window.GOVUK = window.GOVUK || {}
window.GOVUK.Modules = window.GOVUK.Modules || {};

(function (Modules) {
  function DocumentHistoryPaginator (module) {
    this.module = module
  }

  DocumentHistoryPaginator.prototype.init = function () {
    if (!window.fetch) { return }

    this.setupEventListeners()
  }

  DocumentHistoryPaginator.prototype.setupEventListeners = function () {
    var _this = this

    var linkSelectors = [
      '.app-view-document-history-tab__newer-pagination-link',
      '.app-view-document-history-tab__older-pagination-link'
    ]

    this.module.querySelectorAll(linkSelectors.join()).forEach(function (link) {
      _this.addLinkEventListener(link)
    })
  }

  DocumentHistoryPaginator.prototype.addLinkEventListener = function (link) {
    var module = this.module

    link.addEventListener('click', function (e) {
      e.preventDefault()

      window.fetch(new URL(document.location.origin + link.dataset.remotePagination))
        .then(function (response) { return response.text() })
        .catch(function () { window.location.replace(new URL(link.href)) })
        .then(function (html) {
          module.innerHTML = html

          var documentHistoryModule = new GOVUK.Modules.DocumentHistoryPaginator(module)
          documentHistoryModule.init()
        })
    })
  }

  Modules.DocumentHistoryPaginator = DocumentHistoryPaginator
})(window.GOVUK.Modules)
