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
        const forms = $module.querySelectorAll('form')
        forms.forEach(function (form) {
          const section = form.closest('[data-ga4-form-type]')
          const type = form.closest('[data-ga4-document-type]')

          form.setAttribute(
            'data-ga4-form',
            JSON.stringify({
              event_name: 'form_response',
              type,
              section,
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

          form.addEventListener('change', (event) => {
            const target = event.target
            const indexJson = target.closest('[data-ga4-index]')
            const type = target.closest('[data-ga4-form-type]')
            const section = document.querySelector(
              `label[for='${target.id}']`
            ).innerText

            let index = {}

            try {
              index = indexJson.getAttribute('data-ga4-index')
              index = JSON.parse(index)
            } catch (e) {
              console.error(
                'GA4 configuration error: ' + e.message,
                window.location
              )
            }

            const schema = {
              event_name: 'select_content',
              action: target.value ? 'select' : 'remove',
              section,
              text: target.value,
              type: type && type.getAttribute('data-ga4-form-type'),
              ...index
            }

            if (target.closest('.govuk-date-input')) {
              // only track if completely filled in
              const inputs = [
                ...target.closest('.govuk-date-input').querySelectorAll('input')
              ]
              const allInputsSet = inputs.every((input) => input.value)

              if (!allInputsSet) return

              schema.text = inputs.map((input) => input.value).join('/')
            }

            if (target.type === 'radio' || target.type === 'checkbox') {
              schema.section = target
                .closest('fieldset')
                .querySelector('legend').textContent
              schema.text = document.querySelector(
                `label[for='${target.id}']`
              ).textContent

              schema.action = target.checked ? 'select' : 'remove'
            }

            if (target.tagName === 'SELECT') {
              let value = target.value

              if (event.detail && event.detail.value) {
                value = event.detail.value
              }

              const option = target.querySelector(`option[value="${value}"]`)

              schema.action = option.checked ? 'select' : 'remove'
              schema.text = option.innerText
            }

            window.GOVUK.analyticsGa4.core.applySchemaAndSendData(
              schema,
              'event_data'
            )
          })
        })

        new window.GOVUK.Modules.Ga4FormTracker($module).init()
      })
    }
  }
})(window.GOVUK.analyticsGa4.analyticsModules)
