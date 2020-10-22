(function () {
  'use strict'
  window.GOVUK = window.GOVUK || {}

  window.GOVUK.brokenLinksReport = {
    init: function init () {
      $('a.js-broken-links-refresh').each(function () {
        var $link = $(this)

        window.GOVUK.smartPoller(2000, function (retry) {
          if ($('a.js-broken-links-refresh').length !== 0) {
            $link.click()
            retry()
          }
        })
      })
    }
  }
}())
