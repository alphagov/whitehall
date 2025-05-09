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
            <input class="gem-c-input govuk-input govuk-input--width-4" name="day" type="text">
        </div>
    </div>
    <div class="govuk-date-input__item">
        <div class="govuk-form-group">
            <input class="gem-c-input govuk-input govuk-input--width-4" name="month" type="text">
        </div>
    </div>
    <div class="govuk-date-input__item">
        <div class="govuk-form-group">
            <input class="gem-c-input govuk-input govuk-input--width-4" name="year" type="text">
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
              <input type="checkbox" name="favourite_colour[]" id="checkboxes-4d23386d-0" value="red" class="govuk-checkboxes__input">
              <label for="checkboxes-4d23386d-0" class="govuk-label govuk-checkboxes__label">Red</label>
          </div>
      </div>
    </fieldset>
  `

  const radios = document.createElement('div')
  radios.innerHTML = `
    <fieldset class="govuk-fieldset">
      <div class="govuk-radios">
          <input type="radio" name="radio-group" id="radio-77f4e0a5-0" value="government-gateway" class="govuk-radios__input">
          <label for="radio-77f4e0a5-0" class="gem-c-label govuk-label govuk-radios__label">Use Government Gateway</label>
      </div>
    </fieldset>
  `

  const radiosChecked = document.createElement('div')
  radiosChecked.innerHTML = radios.innerHTML
  radiosChecked.querySelector('input').checked = true

  const select = document.createElement('div')
  select.innerHTML = `
    <select>
      <option value="1">1</option>
      <option value="2">2</option>
    </select>
  `

  const selectMultiple = document.querySelector('div')
  selectMultiple.innerHTML = select.innerHTML
  selectMultiple.querySelector('select').setAttribute('multiple', true)

  const oneDate = document.createElement('div')
  oneDate.innerHTML = `
    <input type="text" data-ga4-change-category="update-filter one-date" />
  `

  const trackedInputs = [
    date,
    radios,
    checkboxes,
    select,
    selectMultiple,
    oneDate,
    radiosChecked
  ]

  container.appendChild(form)
  document.body.appendChild(container)

  beforeEach(() => {
    form.innerHTML = ''
  })

  describe('on change within tracked form', () => {
    let trackChangeEvent

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

    it('calls `trackChangeEvent` on tracked inputs', () => {
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

  describe('updates dataset correctly', () => {
    it('for a checkbox', () => {
      form.append(checkboxes)

      GOVUK.analyticsGa4.analyticsModules.Ga4FinderSetup.init()

      const input = form.querySelector('input')

      const expectedDataset = {
        ga4ChangeCategory: 'update-filter checkbox'
      }

      expect(Object.assign({}, input.dataset)).toEqual(expectedDataset)
    })

    describe('for a radio', () => {
      let input

      beforeEach(() => {
        form.innerHTML = radios.innerHTML
        input = form.querySelector('input')
      })

      it('that are unchecked', () => {
        input.checked = false

        GOVUK.analyticsGa4.analyticsModules.Ga4FinderSetup.init()

        const expectedDataset = {
          ga4ChangeCategory: 'update-filter radio-empty'
        }

        expect(Object.assign({}, input.dataset)).toEqual(expectedDataset)
      })

      it('that are checked', () => {
        input.checked = true

        GOVUK.analyticsGa4.analyticsModules.Ga4FinderSetup.init()

        const expectedDataset = {
          ga4ChangeCategory: 'update-filter radio'
        }

        expect(Object.assign({}, input.dataset)).toEqual(expectedDataset)
      })
    })

    describe('for a select', () => {
      let selectInput

      beforeEach(() => {
        form.innerHTML = select.innerHTML
        selectInput = form.querySelector('select')
      })

      it('that are single choice', () => {
        GOVUK.analyticsGa4.analyticsModules.Ga4FinderSetup.init()

        const expectedDataset = {
          ga4ChangeCategory: 'update-filter select'
        }

        expect(Object.assign({}, selectInput.dataset)).toEqual(expectedDataset)
      })

      it('that are multiple choice', () => {
        selectInput.setAttribute('multiple', true)

        GOVUK.analyticsGa4.analyticsModules.Ga4FinderSetup.init()

        const expectedDataset = {
          ga4ChangeCategory: 'update-filter select-multiple'
        }

        expect(Object.assign({}, selectInput.dataset)).toEqual(expectedDataset)
      })
    })

    it('for a date', () => {
      form.innerHTML = date.outerHTML

      GOVUK.analyticsGa4.analyticsModules.Ga4FinderSetup.init()

      const inputs = form.querySelectorAll('input')

      const expectedDataset = {
        ga4ChangeCategory: 'update-filter date'
      }

      inputs.forEach((input) => {
        expect(Object.assign({}, input.dataset)).toEqual(expectedDataset)
      })
    })

    it('for a field that already has a data-ga4-change-category set', () => {
      form.innerHTML = oneDate.outerHTML

      GOVUK.analyticsGa4.analyticsModules.Ga4FinderSetup.init()

      const inputs = form.querySelectorAll('input')

      const expectedDataset = {
        ga4ChangeCategory: 'update-filter one-date'
      }

      inputs.forEach((input) => {
        expect(Object.assign({}, input.dataset)).toEqual(expectedDataset)
      })
    })
  })

  afterAll(() => {
    container.remove()
  })
})
