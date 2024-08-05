window.GOVUK = window.GOVUK || {}
window.GOVUK.analyticsGa4 = window.GOVUK.analyticsGa4 || {}
window.GOVUK.analyticsGa4.analyticsModules =
  window.GOVUK.analyticsGa4.analyticsModules || {}
;(function (Modules) {
  function Ga4PasteTracker(module) {
    this.module = module
  }

  Ga4PasteTracker.prototype.init = function () {
    window.addEventListener('paste', this.trackPaste.bind(this))
  }

  Ga4PasteTracker.prototype.trackPaste = function (event) {
    const data = {
      event_name: 'paste',
      type: 'paste',
      action: 'paste',
      method: 'browser paste'
    }
    window.GOVUK.analyticsGa4.core.applySchemaAndSendData(data, 'event_data')
  }

  Modules.Ga4PasteTracker = Ga4PasteTracker
})(window.GOVUK.analyticsGa4.analyticsModules)
