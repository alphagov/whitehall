describe('GOVUK.analyticsGa4.analyticsModules.Ga4SearchSetup', function () {
  const expectedGa4DocumentType = 'documentType'
  const expectedGa4SearchSection = 'Filter by'

  const expectedDataset = {
    ga4SearchType: expectedGa4DocumentType,
    ga4SearchSection: expectedGa4SearchSection,
    ga4SearchUrl: '/'
  }

  const container = document.createElement('div')

  document.body.appendChild(container)

  describe('on form with `type="search"`', function () {
    let input, form, button

    beforeAll(function () {
      input = document.createElement('input')
      input.type = 'search'
      button = document.createElement('button')
      button.type = 'submit'
      button.setAttribute('data-ga4-event', 'data')
      form = document.createElement('form')
      form.appendChild(input)
      form.appendChild(button)
      container.append(form)
    })

    beforeEach(function () {
      container.dataset.ga4DocumentType = expectedGa4DocumentType
      window.GOVUK.analyticsGa4.analyticsModules.Ga4SearchSetup.init()
    })

    it('removes tracking attribute from submit button', function () {
      expect(Object.assign({}, button.dataset)).toEqual({})
    })

    it('adds correct data attributes', function () {
      expect(Object.assign({}, form.dataset)).toEqual(expectedDataset)
    })

    it('adds correct data attributes if search section specified', function () {
      expect(Object.assign({}, form.dataset)).toEqual(expectedDataset)
    })

    it('tracks event on submit', function () {
      const mockGa4SendData = spyOn(
        window.GOVUK.analyticsGa4.core,
        'applySchemaAndSendData'
      )

      form.dispatchEvent(new Event('submit'))

      expect(mockGa4SendData).toHaveBeenCalled()
    })

    afterEach(function () {
      Object.keys(form.dataset).forEach((dataKey) => {
        delete form.dataset[dataKey]
      })
      Object.keys(container.dataset).forEach((dataKey) => {
        delete container.dataset[dataKey]
      })
    })

    afterAll(function () {
      form.remove()
    })
  })

  describe('on form without `type="search"`', function () {
    let input, form, button

    beforeAll(function () {
      input = document.createElement('input')
      input.type = 'text'
      button = document.createElement('button')
      button.type = 'submit'
      button.setAttribute('data-ga4-event', 'data')
      form = document.createElement('form')
      form.appendChild(input)
      form.appendChild(button)
      container.append(form)
      window.GOVUK.analyticsGa4.analyticsModules.Ga4SearchSetup.init()
    })

    it('does not remove tracking attribute from submit button', function () {
      expect(Object.assign({}, button.dataset)).toEqual({ ga4Event: 'data' })
    })

    it('does not add data attributes', function () {
      expect(Object.assign({}, form.dataset)).not.toEqual(expectedDataset)
    })

    it('does not track event on submit', function () {
      const mockGa4SendData = spyOn(
        window.GOVUK.analyticsGa4.core,
        'applySchemaAndSendData'
      )

      form.dispatchEvent(new Event('submit'))

      expect(mockGa4SendData).not.toHaveBeenCalled()
    })

    afterAll(function () {
      form.remove()
    })
  })

  describe('on form with select with search component but no search', function () {
    let input, form, button, div

    beforeAll(function () {
      input = document.createElement('input')
      input.type = 'search'
      div = document.createElement('div')
      div.dataset.module = 'select-with-search'
      div.appendChild(input)
      button = document.createElement('button')
      button.type = 'submit'
      button.setAttribute('data-ga4-event', 'data')
      form = document.createElement('form')
      form.appendChild(div)
      form.appendChild(button)
      container.append(form)
      window.GOVUK.analyticsGa4.analyticsModules.Ga4SearchSetup.init()
    })

    it('does not remove tracking attribute from submit button', function () {
      expect(Object.assign({}, button.dataset)).toEqual({ ga4Event: 'data' })
    })

    it('does not add data attributes', function () {
      expect(Object.assign({}, form.dataset)).not.toEqual(expectedDataset)
    })

    it('does not track event on submit', function () {
      const mockGa4SendData = spyOn(
        window.GOVUK.analyticsGa4.core,
        'applySchemaAndSendData'
      )

      form.dispatchEvent(new Event('submit'))

      expect(mockGa4SendData).not.toHaveBeenCalled()
    })
  })

  afterAll(function () {
    container.remove()
  })
})
