'use strict'
window.GOVUK = window.GOVUK || {}
window.GOVUK.Modules = window.GOVUK.Modules || {}
;(function (Modules) {
  const addAnotherFieldSet = (options) => {
    const { legend, label } = options
    const el = document.createElement('div')
    el.innerHTML = `
      <fieldset>
      <legend>${legend}</legend>
      <label for="text-input">${label}</label>
      <input id="text-input" name="text-input" type="text">
      </fieldset>
    `
    return el
  }

  const date = (options) => {
    const { legend } = options
    const el = document.createElement('div')
    el.innerHTML = `
      <fieldset class="govuk-date-input">
      <legend>${legend}</legend>
      <div class="govuk-date-input__item">
        <div class="govuk-form-group">
          <label for="day" class="gem-c-label govuk-label">Day</label>
          <input class="gem-c-input govuk-input govuk-input--width-4" id="day" name="day" type="text">
        </div>
      </div>
      <div class="govuk-date-input__item">
        <div class="govuk-form-group">
          <label for="month" class="gem-c-label govuk-label">Month</label>
          <input class="gem-c-input govuk-input govuk-input--width-4" name="month" id="month" type="text">
        </div>
      </div>
      <div class="govuk-date-input__item">
        <div class="govuk-form-group">
          <label for="year" class="gem-c-label govuk-label">Year</label>
          <input class="gem-c-input govuk-input govuk-input--width-4" name="year" id="year" type="text">
        </div>
      </div>
      </fieldset>
    `
    return el
  }

  const checkbox = (options) => {
    const { legend, value } = options
    const el = document.createElement('div')
    el.innerHTML = `
      <fieldset>
        <legend>${legend}</legend>
        <div>
          <div>
            <input type="checkbox" name="favourite_colour[]" id="checkboxes" value="1" class="govuk-checkboxes__input">
            <label for="checkboxes" class="govuk-label govuk-checkboxes__label">${value}</label>
          </div>
        </div>
      </fieldset>
    `
    return el
  }

  const text = (options) => {
    const { label } = options
    const el = document.createElement('div')
    el.innerHTML = `
      <label for="text-input">${label}</label>
      <input id="text-input" name="text-input" type="text">
    `
    return el
  }

  const textarea = (options) => {
    const { label } = options
    const el = document.createElement('div')
    el.innerHTML = `
      <label for="text-area">${label}</label>
      <textarea id="text-area" name="text-area">
    `
    return el
  }

  const radio = (options) => {
    const { legend, value } = options
    const el = document.createElement('div')
    el.innerHTML = `
      <fieldset class="govuk-fieldset">
        <legend>${legend}</legend>
        <div class="govuk-radios">
            <input type="radio" name="radio-group" id="radio" value="1">
            <label for="radio">${value}</label>
        </div>
      </fieldset>
    `
    return el
  }

  const select = (options, name = 'select') => {
    const { label, option } = options
    const el = document.createElement('div')
    el.innerHTML = `
      <label class="govuk-label" for="${name}">${label}</label>
      <select name="${name}" id="${name}">
        <option value="1">Red</option>
        <option value="2">${option}</option>
      </select>
    `
    return el
  }

  const selectMultiple = (options) => {
    const el = select(options, 'select-multiple')
    el.querySelector('select').setAttribute('multiple', true)
    return el
  }

  const formInputs = {
    date,
    checkbox,
    text,
    textarea,
    radio,
    select,
    'select-multiple': selectMultiple,
    addAnotherFieldSet
  }

  class Form {
    form

    static formDefaultOptions = {
      label: 'What is your favourite colour?',
      option: 'Blue',
      legend: 'What is your favourite colour?',
      value: 'Blue'
    }

    constructor(inputs, options = Form.formDefaultOptions) {
      this.options = options
      this.inputs = inputs || Object.keys(formInputs)
      this.form = this.createForm(...this.inputs)

      return new Proxy(this, {
        get(target, prop) {
          if (Reflect.has(...arguments)) return Reflect.get(...arguments)

          if (typeof target.form[prop] === 'function')
            return (...args) => target.form[prop](...args)

          return target.form[prop]
        }
      })
    }

    createForm = (...inputs) => {
      const form = document.createElement('form')

      document.createElement('div')
      ;(inputs.length ? inputs : Object.keys(formInputs)).forEach((input) => {
        const newInput = document.createElement('div')

        newInput.innerHTML = formInputs[input](this.options).innerHTML
        form.appendChild(newInput)
      })

      const submitButton = document.createElement('button')
      submitButton.type = 'submit'
      submitButton.innerHTML = 'Save'

      form.appendChild(submitButton)

      return form
    }

    appendToParent = (el) => el.appendChild(this.form)

    submit = (element) => {
      element && element.focus()

      this.form.dispatchEvent(new Event('submit'))
    }

    triggerChange = (selector) => {
      const field = this.form.querySelector(selector)

      if (field.tagName === 'SELECT') {
        field.querySelectorAll('option')[1].selected = true
        field.dispatchEvent(new Event('change', { bubbles: true }))
      } else {
        field.click()

        if (field.tagName === 'TEXTAREA' || field.type === 'text') {
          field.value = this.options.value
        }
        field.dispatchEvent(new Event('change', { bubbles: true }))
      }
    }
  }

  Modules.JasmineHelpers = {
    Form
  }
})(window.GOVUK.Modules)
