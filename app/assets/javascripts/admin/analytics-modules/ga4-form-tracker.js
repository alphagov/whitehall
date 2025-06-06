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

  // Ga4FormTracker does not track form changes
  // so we need to define an extra function
  Ga4FormTracker.prototype.trackFormChange = function (event) {
    const trackableForm =
      window.GOVUK.analyticsGa4.core.trackFunctions.findTrackingAttributes(
        event.target,
        this.trackingTrigger
      )

    if (!trackableForm) return

    const target = event.target
    const type = target.type

    if (type === 'search') return

    const name = target.name

    const fieldset = target.closest('fieldset')

    const sectionLabel = fieldset
      ? fieldset.querySelector('legend')
      : trackableForm.querySelector(`label[for='${target.id}']`)

    const index = this.getJson(target, 'data-ga4-index')

    let section

    if (sectionLabel) {
      section = sectionLabel.innerText
    } else {
      const sectionContainer = trackableForm.closest('[data-ga4-section]')

      section = sectionContainer.dataset.ga4Section
    }

    const text = (event.detail && event.detail.value) || target.value

    const isTextInput = type === 'text' || target.tagName === 'TEXTAREA'
    const isDateComponent = target.closest('.govuk-date-input')

    const checkedAction = trackableForm.querySelector(
      `[name="${name}"] [value="${text}"]:checked, [name="${name}"][value="${text}"]:checked`
    )
      ? 'select'
      : 'remove'

    const schema = {
      ...index,
      section,
      event_name: 'select_content',
      action: isTextInput ? 'select' : checkedAction,
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

    if (!isTextInput) {
      const labelText =
        target.querySelector(`option[value="${text}"]`) ||
        document.querySelector(`label[for='${target.id}']`)

      schema.text = labelText.innerText
    }

    window.GOVUK.analyticsGa4.core.applySchemaAndSendData(schema, 'event_data')
  }

  // we need to override the default `startModule`
  // to add a listener to track changes to the form
  Ga4FormTracker.prototype.startModule = function () {
    this.module.addEventListener('submit', this.trackFormSubmit.bind(this))
    this.module.addEventListener('change', this.trackFormChange.bind(this))
  }
})(window.GOVUK.Modules.Ga4FormTracker)
