describe('GOVUK.analyticsGa4.analyticsModules.Ga4FormTracker', function () {
  let trackedInputs, mockGa4SendData, form

  const container = document.createElement('div')
  container.dataset.module = 'ga4-index-section-setup ga4-form-setup'

  const Form = window.GOVUK.Modules.JasmineHelpers.Form

  const expectedAttributes = {
    event_name: 'select_content',
    section: Form.formDefaultOptions.label,
    text: Form.formDefaultOptions.value
  }

  beforeAll(() => {
    document.body.appendChild(container)
  })

  describe('should fire correct event from a tracked form', () => {
    const createFormAndSetup = (container, ...fields) => {
      form = new Form(fields)

      form.appendToParent(container)

      GOVUK.analyticsGa4.analyticsModules.Ga4IndexSectionSetup.init()
      GOVUK.analyticsGa4.analyticsModules.Ga4FormSetup.init()
    }

    beforeAll(() => {
      mockGa4SendData = spyOn(
        window.GOVUK.analyticsGa4.core,
        'applySchemaAndSendData'
      )
    })

    beforeEach(() => {
      document.body.appendChild(container)
      mockGa4SendData.calls.reset()
    })

    it('when a standard input or select is selected and changed', () => {
      trackedInputs = ['radio', 'checkbox', 'text', 'textarea', 'select']

      createFormAndSetup(container, ...trackedInputs)

      trackedInputs.forEach((field) => {
        mockGa4SendData.calls.reset()

        const index = form
          .querySelector(`input[type="${field}"], ${field}`)
          .closest('[data-ga4-index]')

        form.triggerChange(`input[type="${field}"], ${field}`)

        expect(mockGa4SendData).toHaveBeenCalledWith(
          {
            ...expectedAttributes,
            ...JSON.parse(index.dataset.ga4Index),
            action: 'select'
          },
          'event_data'
        )
      })
    })

    it('when a labelled field within a fieldset is changed', () => {
      createFormAndSetup(container, 'addAnotherFieldSet')

      mockGa4SendData.calls.reset()

      const text = container.querySelector('input[type="text"]')
      const index = text.closest('[data-ga4-index]')

      form.triggerChange(`input`)

      expect(mockGa4SendData).toHaveBeenCalledWith(
        {
          ...expectedAttributes,
          section: `${Form.formDefaultOptions.legend} - ${Form.formDefaultOptions.label}`,
          ...JSON.parse(index.dataset.ga4Index),
          action: 'select'
        },
        'event_data'
      )
    })

    it('should track input with a value containing newlines', () => {
      createFormAndSetup(container, 'text')

      mockGa4SendData.calls.reset()

      const text = container.querySelector('input[type="text"]')
      const index = text.closest('[data-ga4-index]')

      text.value = `this is a value

        with a new line
      `
      text.dispatchEvent(new Event('change', { bubbles: true }))

      expect(mockGa4SendData).toHaveBeenCalledWith(
        {
          ...expectedAttributes,
          text: 'this is a value        with a new line      ',
          ...JSON.parse(index.dataset.ga4Index),
          action: 'select'
        },
        'event_data'
      )
    })

    it('when a checkbox is deselected', () => {
      createFormAndSetup(container, 'checkbox')

      const checkbox = container.querySelector('input[type="checkbox"]')
      const index = checkbox.closest('[data-ga4-index]')

      form.triggerChange(`input[type="checkbox"]`)

      mockGa4SendData.calls.reset()

      form.triggerChange(`input[type="checkbox"]`)

      expect(mockGa4SendData).toHaveBeenCalledWith(
        {
          ...expectedAttributes,
          ...JSON.parse(index.dataset.ga4Index),
          action: 'remove'
        },
        'event_data'
      )
    })

    describe('when the date component', () => {
      let inputs
      let index

      beforeEach(() => {
        createFormAndSetup(container, 'date')
        index = form.querySelector('[data-ga4-index]')

        inputs = form.querySelectorAll('input')
        inputs.forEach((input) =>
          form.triggerChange(`input[name="${input.name}"]`)
        )
      })

      it('is entirely filled in', () => {
        expect(mockGa4SendData).toHaveBeenCalledWith(
          {
            ...expectedAttributes,
            ...JSON.parse(index.dataset.ga4Index),
            action: 'select',
            text: Array(3).fill(expectedAttributes.text).join('/')
          },
          'event_data'
        )
      })

      it('is not entirely filled in', () => {
        mockGa4SendData.calls.reset()

        inputs[0].value = ''

        expect(mockGa4SendData).not.toHaveBeenCalled()
      })
    })

    describe('when multiple select', () => {
      let select, options, index

      beforeEach(() => {
        createFormAndSetup(container, 'select-multiple')
        index = form.querySelector('[data-ga4-index]')

        select = form.querySelector('select')
        options = form.querySelectorAll('option')
        options[0].selected = true
        options[1].selected = true

        mockGa4SendData.calls.reset()
      })

      it('has an option deselected', () => {
        options[1].selected = false

        mockGa4SendData.calls.reset()

        select.dispatchEvent(
          new CustomEvent('change', {
            bubbles: true,
            detail: { value: options[1].value }
          })
        )

        expect(mockGa4SendData).toHaveBeenCalledWith(
          {
            ...expectedAttributes,
            ...JSON.parse(index.dataset.ga4Index),
            action: 'remove'
          },
          'event_data'
        )
      })
    })

    afterEach(() => {
      container.innerHTML = ''
    })
  })

  describe('if form has no `data-ga4-form-change-tracking`', () => {
    beforeEach(() => {
      mockGa4SendData = spyOn(
        window.GOVUK.analyticsGa4.core,
        'applySchemaAndSendData'
      )
    })

    it('does not track changes', () => {
      form = new Form(['text'])

      form.appendToParent(container)

      const trackedComponent =
        GOVUK.analyticsGa4.analyticsModules.Ga4FormSetup.trackedComponents[0]
      form.querySelector('input').dataset.module = `${trackedComponent}`

      GOVUK.analyticsGa4.analyticsModules.Ga4IndexSectionSetup.init()
      GOVUK.analyticsGa4.analyticsModules.Ga4FormSetup.init()

      const index = form
        .querySelector(`input[type="text"]`)
        .closest('[data-ga4-index]')

      form.triggerChange(`input[type="text"]`)

      expect(mockGa4SendData).not.toHaveBeenCalledWith(
        {
          ...expectedAttributes,
          ...JSON.parse(index.dataset.ga4Index),
          action: 'select'
        },
        'event_data'
      )
    })

    afterEach(() => {
      container.innerHTML = ''
    })
  })

  afterAll(() => {
    container.remove()
  })
})
