'use strict'
window.GOVUK = window.GOVUK || {}
window.GOVUK.analyticsGa4 = window.GOVUK.analyticsGa4 || {}
window.GOVUK.analyticsGa4.analyticsModules =
  window.GOVUK.analyticsGa4.analyticsModules || {}
;(function (Modules) {
  Modules.Ga4FormSetup = {
    trackedComponents: ['reorderable-list'],

    init: function () {
      const $modules = document.querySelectorAll(
        "[data-module~='ga4-form-setup']"
      )

      const trackedComponentsSelector = Modules.Ga4FormSetup.trackedComponents
        .map((trackedComponent) => `[data-module~="${trackedComponent}"]`)
        .join(',')

      $modules.forEach(($module) => {
        const forms = $module.querySelectorAll(
          "form:not([data-module~='ga4-finder-tracker']):not([data-module~='ga4-form-tracker'])"
        )

        forms.forEach(function (form) {
          if (!form.querySelector(trackedComponentsSelector)) {
            form.setAttribute('data-ga4-form-change-tracking', '')
          }

          const sectionContainer = form.closest('[data-ga4-section]')
          const documentTypeContainer = form.closest('[data-ga4-document-type]')

          let eventData = {
            event_name: 'form_response',
            action: 'Save'
          }

          if (sectionContainer) {
            eventData.section =
              sectionContainer.getAttribute('data-ga4-section')
          }

          if (documentTypeContainer) {
            const [type, toolName] =
              documentTypeContainer.dataset.ga4DocumentType.split('-')

            const synonyms = {
              create: 'new',
              update: 'edit'
            }

            eventData = {
              ...eventData,
              type: synonyms[type] || type,
              tool_name: toolName
            }
          }

          form.setAttribute('data-ga4-form', JSON.stringify(eventData))

          if (
            form.querySelectorAll(
              'fieldset, input:not([type="checkbox"],[type="hidden"],[type="radio"],[type="search"]), select'
            ).length > 1
          ) {
            // only record JSON if number of fields larger than 1
            form.setAttribute('data-ga4-form-record-json', '')
          }

          form.setAttribute('data-ga4-form-include-text', '')
          form.setAttribute('data-ga4-form-use-text-count', '')
          new window.GOVUK.Modules.Ga4FormTracker(form).init()

          form.addEventListener('submit', this.onSubmit)
        }, this)
      })
    },

    onSubmit: (event) => {
      // on forms we have multiple submit buttons so need to "guess"
      // the action from the focused element on submit

      const form = event.target.closest('form')

      const activeElement = document.activeElement

      try {
        const dataGa4Form = JSON.parse(form.getAttribute('data-ga4-form'))

        dataGa4Form.action = activeElement.textContent

        form.setAttribute('data-ga4-form', JSON.stringify(dataGa4Form))
      } catch (error) {
        console.log(error)
      }
    }
  }
})(window.GOVUK.analyticsGa4.analyticsModules)
