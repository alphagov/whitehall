//= require accessible-autocomplete/dist/accessible-autocomplete.min.js
'use strict'
window.GOVUK = window.GOVUK || {}
window.GOVUK.Modules = window.GOVUK.Modules || {}
;(function (Modules) {
  function Autocomplete($module) {
    this.$module = $module
  }

  Autocomplete.prototype.init = function () {
    const $select = this.$module.querySelector('select')

    const defaultOptions = {
      selectElement: $select,
      minLength: 3,
      showAllValues: $select.multiple,
      showNoOptionsFound: true,
      onConfirm: function (query) {
        let matchingOption
        if (query) {
          matchingOption = [].filter.call($select.options, function (option) {
            return (option.textContent || option.innerText) === query
          })[0]
        } else {
          matchingOption = [].filter.call($select.options, function (option) {
            return option.value === ''
          })[0]
        }
        if (matchingOption) {
          matchingOption.selected = true
        }
      }
    }

    const assignedOptions = JSON.parse(
      this.$module.dataset.autocompleteConfigurationOptions
    )

    const configurationOptions = Object.assign(defaultOptions, assignedOptions)

    // disabled eslint because we can not control the name of the constructor (expected to be EnhanceSelectElement)
    new window.accessibleAutocomplete.enhanceSelectElement(configurationOptions) // eslint-disable-line no-new, new-cap
  }

  Modules.Autocomplete = Autocomplete
})(window.GOVUK.Modules)
