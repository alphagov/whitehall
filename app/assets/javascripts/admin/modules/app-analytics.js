window.GOVUK = window.GOVUK || {}
window.GOVUK.Modules = window.GOVUK.Modules || {};

(function (Modules) {
  function AppAnalytics (module) { }

  AppAnalytics.prototype.init = function () {
    this.setCustomDimensionsFromMetaTags()
    this.setAnalyticsPlugins()
    this.sendInitialView()
  }

  AppAnalytics.prototype.sendInitialView = function () {
    GOVUK.analytics.trackPageview()
  }

  AppAnalytics.prototype.setAnalyticsPlugins = function () {
    GOVUK.analyticsPlugins.externalLinkTracker()
  }

  AppAnalytics.prototype.setCustomDimensionsFromMetaTags = function () {
    const metas = document.querySelectorAll("meta[name^='custom-dimension']")

    for (let i = 0; i < metas.length; i++) {
      const meta = metas[i]
      const dimensionId = parseInt(meta.getAttribute('name').split('custom-dimension:')[1])
      const content = meta.getAttribute('content')

      GOVUK.analytics.setDimension(dimensionId, content)
    }
  }

  Modules.AppAnalytics = AppAnalytics
})(window.GOVUK.Modules)
