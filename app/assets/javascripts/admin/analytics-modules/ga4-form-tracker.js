'use strict'
window.GOVUK = window.GOVUK || {}
window.GOVUK.Modules = window.GOVUK.Modules || {}
window.GOVUK.Modules.Ga4FormTracker = window.GOVUK.Modules.Ga4FormTracker || {}
;(function (Ga4FormTracker) {
  // extra utility function for parsing
  // JSON string data attributes (convention
  // of the components library tracking)
  Ga4FormTracker.prototype.getJson = function (target, attribute) {
    let dataContainer
    let data

    try {
      dataContainer = target.closest(`[${attribute}]`)
      data = dataContainer.getAttribute(attribute)
      return JSON.parse(data)
    } catch (e) {
      console.error(
        `GA4 configuration error: ${e.message}, attempt to access ${attribute} on ${target}`,
        window.location
      )
    }
  }

  Ga4FormTracker.prototype.dateTimeComponent = function (target) {
    return (
      target.closest('.app-c-datetime-fields') ||
      target.closest('.govuk-date-input')
    )
  }

  Ga4FormTracker.prototype.getSection = function (target, checkableValue) {
    const { id } = target
    const form =
      window.GOVUK.analyticsGa4.core.trackFunctions.findTrackingAttributes(
        event.target,
        this.trackingTrigger
      )
    const fieldset = target.closest('fieldset')
    const legend = fieldset && fieldset.querySelector('legend')
    const sectionContainer = form.closest('[data-ga4-section]')
    const label = form.querySelector(`label[for='${CSS.escape(id)}']`)
    const dateTimeComponent = this.dateTimeComponent(target)

    let section = sectionContainer && sectionContainer.dataset.ga4Section

    if (legend && (checkableValue || dateTimeComponent)) {
      section = legend ? legend.innerText : section

      if (dateTimeComponent) {
        // this is an intermediary measure!! need to rework the legends
        // for all datetime fields so they are more descriptive as
        // nested legends have inconsistent screenreader behaviour
        // this work can happen as part of moving datetime out of whitehall
        const dateTimeFieldset = dateTimeComponent.closest('fieldset')
        if (dateTimeFieldset) {
          const dateTimeLegend = dateTimeFieldset.querySelector('legend')
          if (dateTimeLegend && dateTimeLegend.innerText !== section) {
            section = `${dateTimeLegend.innerText} - ${section}`
          }
        }
      }
    } else {
      section = label ? label.innerText : section
    }

    return section
  }

  Ga4FormTracker.prototype.handleDateComponent = function (target) {
    const isDateComponent = target.closest('.govuk-date-input')
    const value = target.value

    if (!isDateComponent)
      return typeof value === 'string' ? value.replace(/[\n\r]/g, ' ') : value

    // only track if completely filled in
    const inputs = [
      ...target.closest('.govuk-date-input').querySelectorAll('input')
    ]
    const allInputsSet = inputs.every((input) => input.value)

    if (allInputsSet) {
      return inputs.map((input) => input.value).join('/')
    }
  }

  // Ga4FormTracker does not track form changes
  // so we need to define an extra function
  Ga4FormTracker.prototype.trackFormChange = function (event) {
    const form =
      window.GOVUK.analyticsGa4.core.trackFunctions.findTrackingAttributes(
        event.target,
        this.trackingTrigger
      )

    if (!form) return

    if (!form.hasAttribute('data-ga4-form-change-tracking')) return

    const target = event.target
    const { type, id } = target

    if (type === 'search') return

    const index = this.getJson(target, 'data-ga4-index')
    const value = (event.detail && event.detail.value) || target.value

    // a radio or check input with a `name` and `value`
    // or an option of `value` within a `select` with `name`
    const checkableValue = form.querySelector(
      `#${CSS.escape(id)}[value="${CSS.escape(value)}"], #${CSS.escape(id)} [value="${CSS.escape(value)}"]`
    )

    let action = 'select'
    let text

    if (checkableValue) {
      // radio, check, option can have `:checked` pseudo-class
      if (!checkableValue.matches(':checked')) {
        action = 'remove'
      }

      text = checkableValue.innerText

      if (!text) {
        // it's not an option so has no innerText
        text = form.querySelector(`label[for='${CSS.escape(id)}']`).innerText
      }
    } else if (!text) {
      // it's a free form text field
      text = this.handleDateComponent(target)

      if (!text) return
    }

    window.GOVUK.analyticsGa4.core.applySchemaAndSendData(
      {
        ...index,
        section: this.getSection(
          target,
          checkableValue && checkableValue.matches(':not(option)')
        ),
        event_name: 'select_content',
        action,
        text: text.replace(/\r?\n|\r/g, '')
      },
      'event_data'
    )
  }

  Ga4FormTracker.prototype.trackFormSubmit = function (event) {
    var target = window.GOVUK.analyticsGa4.core.trackFunctions.findTrackingAttributes(event.target, this.trackingTrigger)
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
      data.text = data.text || this.combineGivenAnswers(formData) || this.useFallbackValue

      if (data.action === 'search' && data.text) {
        data.text = window.GOVUK.analyticsGa4.core.trackFunctions.standardiseSearchTerm(data.text)
      }

      if (data.text && this.splitText) {
        data = this.splitFormResponseText(data)
      }

      window.GOVUK.analyticsGa4.core.applySchemaAndSendData(data, 'event_data')
    }
  }

  Ga4FormTracker.prototype.splitFormResponseText = function (data) {
    var text = data.text
    var dimensions = Math.min(Math.ceil(data.text.length / 500), 5)

    data.text = text.slice(0, 500)

    for (var i = 1; i < dimensions; i++) {
      data['text_' + (i + 1)] = text.slice(i * 500, i * 500 + 500)
    }

    return data
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

      input.section = labelText.replace(/\r?\n|\r/g, '')

      var isTextField = inputTypes.indexOf(inputType) !== -1 || inputNodename === 'TEXTAREA'
      var conditionalField = elem.closest('.govuk-checkboxes__conditional')
      var conditionalCheckbox = conditionalField && this.module.querySelector('[aria-controls="' + conditionalField.id + '"]')
      var conditionalCheckboxChecked = conditionalCheckbox && conditionalCheckbox.checked

      var isDateField = elem.closest('.govuk-date-input')

      if (conditionalCheckbox && !conditionalCheckboxChecked) {
        // don't include conditional field if condition not checked
        inputs.splice(i, 1)
      } else if (conditionalField && elem.hasAttribute('aria-controls')) {
        // don't include conditional field control in text
        inputs.splice(i, 1)
      } else if (elem.checked) {
        input.answer = labelText

        var fieldset = elem.closest('fieldset')

        if (fieldset) {
          var legend = fieldset.querySelector('legend')

          if (legend) {
            input.section = legend.innerText
          }
        }
      } else if (inputNodename === 'SELECT' && elem.querySelectorAll('option:checked')) {
        var selectedOptions = Array.from(elem.querySelectorAll('option:checked')).map(function (element) { return element.text })

        if (selectedOptions.length === 1 && !elem.value.length) {
          // if placeholder value in select, do not include as not filled in
          inputs.splice(i, 1)
        } else {
          input.answer = this.useSelectCount && selectedOptions.length > 1 ? selectedOptions.length : selectedOptions.join(',')
        }
      } else if (isTextField && elem.value) {
        if (this.includeTextInputValues || elem.hasAttribute('data-ga4-form-include-input')) {
          if (this.useTextCount && !isDateField) {
            input.answer = elem.value.length
          } else {
            var PIIRemover = new window.GOVUK.analyticsGa4.PIIRemover()
            input.answer = PIIRemover.stripPIIWithOverride(elem.value, true, true)
          }
        } else {
          // if recording JSON and text input not allowed
          // set the specific answer to '[REDACTED]'
          if (this.recordJson) {
            input.answer = '[REDACTED]'
          } else {
            this.redacted = true
          }
        }
      } else {
        // remove the input from those gathered as it has no value
        inputs.splice(i, 1)
      }

      var parentFieldset
      var parentLegend

      if (conditionalField && conditionalCheckboxChecked) {
        parentFieldset = conditionalField.closest('fieldset')
        parentLegend = parentFieldset && parentFieldset.querySelector('legend')

        if (parentLegend) {
          input.section = parentLegend.innerText + ' - ' + input.section
        }
      } else if (isDateField) {
        var dateFieldset = elem.closest('.govuk-date-input').closest('fieldset')
        var dateLegend = dateFieldset && dateFieldset.querySelector('legend')

        parentFieldset = dateFieldset.parentNode.closest('fieldset')

        if (dateLegend) {
          input.section = dateLegend.innerText + ' - ' + input.section
        }

        if (parentFieldset) {
          parentLegend = parentFieldset.querySelector('legend')
          input.section = parentLegend.innerText + ' - ' + input.section
        }
      }
    }
    return inputs
  }  

  // we need to override the default `startModule`
  // to add a listener to track changes to the form
  Ga4FormTracker.prototype.startModule = function () {
    this.module.addEventListener('change', this.trackFormChange.bind(this))

    this.module.addEventListener('submit', this.trackFormSubmit.bind(this))
  }
})(window.GOVUK.Modules.Ga4FormTracker)
