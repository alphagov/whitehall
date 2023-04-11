/* This module is used where only certain elements within a form are required to update the value of their `dir` attribute in response to a change in a `select` element.
** By default it will affect this change on `input` and `textarea` elements but can be extended to other elements as below.
** Usage:
** - Add to the form with `data-module="LocaleSwitcher"`
** - Add collection of RTL languages on the form element with `data-rtl-locales=<array of LTR languages>`
** - Wrap the language selector with the class `js-locale-switcher-selector`
** - Wrap fields to display RTL languages with `js-locale-switcher-field`
** - Add to any custom elements the class `js-locale-switcher-custom`
*/

window.GOVUK = window.GOVUK || {}
window.GOVUK.Modules = window.GOVUK.Modules || {};

(function (Modules) {
  function LocaleSwitcher (module) {
    this.module = module
    this.rightToLeftLocales = JSON.parse(module.dataset.rtlLocales)
  }

  LocaleSwitcher.prototype.init = function () {
    this.setupLocaleSwitching()
  }

  LocaleSwitcher.prototype.setupLocaleSwitching = function () {
    var form = this.module
    var rightToLeftLocales = this.rightToLeftLocales
    var select = form.querySelector('.js-locale-switcher-selector')
    var localeFields = form.querySelectorAll('.js-locale-switcher-field input, .js-locale-switcher-field textarea, .js-locale-switcher-custom')

    if (!select) {
      return
    }

    select.addEventListener('change', function (event) {
      var value = event.target.value

      if (rightToLeftLocales.indexOf(value) > -1) {
        localeFields.forEach(function (field) {
          field.setAttribute('dir', 'rtl')
        })
      } else {
        localeFields.forEach(function (field) {
          field.removeAttribute('dir')
        })
      }
    })
  }

  Modules.LocaleSwitcher = LocaleSwitcher
})(window.GOVUK.Modules)
