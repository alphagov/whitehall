describe('GOVUK.analyticsGa4.analyticsModules.GA4IndexSectionEventHandlers', function () {
  let container,
    form,
    input,
    radioInput,
    hiddenInput,
    fieldset,
    select,
    excludedParent,
    excludedInput

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
    fieldset = document.createElement('fieldset')
    radioInput = document.createElement('input')
    radioInput.type = 'radio'
    fieldset.appendChild(radioInput)
    form.appendChild(fieldset)
    hiddenInput = document.createElement('input')
    hiddenInput.type = 'hidden'
    form.appendChild(hiddenInput)
    container.appendChild(form)
    document.body.appendChild(container)
  })

  describe('for a form not tracked by ga4-finder-tracker', function () {
    it('adds a ga4-index-section data attribute to select and input fields reflecting their position in the DOM', function () {
      const Ga4IndexSectionSetup =
        GOVUK.analyticsGa4.analyticsModules.Ga4IndexSectionSetup
      Ga4IndexSectionSetup.init()

      expect(input.dataset.ga4Index).toEqual(
        JSON.stringify({ index_section: 0, index_section_count: 3 })
      )
      expect(select.dataset.ga4Index).toEqual(
        JSON.stringify({ index_section: 1, index_section_count: 3 })
      )
      expect(fieldset.dataset.ga4Index).toEqual(
        JSON.stringify({ index_section: 2, index_section_count: 3 })
      )
    })

    it('does not add ga4-filter-parent', function () {
      const Ga4IndexSectionSetup =
        GOVUK.analyticsGa4.analyticsModules.Ga4IndexSectionSetup
      Ga4IndexSectionSetup.init()

      expect(input.dataset.ga4FilterParent).not.toBeDefined()
      expect(select.dataset.ga4FilterParent).not.toBeDefined()
      expect(fieldset.dataset.ga4FilterParent).not.toBeDefined()
    })
  })

  describe('for a form tracked by ga4-finder-tracker', function () {
    it('adds ga4-index-section and ga4-filter-parent data attributes to select and input fields reflecting their position in the DOM', function () {
      form.dataset.module = 'ga4-finder-tracker'

      const Ga4IndexSectionSetup =
        GOVUK.analyticsGa4.analyticsModules.Ga4IndexSectionSetup
      Ga4IndexSectionSetup.init()

      expect(input.dataset.ga4Index).toEqual(
        JSON.stringify({ index_section: 0, index_section_count: 3 })
      )
      expect(input.dataset.ga4FilterParent).toBeDefined()

      expect(select.dataset.ga4Index).toEqual(
        JSON.stringify({ index_section: 1, index_section_count: 3 })
      )
      expect(select.dataset.ga4FilterParent).toBeDefined()

      expect(fieldset.dataset.ga4Index).toEqual(
        JSON.stringify({ index_section: 2, index_section_count: 3 })
      )
      expect(fieldset.dataset.ga4FilterParent).toBeDefined()
    })
  })

  describe('does not add ga4-index-section data attributes to', function () {
    it('select and input fields in an excludedParent', function () {
      const Ga4IndexSectionSetup =
        GOVUK.analyticsGa4.analyticsModules.Ga4IndexSectionSetup
      Ga4IndexSectionSetup.init()

      expect(excludedInput.dataset.ga4Index).not.toBeDefined()
    })

    it('radio button within fieldset', function () {
      const Ga4IndexSectionSetup =
        GOVUK.analyticsGa4.analyticsModules.Ga4IndexSectionSetup
      Ga4IndexSectionSetup.init()

      expect(radioInput.dataset.ga4Index).not.toBeDefined()
    })

    it('hidden input', function () {
      const Ga4IndexSectionSetup =
        GOVUK.analyticsGa4.analyticsModules.Ga4IndexSectionSetup
      Ga4IndexSectionSetup.init()

      expect(hiddenInput.dataset.ga4Index).not.toBeDefined()
    })
  })

  afterEach(function () {
    container.remove()
  })
})
