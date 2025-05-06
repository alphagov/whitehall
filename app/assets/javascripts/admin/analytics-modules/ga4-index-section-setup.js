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
        const indexedElements = moduleElement.querySelectorAll(
          'select, input:not([data-module~="select-with-search"] input):not([type="radio"]):not([type="hidden"]), fieldset'
        )

        indexedElements.forEach((element, index) => {
          if (element.tagName === 'FIELDSET' || !element.closest('fieldset')) {
            const indexData = {
              // cast to string otherwise treated as false by
              // `analyticsGa4.core.applySchemaAndSendData`
              index_section: String(index),
              index_section_count: String(indexedElements.length)
            }
            element.dataset.ga4Index = JSON.stringify(indexData)
            element.dataset.ga4FilterParent = true
            element.dataset.ga4IndexSection = String(index)
          }
        })
      })
    }
  }
})(window.GOVUK.analyticsGa4.analyticsModules)
