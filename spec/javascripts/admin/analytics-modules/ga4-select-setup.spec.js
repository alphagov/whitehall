describe('GOVUK.analyticsGa4.analyticsModules.GA4SelectEventHandlers', function () {
  it(`triggers GA4 in response to change events on selects with no [data-module~='select-with-search'] ancestor`, function () {
    const container = document.createElement('div')
    container.setAttribute('data-module', 'ga4-select-setup')

    const select = document.createElement('select')
    select.setAttribute('data-ga4-document-type', 'new-consultations')
    select.setAttribute('data-ga4-index-section', '20')
    select.setAttribute('data-ga4-section', 'Settings')

    const option = document.createElement('option')
    option.setAttribute('value', '1')
    option.setAttribute('selected', '')
    option.innerText = 'Email address for ordering attachment files'

    select.appendChild(option)
    container.appendChild(select)
    document.body.appendChild(container)

    const ga4SelectEventHandlers =
      GOVUK.analyticsGa4.analyticsModules.Ga4SelectSetup

    ga4SelectEventHandlers.init()

    const mockGa4SendData = spyOn(window.GOVUK.analyticsGa4.core, 'sendData')

    select.dispatchEvent(new Event('change'))

    const expectedAttributes = {
      event: 'event_data',
      event_data: {
        event_name: 'select_component',
        type: 'new-consultations',
        index: {
          index_section_count: '0',
          index_section: '20'
        },
        text: 'Email address for ordering attachment files',
        section: 'Settings',
        action: 'select'
      }
    }

    expect(mockGa4SendData).toHaveBeenCalledWith(
      expectedAttributes,
      'event_data'
    )
  })

  it(`does not trigger GA4 in response to change events on selects with a [data-module~='select-with-search'] ancestor`, function () {
    const container = document.createElement('div')
    container.setAttribute('data-module', 'ga4-select-setup')

    const wrapper = document.createElement('div')
    wrapper.setAttribute('data-module', 'select-with-search')

    const select = document.createElement('select')
    select.setAttribute('data-ga4-document-type', 'new-consultations')
    select.setAttribute('data-ga4-index-section', '20')
    select.setAttribute('data-ga4-section', 'Settings')

    const option = document.createElement('option')
    option.setAttribute('value', '1')
    option.setAttribute('selected', '')
    option.innerText = 'Email address for ordering attachment files'

    select.appendChild(option)
    wrapper.appendChild(select)
    container.appendChild(wrapper)
    document.body.appendChild(container)

    const ga4SelectEventHandlers =
      GOVUK.analyticsGa4.analyticsModules.Ga4SelectSetup

    ga4SelectEventHandlers.init()

    const mockGa4SendData = spyOn(window.GOVUK.analyticsGa4.core, 'sendData')

    select.dispatchEvent(new Event('change'))

    expect(mockGa4SendData).not.toHaveBeenCalled()
  })
})
