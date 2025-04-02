describe('GOVUK.analyticsGa4.analyticsModules.GA4IndexSectionEventHandlers', function () {
  let container, form, input, select, excludedParent, excludedInput

  beforeEach(function () {
    document.title = 'Document title'

    container = document.createElement('div')
    container.setAttribute('data-module', 'ga4-index-section-setup')
    form = document.createElement('form')
    input = document.createElement('input')
    form.appendChild(input)
    select = document.createElement('select')
    form.appendChild(select)
    excludedParent = document.createElement('div')
    excludedParent.setAttribute('data-module', 'select-with-search')
    excludedInput = document.createElement('input')
    excludedParent.appendChild(excludedInput)
    form.appendChild(excludedParent)
    container.appendChild(form)
    document.body.appendChild(container)
  })

  it('adds a ga4-index-section data attribute to select and input fields reflecting their position in the DOM', function () {
    const Ga4IndexSectionSetup =
      GOVUK.analyticsGa4.analyticsModules.Ga4IndexSectionSetup
    Ga4IndexSectionSetup.init()

    expect(input.dataset.ga4IndexSection).toEqual('0')
    expect(select.dataset.ga4IndexSection).toEqual('1')
  })

  it('does not add ga4-index-section data attributes to select and input fields in an excludedParent', function () {
    const Ga4IndexSectionSetup =
      GOVUK.analyticsGa4.analyticsModules.Ga4IndexSectionSetup
    Ga4IndexSectionSetup.init()

    expect(excludedInput.dataset.ga4IndexSection).not.toBeDefined()
  })
})
