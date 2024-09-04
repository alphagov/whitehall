window.GOVUK = window.GOVUK || {}
window.GOVUK.analyticsGa4 = window.GOVUK.analyticsGa4 || {}
window.GOVUK.analyticsGa4.analyticsModules =
  window.GOVUK.analyticsGa4.analyticsModules || {}
;(function (Modules) {
  Modules.Ga4PasteTracker = {
    init: function () {
      window.addEventListener('paste', this.trackPaste.bind(this))
    },

    trackPaste: function (event) {
      const data = {
        event_name: 'paste',
        type: 'paste',
        action: 'paste',
        method: 'browser paste'
      }
      window.GOVUK.analyticsGa4.core.applySchemaAndSendData(data, 'event_data')
    }
  }
})(window.GOVUK.analyticsGa4.analyticsModules)
