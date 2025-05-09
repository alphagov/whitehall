'use strict'
window.GOVUK = window.GOVUK || {}
window.GOVUK.analyticsGa4 = window.GOVUK.analyticsGa4 || {}
window.GOVUK.analyticsGa4.analyticsModules =
  window.GOVUK.analyticsGa4.analyticsModules || {}
;(function (Modules) {
  Modules.analyticsModules = Modules.analyticsModules || {}

  const excludedTypes = ['search', 'hidden']

  Modules.analyticsModules.Ga4FinderSetup = {
    init: function () {
      const finders = Array.from(
        document.querySelectorAll("[data-module~='ga4-finder-tracker']")
      )

      if (finders) {
        finders.forEach((finder) => {
          Array.from(finder.querySelectorAll('input, select')).forEach((el) => {
            const changeCategory = el.getAttribute('data-ga4-change-category')
            const isDateInput = el.closest('.govuk-date-input')

            if (excludedTypes.find((type) => type === el.type)) {
              if (!changeCategory && !isDateInput) return
            }

            if (!changeCategory) {
              let changeCategoryType

              const isDateInput = el.closest('.govuk-date-input')
              const isSelect = el.tagName === 'SELECT'

              if (isSelect) {
                changeCategoryType = 'select'
              }

              if (isDateInput) {
                changeCategoryType = 'date'
              }

              changeCategoryType = changeCategoryType || el.type

              if (el.hasAttribute('multiple')) {
                changeCategoryType = `${changeCategoryType}-multiple`
              }

              el.setAttribute(
                'data-ga4-change-category',
                `update-filter ${changeCategoryType}`
              )
            }
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
            },
            // for date filters on Editions search unlike
            // the Date component, these are single text
            // fields so just use default text tracker
            'one-date': (eventTarget) =>
              Modules.Ga4FinderTracker.defaultSupportedElements.text(
                eventTarget
              )
          }

          // because clearing the filters doesn't change
          // the form, it loads another page so we can't
          // use the `trackChange`
          const resetLink = finder.querySelector(
            'a[data-ga4-change-category="clear-all-filters"]'
          )

          if (resetLink) {
            const filterTypeContainer = resetLink.closest(
              '[data-ga4-filter-type]'
            )

            resetLink.setAttribute(
              'data-ga4-link',
              JSON.stringify({
                action: 'remove',
                event_name: 'select_content',
                text: resetLink.innerText,
                type:
                  (filterTypeContainer &&
                    filterTypeContainer.getAttribute('data-ga4-filter-type')) ||
                  undefined
              })
            )
          }

          finder.addEventListener('change', (event) => {
            let ga4ChangeCategory = event.target.closest(
              '[data-ga4-change-category]'
            )
            if (ga4ChangeCategory) {
              ga4ChangeCategory = ga4ChangeCategory.getAttribute(
                'data-ga4-change-category'
              )
              window.GOVUK.analyticsGa4.Ga4FinderTracker.trackChangeEvent(
                event,
                ga4ChangeCategory
              )
            }
          })
        })
      }
    }
  }
})(window.GOVUK.analyticsGa4)
