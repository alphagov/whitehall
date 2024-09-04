'use strict'
window.GOVUK = window.GOVUK || {}
window.GOVUK.analyticsGa4 = window.GOVUK.analyticsGa4 || {}
window.GOVUK.analyticsGa4.analyticsModules =
  window.GOVUK.analyticsGa4.analyticsModules || {}
;(function (Modules) {
  Modules.Ga4LinkSetup = {
    init: function () {
      const moduleElements = document.querySelectorAll(
        "[data-module~='ga4-link-setup']"
      )
      moduleElements.forEach(function (moduleElement) {
        const links = moduleElement.querySelectorAll('a')
        links.forEach((link) => {
          const event = {
            event_name: 'navigation',
            type: 'generic_link',
            section: document.title.split(' - ')[0].replace('Error: ', '')
          }
          if (link.dataset.ga4Event) {
            Object.assign(event, JSON.parse(link.dataset.ga4Event))
          }
          link.dataset.ga4Event = JSON.stringify(event)
        })
      })
    }
  }
})(window.GOVUK.analyticsGa4.analyticsModules)
