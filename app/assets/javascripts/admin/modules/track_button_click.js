/* global GOVUKAdmin */

(function (Modules) {
  'use strict'

  Modules.TrackButtonClick = function () {
    this.start = function (container) {
      var trackClick = function () {
        var category = container.data('track-category')
        var action = container.data('track-action') || 'button-pressed'
        var label = $(this).is(':input') ? $(this).val() : $(this).text()

        GOVUKAdmin.trackEvent(category, action, { label: label })
      }

      container.on('click', '.btn', trackClick)
    }
  }
})(window.GOVUKAdmin.Modules)
