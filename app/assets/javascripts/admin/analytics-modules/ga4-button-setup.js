'use strict'
window.GOVUK = window.GOVUK || {}
window.GOVUK.analyticsGa4 = window.GOVUK.analyticsGa4 || {}
window.GOVUK.analyticsGa4.analyticsModules =
  window.GOVUK.analyticsGa4.analyticsModules || {}
;(function (Modules) {
  Modules.Ga4ButtonSetup = {
    init: function () {
      const moduleElements = document.querySelectorAll(
        "[data-module~='ga4-button-setup']"
      )
      moduleElements.forEach(function (moduleElement) {
        const buttons = moduleElement.querySelectorAll(
          'button, [role="button"]'
        )
        buttons.forEach((button) => {
          const event = {
            event_name: 'navigation',
            type: 'button',
            text: button.textContent,
            action: button.textContent,
            method: 'primary_click'
          }
          if (button.dataset.ga4Event) {
            Object.assign(event, JSON.parse(button.dataset.ga4Event))
          }
          button.dataset.ga4Event = JSON.stringify(event)
        })
      })
    }
  }
})(window.GOVUK.analyticsGa4.analyticsModules)
