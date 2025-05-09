'use strict'
window.GOVUK = window.GOVUK || {}
window.GOVUK.analyticsGa4 = window.GOVUK.analyticsGa4 || {}
window.GOVUK.analyticsGa4.analyticsModules =
  window.GOVUK.analyticsGa4.analyticsModules || {}
;(function (Modules) {
  Modules.analyticsModules = Modules.analyticsModules || {}

  Modules.analyticsModules.Ga4FinderSetup = {
    init: function () {
      const finders = Array.from(
        document.querySelectorAll("[data-module~='ga4-finder-tracker']")
      )

      if (finders) {
        finders.forEach((finder) => {
          finder.addEventListener('change', this.onFinderChange)
        })

        Modules.Ga4FinderTracker = Modules.Ga4FinderTracker || {}
        Modules.Ga4FinderTracker.extraSupportedElements = {
          // for select with search with multiple choice
          'select-multiple': function (eventTarget, event) {
            const eventValue = event.detail.value
            const elementValue = eventTarget.querySelector(
              `option[value="${eventValue}"]`
            ).text
            const selectedEventOption = eventTarget.querySelector(
              `option[value="${eventValue}"]:checked`
            )

            return {
              elementValue,
              wasFilterRemoved: !selectedEventOption
            }
          }
        }
      }
    },

    onFinderChange: function (event) {
      let ga4ChangeCategory = event.target.closest('[data-ga4-change-category]')
      if (ga4ChangeCategory) {
        ga4ChangeCategory = ga4ChangeCategory.getAttribute(
          'data-ga4-change-category'
        )
        window.GOVUK.analyticsGa4.Ga4FinderTracker.trackChangeEvent(
          event,
          ga4ChangeCategory
        )
      }
    }
  }
})(window.GOVUK.analyticsGa4)
