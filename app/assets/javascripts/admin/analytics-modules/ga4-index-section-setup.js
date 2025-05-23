'use strict'
window.GOVUK = window.GOVUK || {}
window.GOVUK.analyticsGa4 = window.GOVUK.analyticsGa4 || {}
window.GOVUK.analyticsGa4.analyticsModules =
  window.GOVUK.analyticsGa4.analyticsModules || {}
;(function (Modules) {
  Modules.Ga4IndexSectionSetup = {
    init: function () {
      const moduleElements = document.querySelectorAll(
        "[data-module~='ga4-index-section-setup']"
      )

      moduleElements.forEach(function (moduleElement) {
        // An indexed section is either a single element
        // or set of elements that changes one value of
        // a form. Therefore we don't want to index:
        //
        // - individual radio buttons because they change
        //   one value of a single value
        // - individual checkboxes if they're part of a
        //   group of checkboxes that change a single value
        //
        // Additionally we don't want to index:
        // - the search within a SelectWithSearch component as it doesn't
        //   change the value of the form
        // - a hidden input because the user can't interact with it
        const indexedElements = moduleElement.querySelectorAll(
          'select, input:not([data-module~="select-with-search"] input):not([type="radio"]):not([type="hidden"]), fieldset'
        )

        indexedElements.forEach((element, index) => {
          if (element.tagName === 'FIELDSET' || !element.closest('fieldset')) {
            const indexData = {
              index_section: index,
              index_section_count: indexedElements.length
            }
            element.dataset.ga4Index = JSON.stringify(indexData)
            element.dataset.ga4IndexSection = index

            if (element.closest('[data-module~="ga4-finder-tracker"]')) {
              // required attribute for `ga4-finder-tracker`
              // assumes that index values will come from
              // an element with `ga4-filter-parent` set
              element.dataset.ga4FilterParent = true
            }
          }
        })
      })
    }
  }
})(window.GOVUK.analyticsGa4.analyticsModules)
