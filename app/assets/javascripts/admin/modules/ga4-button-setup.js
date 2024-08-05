'use strict'
window.GOVUK = window.GOVUK || {}
window.GOVUK.analyticsGa4 = window.GOVUK.analyticsGa4 || {}
window.GOVUK.analyticsGa4.analyticsModules =
  window.GOVUK.analyticsGa4.analyticsModules || {}
;(function (Modules) {
  function Ga4ButtonSetup(module) {
    this.module = module
  }

  Ga4ButtonSetup.prototype.init = function () {
    const buttons = this.module.querySelectorAll('button, [role="button"]')
    buttons.forEach((button) => {
      const event = {
        event_name: button.type === 'submit' ? 'form_response' : 'navigation',
        type: 'generic_link',
        text: button.textContent,
        section: document.title.split(' - ')[0].replace('Error: ', ''),
        action: button.textContent
      }
      if (button.dataset.ga4Event) {
        Object.assign(event, JSON.parse(button.dataset.ga4Event))
      }
      button.dataset.ga4Event = JSON.stringify(event)
    })
  }

  Modules.Ga4ButtonSetup = Ga4ButtonSetup
})(window.GOVUK.analyticsGa4.analyticsModules)
