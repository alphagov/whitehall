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
    const selectedItems = this.form.querySelectorAll('.miller-columns-selected__list .miller-columns-selected__list-item')

    for (let index = 0; index < selectedItems.length; index++) {
      const taxonPath = []
      const taxons = selectedItems[index].querySelectorAll('.govuk-breadcrumbs__list-item')

      for (let i = 0; i < taxons.length; i++) {
        taxonPath.push(taxons[i].innerText.trim())
      }

      GOVUK.analytics.trackEvent('taxonSelection', taxonPath.join(' > '), { label: this.getCurrentPath() })
    }
  }

  TrackSelectedTaxons.prototype.addTaxonSelectionEvent = function () {
    const taxonCheckboxes = this.form.querySelectorAll('.miller-columns__item .govuk-checkboxes__input')

    for (let index = 0; index < taxonCheckboxes.length; index++) {
      const checkbox = taxonCheckboxes[index]

      checkbox.addEventListener('click', function (e) {
        const target = e.currentTarget
        const label = this.form.querySelector('label[for="' + target.id + '"]').innerText.trim()

        GOVUK.analytics.trackEvent(
          'pageElementInteraction',
          target.checked ? 'checkboxClickedOn' : 'checkboxClickedOff',
          { label }
        )
      })
    }
  }

  TrackSelectedTaxons.prototype.getCurrentPath = function () {
    return window.location.pathname
  }

  Modules.TrackSelectedTaxons = TrackSelectedTaxons
})(window.GOVUK.Modules)
