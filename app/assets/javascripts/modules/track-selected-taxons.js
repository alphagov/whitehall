window.GOVUK = window.GOVUK || {}
window.GOVUK.Modules = window.GOVUK.Modules || {};

(function (Modules) {
  function TrackSelectedTaxons (module) {
    this.form = module
  }

  TrackSelectedTaxons.prototype.init = function () {
    this.form.addEventListener('submit', this.onSubmitListener.bind(this))
  }

  TrackSelectedTaxons.prototype.onSubmitListener = function (e) {
    var selectedItems = this.form.querySelectorAll('.miller-columns-selected__list .miller-columns-selected__list-item')

    for (var index = 0; index < selectedItems.length; index++) {
      var taxonPath = []
      var taxons = selectedItems[index].querySelectorAll('.govuk-breadcrumbs__list-item')

      for (var i = 0; i < taxons.length; i++) {
        taxonPath.push(taxons[i].innerText.trim())
      }

      GOVUK.analytics.trackEvent('taxonSelection', taxonPath.join(' > '), { label: window.location.pathname })
    }
  }

  Modules.TrackSelectedTaxons = TrackSelectedTaxons
})(window.GOVUK.Modules)
