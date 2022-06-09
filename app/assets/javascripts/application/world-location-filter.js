(function () {
  'use strict'
  window.GOVUK = window.GOVUK || {}

  var worldLocationFilter = {
    init: function () {
      var worldSelect = document.querySelector('.js-world-location-filter select#world_locations')

      if (worldSelect) {
        worldSelect.addEventListener('change', function () {
          this.form.submit()
        })
      }

      var worldButton = document.querySelector('.js-world-location-filter button')

      if (worldButton) {
        worldButton.classList.add('govuk-!-display-none')
      }
    }
  }

  window.GOVUK.worldLocationFilter = worldLocationFilter
})()
