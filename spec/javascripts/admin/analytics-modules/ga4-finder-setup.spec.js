describe('GOVUK.analyticsGa4.analyticsModules.Ga4FinderSetup', function () {
  let container, form, trackedInputs

  const Form = window.GOVUK.Modules.JasmineHelpers.Form

  beforeAll(() => {
    container = document.createElement('div')

    trackedInputs = ['date', 'radio', 'checkbox', 'select', 'select-multiple']

    document.body.appendChild(container)
  })

  describe('on change within tracked form', () => {
    let trackChangeEvent

    beforeAll(() => {
      trackChangeEvent = spyOn(
        GOVUK.analyticsGa4.Ga4FinderTracker,
        'trackChangeEvent'
      )
    })

    it('calls `trackChangeEvent` on tracked inputs', () => {
      const addInputToFormAndChange = (...input) => {
        trackChangeEvent.calls.reset()

        form = new Form(input)

        form.setAttribute('data-module', 'ga4-finder-tracker')

        form.appendToParent(container)

        const field = form.querySelector('input, select')

        if (field.closest('fieldset')) {
          field.closest('fieldset').dataset.ga4ChangeCategory =
            `update-filter ${input}`
        } else {
          field.dataset.ga4ChangeCategory = `update-filter ${input}`
        }

        GOVUK.analyticsGa4.analyticsModules.Ga4FinderSetup.init()

        form.triggerChange('input, select')
      }

      trackedInputs.forEach((input) => {
        addInputToFormAndChange(input)
        const ga4ChangeCategoryElement = form.querySelector(
          '[data-ga4-change-category]'
        )
        const ga4ChangeCategory =
          ga4ChangeCategoryElement.dataset.ga4ChangeCategory

        expect(trackChangeEvent).toHaveBeenCalledWith(
          new Event('change'),
          ga4ChangeCategory
        )
      })
    })
  })

  afterEach(() => {
    container.innerHTML = ''
  })

  afterAll(() => {
    container.remove()
  })
})
