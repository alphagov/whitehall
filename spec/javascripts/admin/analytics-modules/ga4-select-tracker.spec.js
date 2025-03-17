describe('GOVUK.analyticsGa4.analyticsModules.Ga4SelectSetup', function () {
  let container, select, option, label, expectedAttributes

  const documentType = 'document-type'
  const labelContent = 'Select label'

  beforeEach(function () {
    expectedAttributes = {
      event: 'event_data',
      event_data: {
        event_name: 'select_content',
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

    container = document.createElement('div')
    container.setAttribute('data-module', 'ga4-select-setup')
    container.setAttribute('data-ga4-document-type', documentType)

    label = document.createElement('label')
    label.innerText = labelContent
    label.setAttribute('for', 'select-test')

    select = document.createElement('select')
    select.id = 'select-test'
    select.setAttribute('data-ga4-document-type', 'new-consultations')
    select.setAttribute('data-ga4-index-section', '20')
    select.setAttribute('data-ga4-section', 'Settings')

    option = document.createElement('option')
    option.setAttribute('value', '1')
    option.setAttribute('selected', '')
    option.innerText = 'Email address for ordering attachment files'

    select.appendChild(option)
    container.appendChild(label)
    container.appendChild(select)
    document.body.appendChild(container)
  })

  it(`triggers GA4 in response to change events on selects that are not replaced by choices.js`, function () {
    const ga4SelectEventHandlers =
      GOVUK.analyticsGa4.analyticsModules.Ga4SelectSetup

    ga4SelectEventHandlers.init()

    const mockGa4SendData = spyOn(window.GOVUK.analyticsGa4.core, 'sendData')

    select.dispatchEvent(new Event('change', { bubbles: true }))

    expect(mockGa4SendData).toHaveBeenCalledWith(
      expectedAttributes,
      'event_data'
    )
  })

  it(`does not trigger GA4 in response to change events on selects that are replaced by choices.js`, function () {
    select.setAttribute('hidden', true)

    const ga4SelectEventHandlers =
      GOVUK.analyticsGa4.analyticsModules.Ga4SelectSetup

    ga4SelectEventHandlers.init()

    const mockGa4SendData = spyOn(window.GOVUK.analyticsGa4.core, 'sendData')

    select.dispatchEvent(new Event('change', { bubbles: true }))

    expect(mockGa4SendData).not.toHaveBeenCalled()
  })

  it(`uses document type from container if not specified on select`, function () {
    select.removeAttribute('data-ga4-document-type')

    const ga4SelectEventHandlers =
      GOVUK.analyticsGa4.analyticsModules.Ga4SelectSetup

    ga4SelectEventHandlers.init()

    const mockGa4SendData = spyOn(window.GOVUK.analyticsGa4.core, 'sendData')

    select.dispatchEvent(new Event('change', { bubbles: true }))

    expectedAttributes.event_data.type = documentType

    expect(mockGa4SendData).toHaveBeenCalledWith(
      expectedAttributes,
      'event_data'
    )
  })

  it(`uses label of select for section if not specified on select`, function () {
    select.removeAttribute('data-ga4-section')

    const ga4SelectEventHandlers =
      GOVUK.analyticsGa4.analyticsModules.Ga4SelectSetup

    ga4SelectEventHandlers.init()

    const mockGa4SendData = spyOn(window.GOVUK.analyticsGa4.core, 'sendData')

    select.dispatchEvent(new Event('change', { bubbles: true }))

    expectedAttributes.event_data.section = labelContent

    expect(mockGa4SendData).toHaveBeenCalledWith(
      expectedAttributes,
      'event_data'
    )
  })

  afterEach(function () {
    document.body.removeChild(container)
  })
})
