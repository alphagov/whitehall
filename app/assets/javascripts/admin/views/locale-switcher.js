window.GOVUK = window.GOVUK || {}
window.GOVUK.Modules = window.GOVUK.Modules || {};

(function (Modules) {
  function LocaleSwitcher (module) {
    this.module = module
    this.rightToLeftLocales = module.dataset.rtlLocales.split(' ')
  }

  LocaleSwitcher.prototype.init = function () {
    this.setupLocaleSwitching()
  }

  LocaleSwitcher.prototype.setupLocaleSwitching = function () {
    var form = this.module
    var rightToLeftLocales = this.rightToLeftLocales
    var select = form.querySelector('#attachment_locale')
    var title = form.querySelector('.app-view-attachments__form-title input')
    var body = form.querySelector('.app-view-attachments__form-body .app-c-govspeak-editor__textarea textarea')
    var preview = form.querySelector('.app-view-attachments__form-body .app-c-govspeak-editor__preview')

    if (!select) {
      return
    }

    select.addEventListener('change', function () {
      if (rightToLeftLocales.indexOf(this.value) > -1) {
        title.setAttribute('dir', 'rtl')
        body.setAttribute('dir', 'rtl')
        preview.setAttribute('dir', 'rtl')
      } else {
        title.removeAttribute('dir')
        body.removeAttribute('dir')
        preview.removeAttribute('dir')
      }
    })
  }

  Modules.LocaleSwitcher = LocaleSwitcher
})(window.GOVUK.Modules)
