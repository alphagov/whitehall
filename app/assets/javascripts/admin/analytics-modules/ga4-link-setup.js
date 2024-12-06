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
          // Exclude links that serve as tab controls as they have their own event tracking
          if (link.role === 'tab') {
            return
          }
          const event = {
            event_name: 'navigation',
            type: link.role === 'button' ? 'button' : 'generic_link'
          }
          if (link.dataset.ga4Link) {
            Object.assign(event, JSON.parse(link.dataset.ga4Link))
          }
          link.dataset.ga4Link = JSON.stringify(event)
        })
      })
    }
  }
})(window.GOVUK.analyticsGa4.analyticsModules)
