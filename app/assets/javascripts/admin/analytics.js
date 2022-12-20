(function (GOVUK) {
  'use strict'

  GOVUK.Analytics.load()
  GOVUK.analyticsVars = { primaryLinkedDomains: [document.location.host] }
  GOVUK.analytics = new GOVUK.Analytics({
    universalId: 'UA-26179049-6', // GOVUK Apps GA ID
    cookieDomain: document.location.host
  })
})(window.GOVUK)
