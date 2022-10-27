window.GOVUK = window.GOVUK || {}
window.GOVUK.Modules = window.GOVUK.Modules || {};

(function (Modules) {
  function GovspeakEditor (module) {
    this.module = module
  }

  GovspeakEditor.prototype.init = function () {
    this.initPreview()
  }

  GovspeakEditor.prototype.getCsrfToken = function () {
    return document.querySelector('meta[name="csrf-token"]').content
  }

  GovspeakEditor.prototype.getRenderedGovspeak = function (content, callback) {
    var body = new FormData()
    body.append('body', content)

    var request = new XMLHttpRequest()
    request.open('POST', '/government/admin/preview', false)
    request.setRequestHeader('X-CSRF-Token', this.getCsrfToken())
    request.onreadystatechange = callback
    request.send(body)
  }

  GovspeakEditor.prototype.initPreview = function () {
    var previewToggle = this.module.querySelector('.js-app-c-govspeak-editor__preview-button')
    var trackToggle = previewToggle.getAttribute('data-preview-toggle-tracking') === 'true'
    var preview = this.module.querySelector('.app-c-govspeak-editor__preview')
    var textareaWrapper = this.module.querySelector('.app-c-govspeak-editor__textarea')
    var textarea = this.module.querySelector(previewToggle.getAttribute('data-content-target'))

    previewToggle.addEventListener('click', function (e) {
      e.preventDefault()

      var previewMode = previewToggle.innerText === 'Preview'

      previewToggle.innerText = previewMode ? 'Back to edit' : 'Preview'
      textareaWrapper.classList.toggle('app-c-govspeak-editor__textarea--hidden')
      preview.classList.toggle('app-c-govspeak-editor__preview--show')

      if (previewMode) {
        this.getRenderedGovspeak(textarea.value, function (event) {
          var response = event.currentTarget

          if (response.readyState === 4 && response.status === 200) {
            preview.innerHTML = response.responseText
          }
        })
      }

      if (trackToggle) {
        GOVUK.analytics.trackEvent(
          previewToggle.getAttribute('data-preview-toggle-track-category'),
          previewToggle.getAttribute('data-preview-toggle-track-action'),
          { label: previewMode ? 'preview' : 'edit' }
        )
      }
    }.bind(this))
  }

  Modules.GovspeakEditor = GovspeakEditor
})(window.GOVUK.Modules)
