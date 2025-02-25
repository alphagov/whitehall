'use strict'
window.GOVUK = window.GOVUK || {}
window.GOVUK.analyticsGa4 = window.GOVUK.analyticsGa4 || {}
window.GOVUK.analyticsGa4.analyticsModules =
  window.GOVUK.analyticsGa4.analyticsModules || {}
;(function (Modules) {
  Modules.Ga4SelectWithSearchSetup = {
    init: function () {
      const moduleElements = document.querySelectorAll(
        "[data-module~='ga4-select-with-search-setup'] select"
      )

      moduleElements.forEach(function (moduleElement) {
        moduleElement.addEventListener('change', function (event) {
          const eventData = {
            event_name: 'select_component',
            type: event.target.dataset.ga4DocumentType,
            index: {
              index_section_count: `${event.target.selectedIndex}`,
              index_section: event.target.dataset.ga4IndexSection
            },
            text: event.target.querySelector('[selected]')?.innerText ?? '',
            section: event.target.dataset.ga4Section,
            action: 'select'
          }

          window.GOVUK.analyticsGa4.core.applySchemaAndSendData(
            eventData,
            'event_data'
          )
        })
      })
    }
  }
})(window.GOVUK.analyticsGa4.analyticsModules)
