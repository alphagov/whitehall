(function () {
  'use strict'
  window.GOVUK = window.GOVUK || {}

  function DocumentShareLinks (options) {
    var $el = $(options.el)

    $el.on('click', '.facebook', trackFacebook)
    $el.on('click', '.twitter', trackTwitter)

    function trackFacebook () {
      GOVUK.analytics.trackShare('facebook')
    }

    function trackTwitter () {
      GOVUK.analytics.trackShare('twitter')
    }
  }

  GOVUK.DocumentShareLinks = DocumentShareLinks
}())
