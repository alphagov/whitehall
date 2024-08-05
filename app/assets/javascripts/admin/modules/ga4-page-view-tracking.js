'use strict'
window.GOVUK = window.GOVUK || {}
window.GOVUK.analyticsGa4 = window.GOVUK.analyticsGa4 || {}
window.GOVUK.analyticsGa4.analyticsModules =
  window.GOVUK.analyticsGa4.analyticsModules || {}
;(function (Modules) {
  function GA4PageViewTracking(module) {
    this.module = module
  }

  GA4PageViewTracking.prototype.init = function () {
    this.trackingData = this.module.getAttribute('data-attributes')
    window.GOVUK.analyticsGa4.core.sendData(JSON.parse(this.trackingData))
  }

  Modules.GA4PageViewTracking = GA4PageViewTracking
})(window.GOVUK.analyticsGa4.analyticsModules)
