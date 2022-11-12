window.GOVUK = window.GOVUK || {}
window.GOVUK.Modules = window.GOVUK.Modules || {};

(function (Modules) {
  function FormSubmitLink (module) {
    this.module = module
  }

  FormSubmitLink.prototype.init = function () {
    this.module.addEventListener('click', function (e) {
      e.preventDefault()
      this.closest('form').submit()
    })
  }

  Modules.FormSubmitLink = FormSubmitLink
})(window.GOVUK.Modules)
