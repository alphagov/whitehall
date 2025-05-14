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
    const trackableForm = window.GOVUK.analyticsGa4.core.trackFunctions.findTrackingAttributes(event.target, this.trackingTrigger)

    if (!trackableForm) return

    const target = event.target

    if (target.type === 'search') return

    const index = this.getJson(target, 'data-ga4-index')
    const formData = this.getJson(target, 'data-ga4-form')
    const section = document.querySelector(
      `label[for='${target.id}']`
    ).innerText

    const schema = {
      ...formData,
      ...index,
      section,
      event_name: 'select_content',
      action: target.value ? 'select' : 'remove',
      text:
        event.detail && event.detail.value && target.value
    }

    if (target.type !== 'text' && target.tagName !== 'TEXTAREA') {
      schema.action = target.querySelector(`[value="${schema.text}"]:checked`)
        ? 'select'
        : 'remove'
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
    }

    if (target.tagName === 'SELECT') {
      schema.text = target.querySelector(
        `option[value="${schema.text}"]`
      ).innerText
    }

    window.GOVUK.analyticsGa4.core.applySchemaAndSendData(schema, 'event_data')
  }

  Ga4FormTracker.prototype.startModule = function () {
    this.module.addEventListener('submit', this.trackFormSubmit.bind(this))
    this.module.addEventListener('change', this.trackFormChange.bind(this))
  }
})(window.GOVUK.Modules.Ga4FormTracker)
