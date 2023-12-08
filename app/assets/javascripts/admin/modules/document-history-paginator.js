window.GOVUK = window.GOVUK || {}
window.GOVUK.Modules = window.GOVUK.Modules || {}
;(function (Modules) {
  function DocumentHistoryPaginator(module) {
    this.module = module
  }

  DocumentHistoryPaginator.prototype.init = function () {
    this.setupLinkEventListeners()
    this.setupFormChangeListener()
  }

  DocumentHistoryPaginator.prototype.setupLinkEventListeners = function () {
    const _this = this

    const linkSelectors = [
      '.app-view-document-history-tab__newer-pagination-link',
      '.app-view-document-history-tab__older-pagination-link'
    ]

    this.module.querySelectorAll(linkSelectors.join()).forEach(function (link) {
      _this.addLinkEventListener(link)
    })
  }

  DocumentHistoryPaginator.prototype.addLinkEventListener = function (link) {
    const module = this.module

    link.addEventListener('click', function (e) {
      e.preventDefault()

      window
        .fetch(
          new URL(document.location.origin + link.dataset.remotePagination)
        )
        .then(function (response) {
          return response.text()
        })
        .catch(function () {
          window.location.href = link.href
        })
        .then(function (html) {
          module.innerHTML = html

          const documentHistoryModule =
            new GOVUK.Modules.DocumentHistoryPaginator(module)
          documentHistoryModule.init()
        })
    })
  }

  DocumentHistoryPaginator.prototype.setupFormChangeListener = function () {
    const module = this.module

    const form = module.querySelector('form.js-filter-form')
    const select = form.querySelector('select')

    // Hide the submit <button>
    form.querySelector('button').hidden = true // this doesn't hide it for some reason 😢
    form.querySelector('button').style.display = 'none'

    const queryParameters = function () {
      const formData = new FormData(form)
      return new URLSearchParams(formData).toString()
    }

    select.addEventListener('change', function () {
      window
        .fetch(form.dataset.remotePagination + '?' + queryParameters())
        .then(function (response) {
          return response.text()
        })
        .catch(function () {
          window.location.search = queryParameters()
        })
        .then(function (html) {
          module.innerHTML = html
          const insertedForm = module.querySelector('form.js-filter-form')
          insertedForm.querySelector('select').focus()

          const documentHistoryModule =
            new GOVUK.Modules.DocumentHistoryPaginator(module)
          documentHistoryModule.init()
        })
    })
  }

  Modules.DocumentHistoryPaginator = DocumentHistoryPaginator
})(window.GOVUK.Modules)
