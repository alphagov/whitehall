'use strict'
window.GOVUK = window.GOVUK || {}
window.GOVUK.Modules = window.GOVUK.Modules || {}
;(function (Modules) {
  function FormPrefix(module) {
    this.module = module
  }

  FormPrefix.prototype.init = function () {
    // Create a prefix element
    const prefix = document.createElement('span')
    prefix.classList.add('govuk-input__prefix')
    prefix.setAttribute('aria-hidden', 'true')
    prefix.textContent = this.module.dataset.prefix

    // Add a wrapper with the prefix
    const wrapper = document.createElement('div')
    wrapper.classList.add('govuk-input__wrapper')
    this.module.parentNode.insertBefore(wrapper, this.module)
    wrapper.appendChild(this.module)
    wrapper.insertBefore(prefix, this.module)

    // Remove the prefix from the text boxes value
    if (this.module.value.startsWith(this.module.dataset.prefix)) {
      this.module.value = this.module.value.slice(
        this.module.dataset.prefix.length
      )
    }

    // Add a listener to add the prefix once the form is submitted
    this.module.form.addEventListener('submit', this.appendPrefix.bind(this))
  }

  FormPrefix.prototype.appendPrefix = function (e) {
    const form = this.module.form
    const inputName = this.module.name

    form[inputName].value = this.module.dataset.prefix + form[inputName].value
  }

  Modules.FormPrefix = FormPrefix
})(window.GOVUK.Modules)
