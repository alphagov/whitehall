//= require choices.js/public/assets/scripts/choices.min.js
//= require miller-columns-element
'use strict'
window.GOVUK = window.GOVUK || {}
window.GOVUK.Modules = window.GOVUK.Modules || {}
;(function (Modules) {
  function MillerColumns(module) {
    this.module = module
    this.searchable = module.getAttribute('data-searchable') === 'true'
  }

  MillerColumns.prototype.init = function () {
    if (this.searchable) this.initSearch()
  }

  MillerColumns.prototype.initSearch = function () {
    const input = this.module.querySelector(
      '#app-c-miller-columns__search-input'
    )
    const placeholderOption = input.querySelector(
      'option[value=""]:first-child'
    )

    if (placeholderOption && placeholderOption.textContent === '') {
      placeholderOption.textContent = 'Search for topics'
    }
    const choices = new window.Choices(input, {
      allowHTML: true,
      shouldSort: false, // show options and groups in the order they were given
      itemSelectText: '',
      searchResultLimit: 100,
      // https://fusejs.io/api/options.html
      fuseOptions: {
        ignoreLocation: true, // matches any part of the string
        threshold: 0 // only matches when characters are sequential
      }
    })
    choices.passedElement.element.addEventListener(
      'choice',
      function (event) {
        // check the corresponding box in miller-columns
        document
          .querySelector("input[value='" + event.detail.value + "']")
          .click()

        // Remove the 'chosen' item so that it continues to be available
        // in search, and so that it isn't made visible below the search
        // area like we'd normally want it to be.
        choices.removeActiveItems()
      },
      false
    )
  }

  Modules.MillerColumns = MillerColumns
})(window.GOVUK.Modules)
