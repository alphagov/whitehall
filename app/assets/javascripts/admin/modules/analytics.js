(function (GOVUK) {
  'use strict'

  GOVUK.Analytics.load()
  GOVUK.analyticsVars = { primaryLinkedDomains: [document.domain] }
  GOVUK.analytics = new GOVUK.Analytics({
    universalId: 'UA-26179049-6', // GOVUK Apps GA ID
    cookieDomain: document.domain
  })

  GOVUK.analytics.trackPageview()
})(window.GOVUK)
