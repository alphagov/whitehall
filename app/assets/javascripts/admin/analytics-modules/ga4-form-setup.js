'use strict'
window.GOVUK = window.GOVUK || {}
window.GOVUK.analyticsGa4 = window.GOVUK.analyticsGa4 || {}
window.GOVUK.analyticsGa4.analyticsModules =
  window.GOVUK.analyticsGa4.analyticsModules || {}
;(function (Modules) {
  Modules.Ga4FormSetup = {
    init: function () {
      const $modules = document.querySelectorAll(
        "[data-module~='ga4-form-setup']"
      )

      $modules.forEach(($module) => {
        const forms = $module.querySelectorAll(
          "form:not([data-module~='ga4-finder-tracker'])"
        )
        forms.forEach(function (form) {
          const sectionContainer = form.closest('[data-ga4-section]')
          const documentTypeContainer = form.closest('[data-ga4-document-type]')

          form.setAttribute(
            'data-ga4-form',
            JSON.stringify({
              event_name: 'form_response',
              type: documentTypeContainer.getAttribute(
                'data-ga4-document-type'
              ),
              section: sectionContainer.getAttribute('data-ga4-section'),
              action: 'Save'
            })
          )

          form.addEventListener('submit', () => {
            // on forms we have multiple submit buttons so need to "guess"
            // the action from the focused element on submit

            const activeElement = document.activeElement

            const dataGa4Form = JSON.parse(form.getAttribute('data-ga4-form'))

            dataGa4Form.action = activeElement.innerHTML

            form.setAttribute('data-ga4-form', JSON.stringify(dataGa4Form))
          })
        })

        new window.GOVUK.Modules.Ga4FormTracker($module).init()
      })
    }
  }
})(window.GOVUK.analyticsGa4.analyticsModules)
