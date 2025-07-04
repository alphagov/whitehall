'use strict'
window.GOVUK = window.GOVUK || {}
window.GOVUK.analyticsGa4 = window.GOVUK.analyticsGa4 || {}
window.GOVUK.analyticsGa4.analyticsModules =
  window.GOVUK.analyticsGa4.analyticsModules || {}
;(function (Modules) {
  Modules.Ga4SearchSetup = {
    init: function () {
      // not tracking searches on input[type="search"]
      // in the select with search component (yet)
      const searchFormInputs = document.querySelectorAll(
        'input[type="search"]:not([data-module~="select-with-search"] input)'
      )

      searchFormInputs.forEach((searchFormInput) => {
        const searchForm = searchFormInput.closest('form')

        if (searchForm) {
          let ga4DocumentType = searchForm.closest('[data-ga4-document-type]')

          if (ga4DocumentType) {
            ga4DocumentType = ga4DocumentType.dataset.ga4DocumentType
          }

          let ga4SearchSection = 'Filter by'

          const ga4SearchSectionOverride = searchForm.closest(
            '[data-ga4-search-section]'
          )

          if (ga4SearchSectionOverride) {
            ga4SearchSection = ga4SearchSectionOverride.dataset.ga4SearchSection
          }

          searchForm.dataset.ga4SearchType = ga4DocumentType
          searchForm.dataset.ga4SearchUrl = window.location.pathname
          searchForm.dataset.ga4SearchSection = ga4SearchSection
          searchForm.dataset.ga4SearchInputName = searchFormInput.name

          // an event is added by default to all buttons in whitehall
          // in `ga4-button-setup`, this removes that event and prevents
          // double event firing on search submit
          const searchFormButton = searchForm.querySelector(
            'button[type="submit"]'
          )

          if (searchFormButton) {
            searchFormButton.removeAttribute('data-ga4-event')
          }

          const tracker = new window.GOVUK.Modules.Ga4SearchTracker(searchForm)
          tracker.init()
        }
      })
    }
  }
})(window.GOVUK.analyticsGa4.analyticsModules)
