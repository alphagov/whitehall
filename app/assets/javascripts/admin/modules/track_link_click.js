/* global GOVUKAdmin */

(function (Modules) {
  'use strict'

  Modules.TrackLinkClick = function () {
    this.start = function (link) {
      var trackClick = function () {
        var category = link.data('track-category')
        var action = link.data('track-action') || 'link-clicked'
        var label = link.data('track-label') || $(this).text()

        GOVUKAdmin.trackEvent(category, action, { label: label })
      }

      link.on('click', trackClick)
    }
  }
})(window.GOVUKAdmin.Modules)
