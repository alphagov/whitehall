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
        moduleElement.addEventListener('addItem', function (event) {
          const eventData = {
            event: 'event_data',
            event_data: {
              event_name: 'select_component',
              type: event.target.dataset.ga4DocumentType,
              index: {
                index_section_count: `${event.target.selectedIndex}`,
                index_section: event.target.dataset.ga4IndexSection
              },
              text: event.detail.label,
              section: event.target.dataset.ga4Section,
              action: 'select'
            }
          }

          window.GOVUK.analyticsGa4.core.sendData(eventData, 'event_data')
        })

        if (moduleElement.getAttribute('multiple') !== null) {
          moduleElement.addEventListener('removeItem', function (event) {
            const eventData = {
              event: 'event_data',
              event_data: {
                event_name: 'select_component',
                type: event.target.dataset.ga4DocumentType,
                index: {
                  index_section_count: `${event.detail.value}`,
                  index_section: event.target.dataset.ga4IndexSection
                },
                text: event.detail.label,
                section: event.target.dataset.ga4Section,
                action: 'remove'
              }
            }

            window.GOVUK.analyticsGa4.core.sendData(eventData, 'event_data')
          })
        }
      })
    }
  }
})(window.GOVUK.analyticsGa4.analyticsModules)
