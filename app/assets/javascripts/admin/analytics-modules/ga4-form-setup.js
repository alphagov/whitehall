'use strict'
window.GOVUK = window.GOVUK || {}
window.GOVUK.analyticsGa4 = window.GOVUK.analyticsGa4 || {}
window.GOVUK.analyticsGa4.analyticsModules =
  window.GOVUK.analyticsGa4.analyticsModules || {}
;(function (Modules) {
  Modules.Ga4FormSetup = {
    init: function () {
      const moduleElements = document.querySelectorAll(
        "[data-module~='ga4-form-setup']"
      )
      moduleElements.forEach(function (moduleElement) {
        const submitButton = moduleElement.querySelector(
          'button[type="submit"]'
        )
        moduleElement.dataset.ga4Form = JSON.stringify({
          event_name: 'form_response',
          section: document.title.split(' - ')[0].replace('Error: ', ''),
          action: submitButton.textContent.toLowerCase()
        })
      })
    }
  }
})(window.GOVUK.analyticsGa4.analyticsModules)
