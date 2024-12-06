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
        const buttons = moduleElement.querySelectorAll('button')
        buttons.forEach((button) => {
          const event = {
            event_name:
              button.type === 'submit' ? 'navigation' : 'select_content',
            type: 'button',
            text: button.textContent
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
