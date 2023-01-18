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

    var select = form.querySelector('#edition_news_article_type_id')

    if (!select) { return }

    var container = form.querySelector('.app-view-edit-edition__locale-field')
    var localeCheckbox = container.querySelector('#edition_create_foreign_language_only-0')
    var localeSelect = container.querySelector('#edition_primary_locale')
    var newArticleTypeId = '4'

    select.addEventListener('change', function () {
      if (select.value !== newArticleTypeId) {
        container.classList.add('app-view-edit-edition__locale-field--hidden')
        localeCheckbox.value = '0'
        localeCheckbox.checked = false
        localeSelect.value = ''
      } else {
        container.classList.remove('app-view-edit-edition__locale-field--hidden')
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
        deliveredOnLabel.textContent = 'Written on (required)'
        locationInput.value = ''
      } else {
        locationDiv.classList.remove('app-view-edit-edition__speech-location--hidden')
        deliveredByLabel.textContent = 'Speaker (required)'
        hasProfileRadioLabel.textContent = 'Speaker has a profile on GOV.UK'
        noProfileRadioLabel.textContent = 'Speaker does not have a profile on GOV.UK'
        deliveredOnLabel.textContent = 'Delivered on (required)'
      }
    })
  }

  Modules.EditionForm = EditionForm
})(window.GOVUK.Modules)
