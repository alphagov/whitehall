(function () {
  'use strict'
  window.GOVUK = window.GOVUK || {}

  window.GOVUK.adminGlobalInitialiser = {
    init: function init () {
      GOVUK.init(GOVUK.navBarHelper)
      GOVUK.init(GOVUK.tabs)
    }
  }
}())
