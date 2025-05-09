describe('GOVUK.analyticsGa4.analyticsModules.Ga4FinderSetup', function () {
  const container = document.createElement('div')
  const form = document.createElement('form')
  form.dataset.module = 'ga4-finder-tracker'

  const text = document.createElement('input')
  text.type = 'text'

  const date = document.createElement('div')
  date.className = 'govuk-date-input'
  date.innerHTML = `
    <div class="govuk-date-input__item">
        <div class="govuk-form-group">
            <input class="gem-c-input govuk-input govuk-input--width-4" name="day" type="text" data-ga4-change-category="update-filter date">
        </div>
    </div>
    <div class="govuk-date-input__item">
        <div class="govuk-form-group">
            <input class="gem-c-input govuk-input govuk-input--width-4" name="month" type="text" data-ga4-change-category="update-filter date">
        </div>
    </div>
    <div class="govuk-date-input__item">
        <div class="govuk-form-group">
            <input class="gem-c-input govuk-input govuk-input--width-4" name="year" type="text" data-ga4-change-category="update-filter date">
        </div>
    </div>
  `

  const checkboxes = document.createElement('div')
  checkboxes.innerHTML = `
    <fieldset class="govuk-fieldset" aria-describedby="checkboxes-4d23386d-hint">
      <legend class="govuk-fieldset__legend govuk-fieldset__legend--m">What is your favourite colour?</legend>
      <div id="checkboxes-4d23386d-hint" class="govuk-hint">Select all that apply</div>
      <div class="govuk-checkboxes">
          <div class="govuk-checkboxes__item">
              <input type="checkbox" name="favourite_colour[]" id="checkboxes-4d23386d-0" value="red" class="govuk-checkboxes__input" data-ga4-change-category="update-filter checkbox">
              <label for="checkboxes-4d23386d-0" class="govuk-label govuk-checkboxes__label">Red</label>
          </div>
      </div>
    </fieldset>
  `

  const radios = document.createElement('div')
  radios.innerHTML = `
    <fieldset class="govuk-fieldset">
      <div class="govuk-radios">
          <input type="radio" name="radio-group" id="radio-77f4e0a5-0" value="government-gateway" class="govuk-radios__input" data-ga4-change-category="update-filter radio">
          <label for="radio-77f4e0a5-0" class="gem-c-label govuk-label govuk-radios__label">Use Government Gateway</label>
      </div>
    </fieldset>
  `

  const select = document.createElement('div')
  select.innerHTML = `
    <select data-ga4-change-category="update-filter select">
      <option value="1">1</option>
      <option value="2">2</option>
    </select>
  `

  const selectMultiple = document.querySelector('div')
  selectMultiple.innerHTML = select.innerHTML
  selectMultiple.dataset.ga4ChangeCategory = 'update-filter select-multiple'
  selectMultiple.querySelector('select').setAttribute('multiple', true)

  const trackedInputs = [date, radios, checkboxes, select, selectMultiple]

  container.appendChild(form)
  document.body.appendChild(container)

  beforeEach(() => {
    form.innerHTML = ''
  })

  describe('on change within tracked form', () => {
    let trackChangeEvent

    it('calls `trackChangeEvent` on tracked inputs', () => {
      const addInputToFormAndChange = (input) => {
        trackChangeEvent.calls.reset()

        form.innerHTML = input.outerHTML
        const field = form.querySelector('input, select')

        GOVUK.analyticsGa4.analyticsModules.Ga4FinderSetup.init()

        if (field.tagName === 'SELECT') {
          field.querySelectorAll('option')[1].selected = true
          field.dispatchEvent(new Event('change', { bubbles: true }))
        } else {
          field.click()
          field.value = '123'
          field.dispatchEvent(new Event('change', { bubbles: true }))
        }
      }

      trackChangeEvent = spyOn(
        GOVUK.analyticsGa4.Ga4FinderTracker,
        'trackChangeEvent'
      )

      trackedInputs.forEach((input) => {
        addInputToFormAndChange(input)
        const field = form.querySelector('input, select')

        expect(trackChangeEvent).toHaveBeenCalledWith(
          new Event('change'),
          field.dataset.ga4ChangeCategory
        )

        form.innerHTML = ''
      })
    })
  })

  afterAll(() => {
    container.remove()
  })
})
