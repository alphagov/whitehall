//= require admin/stop-scripts-nomodule

//= require govuk_publishing_components/dependencies
//= require govuk_publishing_components/analytics-ga4
//= require govuk_publishing_components/components/accordion
//= require govuk_publishing_components/components/add-another
//= require govuk_publishing_components/components/copy-to-clipboard
//= require govuk_publishing_components/components/govspeak
//= require govuk_publishing_components/components/reorderable-list
//= require govuk_publishing_components/components/table
//= require govuk_publishing_components/lib/trigger-event
//= require govuk_publishing_components/lib/cookie-functions

//= require components/govspeak-editor
//= require components/image-cropper
//= require components/miller-columns
//= require components/select-with-search

//= require admin/analytics-modules/ga4-index-section-setup.js
//= require admin/analytics-modules/ga4-button-setup.js
//= require admin/analytics-modules/ga4-link-setup.js
//= require admin/analytics-modules/ga4-search-results-setup.js
//= require admin/analytics-modules/ga4-visual-editor-event-handlers.js
//= require admin/analytics-modules/ga4-page-view-tracking.js
//= require admin/analytics-modules/ga4-paste-tracker.js
//= require admin/analytics-modules/ga4-select-with-search-tracker.js
//= require admin/analytics-modules/ga4-select-tracker.js
//= require admin/analytics-modules/ga4-search-setup.js
//= require admin/analytics-modules/ga4-form-setup.js

//= require admin/modules/document-history-paginator
//= require admin/modules/locale-switcher
//= require admin/modules/navbar-toggle
//= require admin/modules/paste-html-to-govspeak
//= require admin/modules/prevent-multiple-form-submissions

//= require admin/views/broken-links-report
//= require admin/views/edition-form
//= require admin/views/organisation-form
//= require admin/views/unpublish-display-conditions

//= require content_block_manager/application

'use strict'
window.GOVUK.approveAllCookieTypes()
window.GOVUK.cookie('cookies_preferences_set', 'true', { days: 365 })

window.GOVUK = window.GOVUK || {}
window.GOVUK.Modules = window.GOVUK.Modules || {}
;(function (Modules) {
  'use strict'

  function Ga4FormTracker(module) {
    this.module = module
    this.trackingTrigger = 'data-ga4-form' // elements with this attribute get tracked
    this.includeTextInputValues = this.module.hasAttribute(
      'data-ga4-form-include-text'
    )
    this.redacted = false
    this.useFallbackValue = this.module.hasAttribute(
      'data-ga4-form-no-answer-undefined'
    )
      ? undefined
      : 'No answer given'
  }

  Ga4FormTracker.prototype.init = function () {
    var consentCookie = window.GOVUK.getConsentCookie()

    console.log('my version')

    if (consentCookie && consentCookie.usage) {
      this.startModule()
    } else {
      this.start = this.startModule.bind(this)
      window.addEventListener('cookie-consent', this.start)
    }
  }

  // triggered by cookie-consent event, which happens when users consent to cookies
  Ga4FormTracker.prototype.startModule = function () {
    if (window.dataLayer) {
      window.removeEventListener('cookie-consent', this.start)
      this.module.addEventListener('submit', this.trackFormSubmit.bind(this))
    }
  }

  Ga4FormTracker.prototype.trackFormSubmit = function (event) {
    var target =
      window.GOVUK.analyticsGa4.core.trackFunctions.findTrackingAttributes(
        event.target,
        this.trackingTrigger
      )
    if (target) {
      try {
        var data = target.getAttribute(this.trackingTrigger)
        data = JSON.parse(data)
      } catch (e) {
        // if there's a problem with the config, don't start the tracker
        console.warn('GA4 configuration error: ' + e.message, window.location)
        return
      }

      var formInputs = this.getFormInputs()
      var formData = this.getInputValues(formInputs)

      data.text =
        data.text || this.combineGivenAnswers(formData) || this.useFallbackValue

      if (data.action === 'search' && data.text) {
        data.text =
          window.GOVUK.analyticsGa4.core.trackFunctions.standardiseSearchTerm(
            data.text
          )
      }

      window.GOVUK.analyticsGa4.core.applySchemaAndSendData(data, 'event_data')
    }
  }

  Ga4FormTracker.prototype.getFormInputs = function () {
    var inputs = []
    var labels = this.module.querySelectorAll('label')

    for (var i = 0; i < labels.length; i++) {
      var label = labels[i]
      var labelFor = label.getAttribute('for')
      var input = false
      if (labelFor) {
        input = this.module.querySelector('[id=' + labelFor + ']')
      } else {
        input = label.querySelector('input')
      }
      inputs.push({
        input: input,
        label: label
      })
    }
    return inputs
  }

  Ga4FormTracker.prototype.getInputValues = function (inputs) {
    for (var i = inputs.length - 1; i >= 0; i--) {
      var input = inputs[i]
      var elem = input.input
      var labelText = input.label.innerText || input.label.textContent
      var inputType = elem.getAttribute('type')
      var inputNodename = elem.nodeName
      var inputTypes = ['text', 'search', 'email', 'number']

      if (inputType === 'checkbox' && elem.checked) {
        input.answer = labelText
      } else if (
        inputNodename === 'SELECT' &&
        elem.options[elem.selectedIndex] &&
        elem.options[elem.selectedIndex].value
      ) {
        input.answer = elem.options[elem.selectedIndex].text
      } else if (inputTypes.indexOf(inputType) !== -1 && elem.value) {
        if (
          this.includeTextInputValues ||
          elem.hasAttribute('data-ga4-form-include-input')
        ) {
          var PIIRemover = new window.GOVUK.analyticsGa4.PIIRemover()
          input.answer = PIIRemover.stripPIIWithOverride(elem.value, true, true)
        } else {
          this.redacted = true
        }
      } else if (inputType === 'radio' && elem.checked) {
        input.answer = labelText
      } else {
        // remove the input from those gathered as it has no value
        inputs.splice(i, 1)
      }
    }
    return inputs
  }

  Ga4FormTracker.prototype.combineGivenAnswers = function (data) {
    var answers = []
    for (var i = 0; i < data.length; i++) {
      var answer = data[i].answer
      if (answer) {
        answers.push(answer)
      }
    }
    if (this.redacted) {
      answers.push('[REDACTED]')
    }

    answers = answers.join(',')
    return answers
  }

  Modules.Ga4FormTracker = Ga4FormTracker
})(window.GOVUK.Modules)
