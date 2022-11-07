//= require accessible-autocomplete/dist/accessible-autocomplete.min.js
window.GOVUK = window.GOVUK || {}
window.GOVUK.Modules = window.GOVUK.Modules || {};

(function (Modules) {
  function Autocomplete ($module) {
    this.$module = $module
  }

  Autocomplete.prototype.init = function () {
    var $select = this.$module.querySelector('select')
    var $input = this.$module.querySelector('input')

    if ($select) {
      this.initAutoCompleteSelect($select)
    } else if ($input) {
      this.initAutoCompleteInput($input)
    }
  }

  Autocomplete.prototype.initAutoCompleteSelect = function ($select) {
    // disabled eslint because we can not control the name of the constructor (expected to be EnhanceSelectElement)
    new window.accessibleAutocomplete.enhanceSelectElement({ // eslint-disable-line no-new, new-cap
      selectElement: $select,
      minLength: 3,
      showNoOptionsFound: true,
      onConfirm: function (value) {
        var category = $select.getAttribute('data-track-category')
        var label = $select.getAttribute('data-track-label')
        var action = value
        if (category && label) {
          window.GOVUK.analytics.trackEvent(category, action, { label: label })
        }
      }
    })
  }

  Autocomplete.prototype.initAutoCompleteInput = function ($input) {
    var withoutNarrowingResults = this.$module.dataset.autocompleteWithoutNarrowingResults

    var list = document.getElementById($input.getAttribute('list'))
    var options = []

    if (list) {
      options = [].map.call(list.querySelectorAll('option'), function (option) {
        return option.value
      })
    }

    if (!options.length) {
      return
    }

    new window.accessibleAutocomplete({ // eslint-disable-line no-new, new-cap
      id: $input.id,
      name: $input.name,
      element: this.$module,
      showAllValues: withoutNarrowingResults,
      defaultValue: $input.value,
      autoselect: !withoutNarrowingResults,
      dropdownArrow: withoutNarrowingResults ? this.dropdownArrow : null,
      source: function (query, syncResults) {
        if (withoutNarrowingResults) {
          syncResults(options)
        } else {
          var resultMatcher = function (option) {
            return option.toLowerCase().indexOf(query.toLowerCase()) !== -1
          }

          syncResults(query ? options.filter(resultMatcher) : [])
        }
      }
    })

    $input.parentNode.removeChild($input)
  }

  Autocomplete.prototype.dropdownArrow = function (config) {
    return '<svg class="' + config.className + '" style="top: 8px;" viewBox="0 0 512 512" ><path d="M256,298.3L256,298.3L256,298.3l174.2-167.2c4.3-4.2,11.4-4.1,15.8,0.2l30.6,29.9c4.4,4.3,4.5,11.3,0.2,15.5L264.1,380.9  c-2.2,2.2-5.2,3.2-8.1,3c-3,0.1-5.9-0.9-8.1-3L35.2,176.7c-4.3-4.2-4.2-11.2,0.2-15.5L66,131.3c4.4-4.3,11.5-4.4,15.8-0.2L256,298.3  z"/></svg>'
  }

  Autocomplete.prototype.triggerEvent = function (element, eventName, detail) {
    var params = { bubbles: true, cancelable: true, detail: detail || null }
    var event

    if (typeof window.CustomEvent === 'function') {
      event = new window.CustomEvent(eventName, params)
    } else {
      event = document.createEvent('CustomEvent')
      event.initCustomEvent(eventName, params.bubbles, params.cancelable, params.detail)
    }

    element.dispatchEvent(event)
  }

  Modules.Autocomplete = Autocomplete
})(window.GOVUK.Modules)
