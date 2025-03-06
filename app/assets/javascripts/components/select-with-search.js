//= require choices.js/public/assets/scripts/choices.min.js
'use strict'
window.GOVUK = window.GOVUK || {}
window.GOVUK.Modules = window.GOVUK.Modules || {}
;(function (Modules) {
  function SelectWithSearch(module) {
    this.module = module
    this.select = this.module.querySelector('select')
  }

  SelectWithSearch.prototype.init = function () {
    if (!this.select) return
    const placeholderOption = this.select.querySelector(
      'option[value=""]:first-child'
    )

    if (placeholderOption && placeholderOption.textContent === '') {
      placeholderOption.textContent = this.select.multiple
        ? 'Select all that apply'
        : 'Select one'
    }

    this.choices = new window.Choices(this.select, {
      allowHTML: true,
      searchPlaceholderValue: 'Search in list',
      shouldSort: false, // show options and groups in the order they were given
      itemSelectText: '',
      searchResultLimit: 100,
      removeItemButton: this.select.multiple,
      labelId: this.select.id + '_label',
      callbackOnInit: function () {
        // For the multiple select, move the input field to
        // the top of the feedback area, so that the selected
        // 'lozenges' appear afterwards in a more natural flow
        if (this.dropdown.type === 'select-multiple') {
          const inner = this.containerInner.element
          const input = this.input.element
          inner.prepend(input)
        }
      },
      // https://fusejs.io/api/options.html
      fuseOptions: {
        ignoreLocation: true, // matches any part of the string
        threshold: 0 // only matches when characters are sequential
      }
    })

    this.module.choices = this.choices
  }

  Modules.SelectWithSearch = SelectWithSearch
})(window.GOVUK.Modules)
