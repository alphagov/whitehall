describe('GOVUK.analyticsGa4.analyticsModules.Ga4FormSetup', function () {
  let form, submitButton, expectedDefaults

  const Form = window.GOVUK.Modules.JasmineHelpers.Form

  const container = document.createElement('div')

  const documentType = 'type-toolName'
  const section = 'section'
  const eventName = 'form_response'

  container.dataset.module = 'ga4-form-setup'
  container.dataset.ga4DocumentType = documentType
  container.dataset.ga4Section = section

  beforeEach(() => {
    form = new Form()

    form.appendToParent(container)

    document.body.appendChild(container)

    submitButton = form.querySelector("[type='submit']")

    const [type, toolName] = documentType.split('-')

    expectedDefaults = {
      type,
      tool_name: toolName,
      section,
      event_name: eventName,
      action: submitButton.innerHTML
    }
  })

  describe('on a tracked form', () => {
    it('adds the `data-ga4-form` attribute', () => {
      GOVUK.analyticsGa4.analyticsModules.Ga4FormSetup.init()

      const ga4Form = form.dataset.ga4Form

      expect(ga4Form).toBeDefined()

      expect(JSON.parse(ga4Form)).toEqual(expectedDefaults)
    })

    it('updates the `data-ga4-form` attribute on submit', () => {
      const secondSubmitButton = submitButton.cloneNode()
      secondSubmitButton.innerHTML = 'Save and continue'
      form.appendChild(secondSubmitButton)

      GOVUK.analyticsGa4.analyticsModules.Ga4FormSetup.init()

      form.submit(submitButton)

      expect(JSON.parse(form.dataset.ga4Form)).toEqual({
        ...expectedDefaults,
        action: submitButton.innerHTML
      })

      form.submit(secondSubmitButton)

      expect(JSON.parse(form.dataset.ga4Form)).toEqual({
        ...expectedDefaults,
        action: secondSubmitButton.innerHTML
      })
    })
  })

  describe('on a untracked form', () => {
    beforeEach(() => {
      form.dataset.module = 'ga4-finder-tracker'
    })

    it('does not add the `data-ga4-form` attribute on init', () => {
      GOVUK.analyticsGa4.analyticsModules.Ga4FormSetup.init()

      const ga4Form = form.dataset.ga4Form

      expect(ga4Form).not.toBeDefined()
    })

    it('does not add the `data-ga4-form` attribute on submit', () => {
      GOVUK.analyticsGa4.analyticsModules.Ga4FormSetup.init()

      form.submit(submitButton)

      const ga4Form = form.dataset.ga4Form

      expect(ga4Form).not.toBeDefined()
    })
  })

  afterEach(() => {
    form.remove()
  })

  afterAll(() => {
    container.remove()
  })
})
