describe('GOVUK.analyticsGa4.analyticsModules.Ga4FormSetup', function () {
  let form, submitButton, expectedDefaults

  const Form = window.GOVUK.Modules.JasmineHelpers.Form

  let container

  const documentType = 'type-toolName'
  const section = 'section'
  const eventName = 'form_response'

  beforeEach(() => {
    container = document.createElement('div')

    container.dataset.module = 'ga4-form-setup'
    container.dataset.ga4DocumentType = documentType
    container.dataset.ga4Section = section

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
    it('adds the correct data attributes', () => {
      GOVUK.analyticsGa4.analyticsModules.Ga4FormSetup.init()

      const { ga4Form } = form.dataset

      const { ga4FormRecordJson, ga4FormIncludeText, ga4FormUseTextCount } =
        container.dataset

      expect(ga4FormRecordJson).toBeDefined()
      expect(ga4FormIncludeText).toBeDefined()
      expect(ga4FormUseTextCount).toBeDefined()
      expect(ga4Form).toBeDefined()

      expect(JSON.parse(ga4Form)).toEqual(expectedDefaults)
    })

    it('uses new instead of create as action', () => {
      container.dataset.ga4DocumentType = 'create-toolName'

      GOVUK.analyticsGa4.analyticsModules.Ga4FormSetup.init()

      const { ga4Form } = form.dataset

      expect(ga4Form).toBeDefined()

      expect(JSON.parse(ga4Form)).toEqual({ ...expectedDefaults, type: 'new' })
    })

    it('adds the `data-ga4-form-change-tracking` attribute if no tracked components', () => {
      GOVUK.analyticsGa4.analyticsModules.Ga4FormSetup.init()

      const ga4FormChangeTracking = form.dataset.ga4FormChangeTracking

      expect(ga4FormChangeTracking).toBeDefined()
    })

    it('does not add the `data-ga4-form-change-tracking` attribute if tracked components', () => {
      const trackedComponent =
        GOVUK.analyticsGa4.analyticsModules.Ga4FormSetup.trackedComponents[0]

      form.querySelector('input').dataset.module = `${trackedComponent}`

      GOVUK.analyticsGa4.analyticsModules.Ga4FormSetup.init()

      const ga4FormChangeTracking = form.dataset.ga4FormChangeTracking

      expect(ga4FormChangeTracking).not.toBeDefined()
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

      expect(form.dataset.ga4Form).not.toBeDefined()
    })

    it('does not add the `data-ga4-form` attribute on submit', () => {
      GOVUK.analyticsGa4.analyticsModules.Ga4FormSetup.init()

      form.submit(submitButton)

      expect(form.dataset.ga4Form).not.toBeDefined()
    })
  })

  afterEach(() => {
    form.remove()
  })

  afterAll(() => {
    container.remove()
  })
})
