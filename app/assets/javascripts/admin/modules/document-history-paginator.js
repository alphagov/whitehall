window.GOVUK = window.GOVUK || {}
window.GOVUK.Modules = window.GOVUK.Modules || {};

(function (Modules) {
  function DocumentHistoryPaginator (module) {
    this.module = module
  }

  DocumentHistoryPaginator.prototype.init = function () {
    this.setupLinkEventListeners()
    this.setupFormChangeListener()
  }

  DocumentHistoryPaginator.prototype.setupLinkEventListeners = function () {
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
        .catch(function () { window.location.href = link.href })
        .then(function (html) {
          module.innerHTML = html

          var documentHistoryModule = new GOVUK.Modules.DocumentHistoryPaginator(module)
          documentHistoryModule.init()
        })
    })
  }

  DocumentHistoryPaginator.prototype.setupFormChangeListener = function () {
    var module = this.module

    var form = module.querySelector('form.js-filter-form')
    var select = form.querySelector('select')

    // Hide the submit <button>
    form.querySelector('button').hidden = true // this doesn't hide it for some reason 😢
    form.querySelector('button').style.display = 'none'

    var queryParameters = function () {
      var formData = new FormData(form)
      return new URLSearchParams(formData).toString()
    }

    select.addEventListener('change', function () {
      window.fetch(form.dataset.remotePagination + '?' + queryParameters())
        .then(function (response) { return response.text() })
        .catch(function () { window.location.search = queryParameters() })
        .then(function (html) {
          module.innerHTML = html

          var documentHistoryModule = new GOVUK.Modules.DocumentHistoryPaginator(module)
          documentHistoryModule.init()
        })
    })
  }

  Modules.DocumentHistoryPaginator = DocumentHistoryPaginator
})(window.GOVUK.Modules)
