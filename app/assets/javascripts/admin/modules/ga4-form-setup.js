'use strict'
window.GOVUK = window.GOVUK || {}
window.GOVUK.analyticsGa4 = window.GOVUK.analyticsGa4 || {}
window.GOVUK.analyticsGa4.analyticsModules =
  window.GOVUK.analyticsGa4.analyticsModules || {}
;(function (Modules) {
  function Ga4FormSetup(module) {
    this.module = module
  }

  Ga4FormSetup.prototype.init = function () {
    const submitButton = this.module.querySelector('button[type="submit"]')
    this.module.dataset.ga4Form = JSON.stringify({
      event_name: 'form_response',
      section: document.title.split(' - ')[0].replace('Error: ', ''),
      action: submitButton.textContent.toLowerCase()
    })
  }

  Modules.Ga4FormSetup = Ga4FormSetup
})(window.GOVUK.analyticsGa4.analyticsModules)
