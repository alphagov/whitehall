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
    var title = form.querySelector('.attachment-form__title')
    var body = form.querySelector('.attachment-form__body')

    form.querySelector('#attachment_locale').addEventListener('change', function () {
      if (rightToLeftLocales.indexOf(this.value) > -1) {
        title.classList.add('attachment-form__title--right-to-left')
        body.classList.add('attachment-form__body--right-to-left')
      } else {
        title.classList.remove('attachment-form__title--right-to-left')
        body.classList.remove('attachment-form__body--right-to-left')
      }
    })
  }

  Modules.LocaleSwitcher = LocaleSwitcher
})(window.GOVUK.Modules)
