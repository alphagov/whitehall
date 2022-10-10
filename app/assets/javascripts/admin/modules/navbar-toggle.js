window.GOVUK = window.GOVUK || {}
window.GOVUK.Modules = window.GOVUK.Modules || {};

(function (Modules) {
  function NavbarToggle (module) {
    this.module = module
    this.toggler = this.module.querySelector('.js-navbar-toggle__toggler')
    this.menu = this.module.querySelector('.js-navbar-toggle__menu')
  }

  NavbarToggle.prototype.init = function () {
    this.menu.classList.add('govuk-visually-hidden')
    this.initToggleListener()
  }

  NavbarToggle.prototype.initToggleListener = function () {
    this.toggler.addEventListener('click', function (e) {
      e.stopPropagation()
      e.preventDefault()

      this.module.classList.toggle('open')
      this.menu.classList.toggle('govuk-visually-hidden')
    }.bind(this))
  }

  Modules.NavbarToggle = NavbarToggle
})(window.GOVUK.Modules)
