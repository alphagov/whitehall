window.GOVUK = window.GOVUK || {}
window.GOVUK.Modules = window.GOVUK.Modules || {};

(function (Modules) {
  function TrackSelectedTaxons (module) {
    this.form = module
  }

  TrackSelectedTaxons.prototype.init = function () {
    this.form.addEventListener('submit', this.onSubmitListener.bind(this))
    this.addTaxonSelectionEvent()
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

  TrackSelectedTaxons.prototype.addTaxonSelectionEvent = function () {
    var taxonCheckboxes = this.form.querySelectorAll('.miller-columns__item .govuk-checkboxes__input')

    for (var index = 0; index < taxonCheckboxes.length; index++) {
      var checkbox = taxonCheckboxes[index]

      checkbox.addEventListener('click', function (e) {
        var target = e.currentTarget
        var label = this.form.querySelector('label[for="' + target.id + '"]').innerText.trim()

        GOVUK.analytics.trackEvent(
          'pageElementInteraction',
          target.checked ? 'checkboxClickedOn' : 'checkboxClickedOff',
          { label: label }
        )
      })
    }
  }

  Modules.TrackSelectedTaxons = TrackSelectedTaxons
})(window.GOVUK.Modules)
