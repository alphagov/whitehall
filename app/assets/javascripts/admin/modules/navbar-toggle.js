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
    this.toggler.setAttribute('tabindex', 0)
    this.initToggleListeners()
  }

  NavbarToggle.prototype.initToggleListeners = function () {
    this.toggler.addEventListener('click', this.toggle.bind(this))
    this.toggler.addEventListener('keyup', this.toggle.bind(this))
  }

  NavbarToggle.prototype.toggle = function (e) {
    // Toggle menu for users tabbing through the navigation bar
    if (e.type === 'keyup' && (e.which !== 9 || this.module.classList.contains('open'))) return

    e.stopPropagation()
    e.preventDefault()

    this.module.classList.toggle('open')
    this.menu.classList.toggle('govuk-visually-hidden')
  }

  Modules.NavbarToggle = NavbarToggle
})(window.GOVUK.Modules)
