window.GOVUK = window.GOVUK || {}
window.GOVUK.Modules = window.GOVUK.Modules || {}
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
})(window.GOVUK.Modules)
