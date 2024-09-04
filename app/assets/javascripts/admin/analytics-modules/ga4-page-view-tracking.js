'use strict'
window.GOVUK = window.GOVUK || {}
window.GOVUK.analyticsGa4 = window.GOVUK.analyticsGa4 || {}
window.GOVUK.analyticsGa4.analyticsModules =
  window.GOVUK.analyticsGa4.analyticsModules || {}
;(function (Modules) {
  Modules.GA4PageViewTracking = {
    init: function () {
      const trackingDataElement = document.querySelector(
        "[data-module~='ga4-page-view-tracking']"
      )
      window.GOVUK.analyticsGa4.core.sendData(
        JSON.parse(trackingDataElement.dataset.attributes)
      )
    }
  }
})(window.GOVUK.analyticsGa4.analyticsModules)
