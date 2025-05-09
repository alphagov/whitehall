'use strict'
window.GOVUK = window.GOVUK || {}
window.GOVUK.analyticsGa4 = window.GOVUK.analyticsGa4 || {}
window.GOVUK.analyticsGa4.analyticsModules =
  window.GOVUK.analyticsGa4.analyticsModules || {}
;(function (Modules) {
  Modules.analyticsModules = Modules.analyticsModules || {}

  const excludedTypes = ['search', 'hidden', 'text', 'textarea']

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

              if (el.type === 'radio') {
                if (!el.closest('fieldset').querySelector('input:checked')) {
                  changeCategoryType = 'radio-empty'
                }
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
            // forms that don't have a default radio button selected
            // so all radio button interactions are a selection
            // as you won't be able to clear the input once the select
            // has been made
            'radio-empty': (eventTarget) => ({
              ...Modules.Ga4FinderTracker.defaultSupportedElements.radio(
                eventTarget
              ),
              wasFilterRemoved: false
            }),
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
