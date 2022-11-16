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
    if (!select) {
      return
    }

    var title = form.querySelector('.attachment-form__title')
    var body = form.querySelector('.attachment-form__body')

    select.addEventListener('change', function () {
      if (rightToLeftLocales.indexOf(this.value) > -1) {
        title.classList.add('right-to-left')
        body.classList.add('right-to-left')
      } else {
        title.classList.remove('right-to-left')
        body.classList.remove('right-to-left')
      }
    })
  }

  Modules.LocaleSwitcher = LocaleSwitcher
})(window.GOVUK.Modules)
