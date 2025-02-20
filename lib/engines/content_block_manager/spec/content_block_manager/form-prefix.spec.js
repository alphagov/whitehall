'use strict'
window.GOVUK = window.GOVUK || {}
window.GOVUK.Modules = window.GOVUK.Modules || {}

describe('GOVUK.Modules.FormPrefix', function () {
  let prefix, fixture, formPrefix, form

  beforeEach(function () {
    prefix = '£'
    fixture = document.createElement('input')
    fixture.setAttribute('type', 'text')
    fixture.setAttribute('data-prefix', prefix)
    fixture.setAttribute('data-module', 'form-prefix')
    fixture.setAttribute('name', 'amount')
    fixture.setAttribute('value', '£1234')

    form = document.createElement('form')
    form.appendChild(fixture)

    document.body.append(form)

    formPrefix = new GOVUK.Modules.FormPrefix(fixture)
    formPrefix.init()
  })

  afterEach(function () {
    form.innerHTML = ''
  })

  it('should add a prefix element', function () {
    const wrapper = document.querySelector('.govuk-input__wrapper')
    expect(wrapper).toBeTruthy()

    const prefixElement = wrapper.querySelector('.govuk-input__prefix')
    expect(prefixElement).toBeTruthy()
    expect(prefixElement.textContent).toBe(prefix)
  })

  it('should remove the prefix from the input', function () {
    expect(fixture.value).toBe('1234')
  })

  it('should add the prefix back to the element on submit', function () {
    form.addEventListener('submit', function (e) {
      expect(fixture.value).toBe('£1234')
      e.preventDefault()
    })
    form.dispatchEvent(new Event('submit', { cancelable: true }))
  })
})
