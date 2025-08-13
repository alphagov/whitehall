'use strict'
window.GOVUK = window.GOVUK || {}
window.GOVUK.Modules = window.GOVUK.Modules || {}
;(function (Modules) {
  function EditionForm(module) {
    this.module = module
  }

  EditionForm.prototype.init = function () {
    this.setupSubtypeFormatAdviceEventListener()
    this.setupWorldNewsStoryVisibilityToggle()
    this.setupSpeechSubtypeEventListeners()
    this.setupSpeechDeliverdOnWarningEventListener()
  }

  EditionForm.prototype.setupSubtypeFormatAdviceEventListener = function () {
    const form = this.module
    const subtypeDiv = form.querySelector(
      '.js-app-view-edition-form__subtype-fields'
    )

    if (!subtypeDiv) {
      return
    }

    const subtypeSelect = subtypeDiv.querySelector('select')

    subtypeSelect.addEventListener('change', function () {
      const formatAdviceMap = JSON.parse(subtypeDiv.dataset.formatAdvice)
      const subtypeFormatAdvice = form.querySelector(
        '.js-app-view-edition-form__subtype-format-advice'
      )

      if (subtypeFormatAdvice) {
        subtypeDiv.removeChild(subtypeFormatAdvice)
      }

      const adviceText = formatAdviceMap[subtypeSelect.value]

      if (adviceText) {
        const div = document.createElement('div')
        div.classList.add(
          'js-app-view-edition-form__subtype-format-advice',
          'govuk-body',
          'govuk-!-margin-top-4'
        )
        div.innerHTML = '<strong>Use this subformat for…</strong> ' + adviceText
        subtypeDiv.append(div)
      }
    })
  }

  EditionForm.prototype.setupSpeechSubtypeEventListeners = function () {
    const form = this.module

    const select = form.querySelector('#edition_speech_type_id')

    if (!select) {
      return
    }

    const deliveredByLabel = form.querySelector(
      '#edition_role_appointment .govuk-fieldset__heading'
    )
    const hasProfileRadioLabel = form.querySelector(
      '#edition_role_appointment label[for="edition_role_appointment_speaker_on_govuk"]'
    )
    const noProfileRadioLabel = form.querySelector(
      '#edition_role_appointment label[for="edition_role_appointment_speaker_not_on_govuk"]'
    )
    const deliveredOnLabel = form.querySelector(
      '#edition_delivered_on .govuk-fieldset__legend'
    )
    const locationDiv = form.querySelector(
      '.js-app-view-edit-edition__speech-location-field'
    )
    const locationInput = locationDiv.querySelector(
      'input[name="edition[location]"]'
    )
    const authoredArticleId = '6'

    select.addEventListener('change', function (event) {
      if (event.currentTarget.value === authoredArticleId) {
        locationDiv.classList.add(
          'app-view-edit-edition__speech-location--hidden'
        )
        deliveredByLabel.textContent = 'Writer (required)'
        hasProfileRadioLabel.textContent = 'Writer has a profile on GOV.UK'
        noProfileRadioLabel.textContent =
          'Writer does not have a profile on GOV.UK'
        deliveredOnLabel.textContent = 'Written on'
        locationInput.value = ''
      } else {
        locationDiv.classList.remove(
          'app-view-edit-edition__speech-location--hidden'
        )
        deliveredByLabel.textContent = 'Speaker (required)'
        hasProfileRadioLabel.textContent = 'Speaker has a profile on GOV.UK'
        noProfileRadioLabel.textContent =
          'Speaker does not have a profile on GOV.UK'
        deliveredOnLabel.textContent = 'Delivered on'
      }
    })
  }

  EditionForm.prototype.setupSpeechDeliverdOnWarningEventListener =
    function () {
      const form = this.module
      const deliveredOnFieldset = form.querySelector('#edition_delivered_on')

      if (!deliveredOnFieldset) {
        return
      }

      const warningDiv = form.querySelector(
        '.js-app-view-edit-edition__delivered-on-warning'
      )
      const day = form.querySelector('#edition_delivered_on_3i')
      const month = form.querySelector('#edition_delivered_on_2i')
      const year = form.querySelector('#edition_delivered_on_1i')

      deliveredOnFieldset.querySelectorAll('input').forEach(function (input) {
        input.addEventListener('change', function () {
          const dateIsInvalid =
            day.value === '' || month.value === '' || year.value === ''

          if (dateIsInvalid) {
            if (
              !warningDiv.classList.contains(
                'app-view-edit-edition__delivered-on-warning--hidden'
              )
            ) {
              warningDiv.classList.add(
                'app-view-edit-edition__delivered-on-warning--hidden'
              )
            }
          } else {
            const date = new Date(year.value, month.value - 1, day.value)
            const currentDate = new Date()
            if (currentDate < date) {
              const dateFields = deliveredOnFieldset.querySelector(
                '.app-c-datetime-fields__date-time-wrapper'
              )
              dateFields.after(warningDiv)
              warningDiv.classList.remove(
                'app-view-edit-edition__delivered-on-warning--hidden'
              )
            } else if (
              !warningDiv.classList.contains(
                'app-view-edit-edition__delivered-on-warning--hidden'
              )
            ) {
              warningDiv.classList.add(
                'app-view-edit-edition__delivered-on-warning--hidden'
              )
            }
          }
        })
      })
    }

  Modules.EditionForm = EditionForm
})(window.GOVUK.Modules)
