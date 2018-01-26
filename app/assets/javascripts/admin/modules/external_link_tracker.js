// based on https://github.com/alphagov/govuk_frontend_toolkit/blob/master/javascripts/govuk/analytics/external-link-tracker.js
;(function (global) {
  'use strict'

  var $ = global.jQuery
  var externalLinkTracker = function () {
    var externalLinkSelector = 'a[href^="http"]:not(a[href*="' + global.location.hostname + '"])'
    $('body').on('click', externalLinkSelector, trackClickEvent)

    function trackClickEvent (evt) {
      var $link = getLinkFromEvent(evt)
      var href = $link.attr('href')
      var linkText = $.trim($link.text())
      var options = {}

      if (linkText) {
        options.label = linkText
      }

      GOVUKAdmin.trackEvent('external-link-clicked', href, options);
    }

    function getLinkFromEvent (evt) {
      var $target = $(evt.target)

      if (!$target.is('a')) {
        $target = $target.parents('a')
      }

      return $target
    }
  }

  externalLinkTracker()
})(window)
