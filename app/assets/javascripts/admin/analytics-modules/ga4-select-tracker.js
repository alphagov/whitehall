'use strict'
window.GOVUK = window.GOVUK || {}
window.GOVUK.analyticsGa4 = window.GOVUK.analyticsGa4 || {}
window.GOVUK.analyticsGa4.analyticsModules =
  window.GOVUK.analyticsGa4.analyticsModules || {}
;(function (Modules) {
  Modules.Ga4SelectSetup = {
    init: function () {
      const moduleElements = document.querySelectorAll(
        "[data-module~='ga4-select-setup']"
      )

      moduleElements.forEach(function (moduleElement) {
        moduleElement.addEventListener('change', function (event) {
          const ga4DocumentType = moduleElement.dataset.ga4DocumentType

          if (
            event.target.tagName.toLowerCase() === 'select' &&
            !event.target.getAttribute('hidden')
          ) {
            const eventData = {
              event: 'event_data',
              event_data: {
                event_name: 'select_content',
                type: event.target.dataset.ga4DocumentType || ga4DocumentType,
                index: {
                  index_section_count: `${event.target.selectedIndex}`,
                  index_section: event.target.dataset.ga4IndexSection
                },
                text: event.target[event.target.selectedIndex].label,
                section:
                  event.target.dataset.ga4Section ||
                  event.target.labels[0].innerText,
                action: 'select'
              }
            }

            window.GOVUK.analyticsGa4.core.sendData(eventData, 'event_data')
          }
        })
      })
    }
  }
})(window.GOVUK.analyticsGa4.analyticsModules)
