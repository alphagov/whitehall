'use strict'
window.GOVUK = window.GOVUK || {}
window.GOVUK.analyticsGa4 = window.GOVUK.analyticsGa4 || {}
window.GOVUK.analyticsGa4.analyticsModules =
  window.GOVUK.analyticsGa4.analyticsModules || {}
;(function (Modules) {
  Modules.Ga4SearchResultsSetup = {
    init: function (noHashChange) {
      if (!document.querySelector('[data-ga4-ecommerce]')) {
        return
      }

      this.addSearchResultLinkTracking()

      // if we have multiple tabs with search results
      // then remove the attributes so that we only capture
      // the search results in the visible tab
      Array.from(document.querySelectorAll('[data-ga4-ecommerce]')).forEach(
        (search) => {
          if (search.closest('[data-module~="govuk-tabs"]')) {
            search.removeAttribute('data-ga4-ecommerce')
          }

          search.setAttribute('data-search-track', true)
        }
      )

      this.trackEcommerce()

      if (!noHashChange) {
        this.eventListener = this.trackEcommerce.bind(this)

        window.addEventListener('hashchange', this.eventListener)
      }
    },

    addSearchResultLinkTracking: function () {
      document.querySelectorAll('[data-ga4-ecommerce]').forEach((container) => {
        const table = container.querySelector('table')

        // all search results are displayed in
        // tables so if there's no table then
        // there's no results to track clicks on
        if (!table) return

        table.querySelectorAll('tbody tr').forEach((row, rowIndex) => {
          // the last cell in the search results has action links
          // these are the links that we want to track
          row
            .querySelectorAll('td a[data-ga4-ecommerce-content-id]')
            .forEach((link) => {
              link.setAttribute('data-ga4-ecommerce-path', link.href)
              // there are multiple links per row, use the index of the
              // row as the index not the index of the link within table
              link.setAttribute('data-ga4-ecommerce-index', rowIndex + 1)
            })
        })
      })
    },

    trackEcommerce: function () {
      // this is because we have an instance of a search result
      // page within a tab component and we only want to fire a
      // search result event if the tab with the search result
      // is visible

      const hash = window.location.hash

      let searchTarget = document.querySelector('[data-ga4-ecommerce]')

      if (
        !searchTarget &&
        document.querySelector('[data-module~="govuk-tabs"]')
      ) {
        if (hash.length) {
          searchTarget = document.querySelector(
            `[data-module~="govuk-tabs"] ${hash} [data-search-track]`
          )
        } else {
          // if search result is on the first tab
          // and the page is loaded without an anchor

          // get the first instance of a search in a tab
          // on the page if it exists
          searchTarget = document.querySelector(
            '[data-module~="govuk-tabs"] section [data-search-track]'
          )

          if (searchTarget) {
            const sectionOfSearchTarget = searchTarget.closest('section')

            const sectionIndexOfSearchTarget = Array.from(
              searchTarget
                .closest('[data-module~="govuk-tabs"]')
                .querySelectorAll('section')
            ).indexOf(sectionOfSearchTarget)

            searchTarget = !sectionIndexOfSearchTarget && searchTarget
          }
        }
      }

      if (searchTarget) {
        searchTarget.setAttribute('data-ga4-ecommerce', true)

        if (!searchTarget.hasAttribute('data-ga4-ecommerce-started')) {
          window.GOVUK.analyticsGa4.Ga4EcommerceTracker.init()
        }

        searchTarget.setAttribute('data-ga4-ecommerce-started', true)
      }
    }
  }
})(window.GOVUK.analyticsGa4.analyticsModules)
