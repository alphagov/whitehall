//= require choices.js/public/assets/scripts/choices.min.js
window.GOVUK = window.GOVUK || {}
window.GOVUK.Modules = window.GOVUK.Modules || {};

(function (Modules) {
  function SelectWithSearch (module) {
    this.module = module
    this.select = this.module.querySelector('select')
    this.enableTracking = !!module.dataset.trackCategory
  }

  SelectWithSearch.prototype.init = function () {
    if (!this.select) return
    var placeholderOption = this.select.querySelector('option[value=""]:first-child')

    if (placeholderOption && placeholderOption.textContent === '') {
      placeholderOption.textContent = 'Select one'
    }

    this.choices = new window.Choices(this.select, {
      allowHTML: true,
      searchPlaceholderValue: 'Search in list',
      shouldSort: false, // show options and groups in the order they were given
      itemSelectText: '',
      searchResultLimit: 100,
      labelId: this.select.id + '_label',
      // https://fusejs.io/api/options.html
      fuseOptions: {
        ignoreLocation: true, // matches any part of the string
        threshold: 0 // only matches when characters are sequential
      }
    })

    this.module.choices = this.choices

    if (this.enableTracking) {
      this.module.addEventListener('change', this.trackChange.bind(this))
    }
  }

  SelectWithSearch.prototype.trackChange = function () {
    var { trackCategory, trackLabel } = this.module.dataset

    var action = this.choices.getValue().label

    var options = {}
    if (trackLabel) options.label = trackLabel

    GOVUK.analytics.trackEvent(trackCategory, action, options)
  }

  Modules.SelectWithSearch = SelectWithSearch
})(window.GOVUK.Modules)
