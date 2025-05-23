'use strict'
window.GOVUK = window.GOVUK || {}
window.GOVUK.Modules = window.GOVUK.Modules || {}
window.GOVUK.Modules.Ga4FormTracker = window.GOVUK.Modules.Ga4FormTracker || {}
;(function (Ga4FormTracker) {
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

  Ga4FormTracker.prototype.trackFormChange = function (event) {
    const trackableForm =
      window.GOVUK.analyticsGa4.core.trackFunctions.findTrackingAttributes(
        event.target,
        this.trackingTrigger
      )

    if (!trackableForm) return

    const target = event.target

    if (target.type === 'search') return

    const fieldset = target.closest('fieldset')

    const sectionElement = fieldset
      ? fieldset.querySelector('legend')
      : document.querySelector(`label[for='${target.id}']`)

    const index = this.getJson(target, 'data-ga4-index')
    const formData = this.getJson(target, 'data-ga4-form')

    const section = sectionElement.innerText
    const text = (event.detail && event.detail.value) || target.value

    const isTextInput = target.type === 'text' || target.tagName === 'TEXTAREA'
    const isDateComponent = target.closest('.govuk-date-input')

    const checkedAction = document.querySelector(
      `#${target.id} [value="${text}"]:checked`
    )
      ? 'select'
      : 'remove'
    const textAction = text ? 'select' : 'remove'

    const schema = {
      ...formData,
      ...index,
      section,
      event_name: 'select_content',
      action: (isTextInput && textAction) || checkedAction,
      text
    }

    if (isDateComponent) {
      // only track if completely filled in
      const inputs = [
        ...target.closest('.govuk-date-input').querySelectorAll('input')
      ]
      const allInputsSet = inputs.every((input) => input.value)

      if (!allInputsSet) return

      schema.text = inputs.map((input) => input.value).join('/')
    }

    schema.action = document.querySelector(
      `#${target.id} [value="${text}"]:checked`
    )
      ? 'select'
      : !isTextInput

    if (!isTextInput) {
      const labelText =
        target.querySelector(`option[value="${text}"]`) ||
        document.querySelector(`label[for='${target.id}']`)

      schema.text = labelText.textContent
    }

    if (target.type === 'radio' || target.type === 'checkbox') {
      schema.section = target
        .closest('fieldset')
        .querySelector('legend').innerText
    }

    window.GOVUK.analyticsGa4.core.applySchemaAndSendData(schema, 'event_data')
  }

  Ga4FormTracker.prototype.startModule = function () {
    this.module.addEventListener('submit', this.trackFormSubmit.bind(this))
    this.module.addEventListener('change', this.trackFormChange.bind(this))
  }
})(window.GOVUK.Modules.Ga4FormTracker)
