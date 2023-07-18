window.GOVUK = window.GOVUK || {}
window.GOVUK.Modules = window.GOVUK.Modules || {};

(function (Modules) {
  function EditionForm (module) {
    this.module = module
  }

  EditionForm.prototype.init = function () {
    this.setupSubtypeFormatAdviceEventListener()
    this.setupWorldNewsStoryVisibilityToggle()
    this.setupSpeechSubtypeEventListeners()
    this.setupSpeechDeliverdOnWarningEventListener()
  }

  EditionForm.prototype.setupSubtypeFormatAdviceEventListener = function () {
    var form = this.module
    var subtypeDiv = form.querySelector('.js-app-view-edition-form__subtype-fields')

    if (!subtypeDiv) { return }

    var subtypeSelect = subtypeDiv.querySelector('select')

    subtypeSelect.addEventListener('change', function () {
      var formatAdviceMap = JSON.parse(subtypeDiv.dataset.formatAdvice)
      var subtypeFormatAdvice = form.querySelector('.js-app-view-edition-form__subtype-format-advice')

      if (subtypeFormatAdvice) {
        subtypeDiv.removeChild(subtypeFormatAdvice)
      }

      var adviceText = formatAdviceMap[subtypeSelect.value]

      if (adviceText) {
        var div = document.createElement('div')
        div.classList.add('js-app-view-edition-form__subtype-format-advice', 'govuk-body', 'govuk-!-margin-top-4')
        div.innerHTML = '<strong>Use this subformat for…</strong> ' + adviceText
        subtypeDiv.append(div)
      }
    })
  }

  EditionForm.prototype.setupWorldNewsStoryVisibilityToggle = function () {
    var form = this.module

    var subtypeSelect = form.querySelector('#edition_news_article_type_id')

    if (!subtypeSelect) { return }

    var localeDiv = form.querySelector('.app-view-edit-edition__locale-field')
    var localeCheckbox = localeDiv.querySelector('#edition_create_foreign_language_only-0')
    var localeSelect = localeDiv.querySelector('#edition_primary_locale')
    var worldNewsArticleTypeId = '4'
    var ministersDiv = form.querySelector('.app-view-edit-edition__appointment-fields')
    var organisationsDiv = form.querySelector('.app-view-edit-edition__organisation-fields')
    var worldOrganisationDiv = form.querySelector('.app-view-edit-edition__world-organisation-fields')

    if (subtypeSelect.value === worldNewsArticleTypeId) {
      ministersDiv.classList.add('app-view-edit-edition__appointment-fields--hidden')
      organisationsDiv.classList.add('app-view-edit-edition__organisation-fields--hidden')
      organisationsDiv.querySelectorAll('select').forEach(function (select) {
        select.value = ''
      })
    } else {
      worldOrganisationDiv.classList.add('app-view-edit-edition__world-organisation-fields--hidden')
    }

    subtypeSelect.addEventListener('change', function () {
      if (subtypeSelect.value !== worldNewsArticleTypeId) {
        localeDiv.classList.add('app-view-edit-edition__locale-field--hidden')
        localeCheckbox.value = '0'
        localeCheckbox.checked = false
        localeSelect.value = ''
        ministersDiv.classList.remove('app-view-edit-edition__appointment-fields--hidden')
        organisationsDiv.classList.remove('app-view-edit-edition__organisation-fields--hidden')
        worldOrganisationDiv.classList.add('app-view-edit-edition__world-organisation-fields--hidden')
        worldOrganisationDiv.querySelector('select').value = ''
      } else {
        localeDiv.classList.remove('app-view-edit-edition__locale-field--hidden')
        worldOrganisationDiv.classList.remove('app-view-edit-edition__world-organisation-fields--hidden')

        ministersDiv.classList.add('app-view-edit-edition__appointment-fields--hidden')
        ministersDiv.querySelector('select').value = ''

        organisationsDiv.classList.add('app-view-edit-edition__organisation-fields--hidden')
        organisationsDiv.querySelectorAll('select').forEach(function (select) {
          select.value = ''
        })
      }
    })
  }

  EditionForm.prototype.setupSpeechSubtypeEventListeners = function () {
    var form = this.module

    var select = form.querySelector('#edition_speech_type_id')

    if (!select) { return }

    var deliveredByLabel = form.querySelector('#edition_role_appointment .govuk-fieldset__heading')
    var hasProfileRadioLabel = form.querySelector('#edition_role_appointment label[for="edition_role_appointment_speaker_on_govuk"]')
    var noProfileRadioLabel = form.querySelector('#edition_role_appointment label[for="edition_role_appointment_speaker_not_on_govuk"]')
    var deliveredOnLabel = form.querySelector('#edition_delivered_on .govuk-fieldset__legend')
    var locationDiv = form.querySelector('.js-app-view-edit-edition__speech-location-field')
    var locationInput = locationDiv.querySelector('input[name="edition[location]"]')
    var authoredArticleId = '6'

    select.addEventListener('change', function (event) {
      if (event.currentTarget.value === authoredArticleId) {
        locationDiv.classList.add('app-view-edit-edition__speech-location--hidden')
        deliveredByLabel.textContent = 'Writer (required)'
        hasProfileRadioLabel.textContent = 'Writer has a profile on GOV.UK'
        noProfileRadioLabel.textContent = 'Writer does not have a profile on GOV.UK'
        deliveredOnLabel.textContent = 'Written on'
        locationInput.value = ''
      } else {
        locationDiv.classList.remove('app-view-edit-edition__speech-location--hidden')
        deliveredByLabel.textContent = 'Speaker (required)'
        hasProfileRadioLabel.textContent = 'Speaker has a profile on GOV.UK'
        noProfileRadioLabel.textContent = 'Speaker does not have a profile on GOV.UK'
        deliveredOnLabel.textContent = 'Delivered on'
      }
    })
  }

  EditionForm.prototype.setupSpeechDeliverdOnWarningEventListener = function () {
    var form = this.module
    var deliveredOnFieldset = form.querySelector('#edition_delivered_on')

    if (!deliveredOnFieldset) { return }

    var warningDiv = form.querySelector('.js-app-view-edit-edition__delivered-on-warning')
    var day = form.querySelector('#edition_delivered_on_3i')
    var month = form.querySelector('#edition_delivered_on_2i')
    var year = form.querySelector('#edition_delivered_on_1i')

    deliveredOnFieldset.querySelectorAll('select').forEach(function (select) {
      select.addEventListener('change', function () {
        var dateIsInvalid = day.value === '' || month.value === '' || year.value === ''

        if (dateIsInvalid) {
          if (!warningDiv.classList.contains('app-view-edit-edition__delivered-on-warning--hidden')) {
            warningDiv.classList.add('app-view-edit-edition__delivered-on-warning--hidden')
          }
        } else {
          var date = new Date(year.value, month.value - 1, day.value)
          var currentDate = new Date()
          if (currentDate < date) {
            var dateFields = deliveredOnFieldset.querySelector('.app-c-datetime-fields__date-time-wrapper')
            dateFields.after(warningDiv)
            warningDiv.classList.remove('app-view-edit-edition__delivered-on-warning--hidden')
          } else if (!warningDiv.classList.contains('app-view-edit-edition__delivered-on-warning--hidden')) {
            warningDiv.classList.add('app-view-edit-edition__delivered-on-warning--hidden')
          }
        }
      })
    })
  }

  Modules.EditionForm = EditionForm
})(window.GOVUK.Modules)
