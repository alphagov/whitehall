//= require choices.js/public/assets/scripts/choices.min.js
window.GOVUK = window.GOVUK || {}
window.GOVUK.Modules = window.GOVUK.Modules || {};

(function (Modules) {
  function SelectWithSearch (module) {
    this.module = module
    this.select = this.module.querySelector('select')
  }

  SelectWithSearch.prototype.init = function () {
    if (!this.select) return

    var placeholderOption = this.select.querySelector('option[value=""]:first-child')
    if (placeholderOption) {
      placeholderOption.textContent = 'Select one'
    }

    this.choices = new window.Choices(this.select, {
      allowHTML: false,
      searchPlaceholderValue: 'Search in list',
      shouldSort: false // show options and groups in the order they were given
    })
  }

  Modules.SelectWithSearch = SelectWithSearch
})(window.GOVUK.Modules)
