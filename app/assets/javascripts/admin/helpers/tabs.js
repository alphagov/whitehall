(function () {
  'use strict'
  window.GOVUK = window.GOVUK || {}

  window.GOVUK.tabs = {
    init: function init () {
      var url = document.location.toString()
      if (url.match('#')) {
        $('.nav-tabs a[href=#' + url.split('#')[1] + ']').tab('show')
      }
      $('.nav-tabs a').on('shown', function (e) {
        var beforeShownScrollX = window.pageXOffset
        var beforeShownScrollY = window.pageYOffset
        window.location.hash = e.target.hash
        window.scrollTo(beforeShownScrollX, beforeShownScrollY)
      })
    }
  }
}())
