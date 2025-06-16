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

  Ga4FormTracker.prototype.parentDateComponent = function (target) {
    return target.closest('.govuk-date-input')
  }

  Ga4FormTracker.prototype.getSection = function (target, checkableValue) {
    const { id } = target
    const form =
      window.GOVUK.analyticsGa4.core.trackFunctions.findTrackingAttributes(
        event.target,
        this.trackingTrigger
      )
    const fieldset = target.closest('fieldset')
    const sectionContainer = form.closest('[data-ga4-section]')
    const label = form.querySelector(`label[for='${id}']`)
    const parentDateComponent = this.parentDateComponent(target)

    let section = sectionContainer && sectionContainer.dataset.ga4Section

    if (fieldset) {
      const legend = fieldset.querySelector('legend')

      // the date component submits several inputs as one
      // event, so we don't want to include the label of
      // the last interacted with input in the section
      if (checkableValue || parentDateComponent) {
        section = legend ? legend.innerText : section
      } else {
        section =
          legend && label ? `${legend.innerText} - ${label.innerText}` : section
      }
    } else {
      section = label ? label.innerText : section
    }

    return section
  }

  Ga4FormTracker.prototype.handleDateComponent = function (target) {
    const isDateComponent = target.closest('.govuk-date-input')

    if (!isDateComponent) return target.value

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
    const { type, name, id } = target

    if (type === 'search') return

    const index = this.getJson(target, 'data-ga4-index')
    const value = (event.detail && event.detail.value) || target.value

    // a radio or check input with a `name` and `value`
    // or an option of `value` within a `select` with `name`
    const checkableValue = form.querySelector(
      `[name="${name}"][value="${value}"], [name="${name}"] [value="${value}"]`
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
        text = form.querySelector(`label[for='${id}']`).innerText
      }
    } else if (!text) {
      // it's a free form text field
      text = this.handleDateComponent(target)

      if (!text) return
    }

    window.GOVUK.analyticsGa4.core.applySchemaAndSendData(
      {
        ...index,
        section: this.getSection(target, checkableValue),
        event_name: 'select_content',
        action,
        text
      },
      'event_data'
    )
  }

  // we need to override the default `startModule`
  // to add a listener to track changes to the form
  Ga4FormTracker.prototype.startModule = function () {
    this.module.addEventListener('change', this.trackFormChange.bind(this))

    this.module.addEventListener('submit', this.trackFormSubmit.bind(this))
  }
})(window.GOVUK.Modules.Ga4FormTracker)
