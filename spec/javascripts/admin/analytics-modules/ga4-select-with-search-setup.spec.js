describe('GOVUK.analyticsGa4.analyticsModules.GA4SelectWithSearchEventHandlers', function () {
  it('triggers GA4 when an addItem event occurs on selects', function () {
    const container = document.createElement('div')
    container.setAttribute('data-module', 'ga4-select-with-search-setup')

    const select = document.createElement('select')
    select.setAttribute('data-ga4-document-type', 'new-consultations')
    select.setAttribute('data-ga4-index-section', '20')
    select.setAttribute('data-ga4-section', 'Lead organisation')

    const option = document.createElement('option')
    option.setAttribute('value', '1')
    option.setAttribute('selected', '')
    option.innerText = 'First organisation name'

    select.appendChild(option)
    container.appendChild(select)
    document.body.appendChild(container)

    const ga4SelectWithSearchEventHandlers =
      GOVUK.analyticsGa4.analyticsModules.Ga4SelectWithSearchSetup

    ga4SelectWithSearchEventHandlers.init()

    const mockGa4SendData = spyOn(window.GOVUK.analyticsGa4.core, 'sendData')

    select.dispatchEvent(
      new CustomEvent('addItem', {
        detail: { label: 'First organisation name' }
      })
    )

    const expectedAttributes = {
      event: 'event_data',
      event_data: {
        event_name: 'select_component',
        type: 'new-consultations',
        index: {
          index_section_count: '0',
          index_section: '20'
        },
        text: 'First organisation name',
        section: 'Lead organisation',
        action: 'select'
      }
    }

    expect(mockGa4SendData).toHaveBeenCalledWith(
      expectedAttributes,
      'event_data'
    )
  })

  it('triggers GA4 when a removeItem event occurs on selects that have the "multiple" attribute', function () {
    const container = document.createElement('div')
    container.setAttribute('data-module', 'ga4-select-with-search-setup')

    const select = document.createElement('select')
    select.setAttribute('multiple', 'multiple')
    select.setAttribute('data-ga4-document-type', 'new-consultations')
    select.setAttribute('data-ga4-index-section', '20')
    select.setAttribute('data-ga4-section', 'Lead organisation')

    const option = document.createElement('option')
    option.setAttribute('value', '1')
    option.setAttribute('selected', '')
    option.innerText = 'First organisation name'

    select.appendChild(option)
    container.appendChild(select)
    document.body.appendChild(container)

    const ga4SelectWithSearchEventHandlers =
      GOVUK.analyticsGa4.analyticsModules.Ga4SelectWithSearchSetup

    ga4SelectWithSearchEventHandlers.init()

    const mockGa4SendData = spyOn(window.GOVUK.analyticsGa4.core, 'sendData')

    select.dispatchEvent(
      new CustomEvent('removeItem', {
        detail: { label: 'First organisation name', value: '1' }
      })
    )

    const expectedAttributes = {
      event: 'event_data',
      event_data: {
        event_name: 'select_component',
        type: 'new-consultations',
        text: 'First organisation name',
        index: {
          index_section_count: '1',
          index_section: '20'
        },
        section: 'Lead organisation',
        action: 'remove'
      }
    }

    expect(mockGa4SendData).toHaveBeenCalledWith(
      expectedAttributes,
      'event_data'
    )
  })

  it('does not trigger GA4 when a removeItem event occurs on selects that do not have the "multiple" attribute', function () {
    const container = document.createElement('div')
    container.setAttribute('data-module', 'ga4-select-with-search-setup')

    const select = document.createElement('select')
    select.setAttribute('data-ga4-document-type', 'new-consultations')
    select.setAttribute('data-ga4-index-section', '20')
    select.setAttribute('data-ga4-section', 'Lead organisation')

    const option = document.createElement('option')
    option.setAttribute('value', '1')
    option.setAttribute('selected', '')
    option.innerText = 'First organisation name'

    select.appendChild(option)
    container.appendChild(select)
    document.body.appendChild(container)

    const ga4SelectWithSearchEventHandlers =
      GOVUK.analyticsGa4.analyticsModules.Ga4SelectWithSearchSetup

    ga4SelectWithSearchEventHandlers.init()

    const mockGa4SendData = spyOn(window.GOVUK.analyticsGa4.core, 'sendData')

    select.dispatchEvent(
      new CustomEvent('removeItem', {
        detail: { label: 'First organisation name' }
      })
    )

    const expectedAttributes = {
      event_name: 'select_component',
      type: 'new-consultations',
      text: 'First organisation name',
      section: 'Lead organisation',
      action: 'remove'
    }

    expect(mockGa4SendData).not.toHaveBeenCalledWith(
      expectedAttributes,
      'event_data'
    )
  })
})
