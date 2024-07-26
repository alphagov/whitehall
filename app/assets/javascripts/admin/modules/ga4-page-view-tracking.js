'use strict'
window.GOVUK = window.GOVUK || {}
window.GOVUK.Modules = window.GOVUK.Modules || {}
;(function (Modules) {
  function GA4PageViewTracking(module) {
    this.module = module
  }

  GA4PageViewTracking.prototype.init = function () {
    this.trackingData = this.module.getAttribute('data-attributes')
    window.GOVUK.analyticsGa4.core.sendData(JSON.parse(this.trackingData))
  }

  Modules.GA4PageViewTracking = GA4PageViewTracking
})(window.GOVUK.Modules)
