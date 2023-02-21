window.GOVUK = window.GOVUK || {}
window.GOVUK.Modules = window.GOVUK.Modules || {};

(function (Modules) {
  function PreventMultipleFormSubmissions (module) {
    this.module = module
    this.submitButtons = module.querySelectorAll('button')
  }

  PreventMultipleFormSubmissions.prototype.init = function () {
    this.module.addEventListener('submit', this.submit.bind(this))
  }

  PreventMultipleFormSubmissions.prototype.submit = function (e) {
    for (var index = 0; index < this.submitButtons.length; index++) {
      var button = this.submitButtons[index]

      button.setAttribute('disabled', 'disabled')
      button.setAttribute('aria-disabled', 'true')
      button.classList.add('govuk-button--disabled')
    }

    return true
  }

  Modules.PreventMultipleFormSubmissions = PreventMultipleFormSubmissions
})(window.GOVUK.Modules)
