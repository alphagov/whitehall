(function (GOVUK) {
  'use strict'

  GOVUK.setCustomDimensionsFromMetaTags = function () {
    var metas = document.querySelectorAll("meta[name^='custom-dimension']")

    for (var i = 0; i < metas.length; i++) {
      var meta = metas[i]
      var dimensionId = parseInt(meta.getAttribute('name').split('custom-dimension:')[1])
      var content = meta.getAttribute('content')

      GOVUK.analytics.setDimension(dimensionId, content)
    }
  }

  GOVUK.Analytics.load()
  GOVUK.analyticsVars = { primaryLinkedDomains: [document.domain] }
  GOVUK.analytics = new GOVUK.Analytics({
    universalId: 'UA-26179049-6', // GOVUK Apps GA ID
    cookieDomain: document.domain
  })

  GOVUK.setCustomDimensionsFromMetaTags()
  GOVUK.analytics.trackPageview()
  GOVUK.analyticsPlugins.externalLinkTracker()
})(window.GOVUK)
