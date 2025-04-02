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
          'select, input:not([data-module~="select-with-search"] input)'
        )
        indexedElements.forEach((element, index) => {
          element.dataset.ga4IndexSection = index
        })
      })
    }
  }
})(window.GOVUK.analyticsGa4.analyticsModules)
