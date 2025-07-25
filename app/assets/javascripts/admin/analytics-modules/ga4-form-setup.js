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
          "form:not([data-module~='ga4-finder-tracker'])"
        )

        forms.forEach(function (form) {
          if (!form.querySelector(trackedComponentsSelector)) {
            form.setAttribute('data-ga4-form-change-tracking', '')
          }

          const sectionContainer = form.closest('[data-ga4-section]')
          const documentTypeContainer = form.closest('[data-ga4-document-type]')
          const contentIdContainer = form.closest('[data-ga4-content-id]')

          let eventData = {
            event_name: 'form_response',
            action: 'Save'
          }

          if (sectionContainer) {
            eventData.section =
              sectionContainer.getAttribute('data-ga4-section')
          }

          if (contentIdContainer) {
            eventData.content_id = contentIdContainer.getAttribute(
              'data-ga4-content-id'
            )
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

          form.addEventListener('submit', this.onSubmit)
        }, this)

        $module.setAttribute('data-ga4-form-record-json', '')
        $module.setAttribute('data-ga4-form-include-text', '')
        $module.setAttribute('data-ga4-form-use-text-count', '')

        new window.GOVUK.Modules.Ga4FormTracker($module).init()
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
