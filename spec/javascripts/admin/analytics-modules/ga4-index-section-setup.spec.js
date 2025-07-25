describe('GOVUK.analyticsGa4.analyticsModules.GA4IndexSectionEventHandlers', function () {
  const Form = window.GOVUK.Modules.JasmineHelpers.Form

  const Ga4IndexSectionSetup =
    window.GOVUK.analyticsGa4.analyticsModules.Ga4IndexSectionSetup

  let container, form, input, fieldset, select

  beforeEach(function () {
    container = document.createElement('div')
    container.setAttribute('data-module', 'ga4-index-section-setup')

    form = new Form(['text', 'select', 'radio'])

    form.appendToParent(container)
    document.body.appendChild(container)

    input = form.querySelector('input')
    select = form.querySelector('select')
    fieldset = form.querySelector('fieldset')
  })

  describe('for a form not tracked by ga4-finder-tracker', function () {
    it('adds a ga4-index-section data attribute to select and input fields reflecting their position in the DOM', function () {
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
      Ga4IndexSectionSetup.init()

      expect(input.dataset.ga4FilterParent).not.toBeDefined()
      expect(select.dataset.ga4FilterParent).not.toBeDefined()
      expect(fieldset.dataset.ga4FilterParent).not.toBeDefined()
    })
  })

  describe('for a form tracked by ga4-finder-tracker', function () {
    it('adds ga4-index-section and ga4-filter-parent data attributes to select and input fields reflecting their position in the DOM', function () {
      form.dataset.module = 'ga4-finder-tracker'

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
    let excludedParent, excludedInput, radioInput, hiddenInput

    it('select and input fields in an excludedParent', function () {
      excludedParent = document.createElement('div')
      excludedParent.setAttribute('data-module', 'select-with-search')
      excludedInput = document.createElement('input')
      excludedParent.appendChild(excludedInput)
      form.appendChild(excludedParent)

      Ga4IndexSectionSetup.init()

      expect(excludedInput.dataset.ga4Index).not.toBeDefined()
    })

    it('radio button within fieldset', function () {
      Ga4IndexSectionSetup.init()

      radioInput = form.querySelector('input[type=radio]')

      expect(radioInput.dataset.ga4Index).not.toBeDefined()
    })

    it('hidden input', function () {
      hiddenInput = document.createElement('input')
      hiddenInput.type = 'hidden'
      form.appendChild(hiddenInput)

      Ga4IndexSectionSetup.init()

      hiddenInput = form.querySelector('input[type=hidden]')

      expect(hiddenInput.dataset.ga4Index).not.toBeDefined()
    })
  })

  afterEach(function () {
    container.remove()
  })
})
