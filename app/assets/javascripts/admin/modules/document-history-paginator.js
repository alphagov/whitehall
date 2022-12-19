window.GOVUK = window.GOVUK || {}
window.GOVUK.Modules = window.GOVUK.Modules || {};

(function (Modules) {
  function DocumentHistoryPaginator (module) {
    this.module = module
  }

  DocumentHistoryPaginator.prototype.init = function () {
    var fetch = window.fetch
    if (!fetch) { return }

    this.setupEventListeners()
  }

  DocumentHistoryPaginator.prototype.setupEventListeners = function () {
    var module = this.module
    var newerLink = module.querySelector('.app-view-document-history-tab__newer-pagination-link')
    var olderLink = module.querySelector('.app-view-document-history-tab__older-pagination-link')

    if (newerLink) {
      this.addLinkEventListener(newerLink)
    }

    if (olderLink) {
      this.addLinkEventListener(olderLink)
    }
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
