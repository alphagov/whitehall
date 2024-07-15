window.GOVUK = window.GOVUK || {}
window.GOVUK.Modules = window.GOVUK.Modules || {}
;(function (Modules) {
  function Ga4LinkSetup(module) {
    this.module = module
  }

  Ga4LinkSetup.prototype.init = function () {
    const links = this.module.querySelectorAll('a')
    links.forEach((link) => {
      const event = {
        event_name: 'navigation',
        type: 'generic_link',
        section: document.title.split(' - ')[0]
      }
      if (link.dataset.ga4Event) {
        Object.assign(event, JSON.parse(link.dataset.ga4Event))
      }
      link.dataset.ga4Event = JSON.stringify(event)
    })
  }

  Modules.Ga4LinkSetup = Ga4LinkSetup
})(window.GOVUK.Modules)
