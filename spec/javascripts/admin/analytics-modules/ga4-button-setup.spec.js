describe('GOVUK.analyticsGa4.analyticsModules', function () {
  let button, container

  beforeEach(function () {
    document.title = 'Title - Text'

    container = document.createElement('div')
    container.setAttribute('data-module', 'ga4-button-setup')
    button = document.createElement('button')
    button.textContent = 'Button'
    button.type = 'button'
    container.appendChild(button)
    document.body.appendChild(container)
  })

  it('adds ga4 event data to buttons contained within', function () {
    const ga4ButtonSetup = GOVUK.analyticsGa4.analyticsModules.Ga4ButtonSetup
    ga4ButtonSetup.init()

    expect(button.dataset.ga4Event).toEqual(
      '{"event_name":"navigation","type":"button","text":"Button","section":"Title","action":"Button","method":"primary_click"}'
    )
  })

  it('uses navigation as the event name from "submit" buttons', function () {
    button.type = 'submit'

    const ga4ButtonSetup = GOVUK.analyticsGa4.analyticsModules.Ga4ButtonSetup
    ga4ButtonSetup.init()

    expect(button.dataset.ga4Event).toEqual(
      '{"event_name":"navigation","type":"button","text":"Button","section":"Title","action":"Button","method":"primary_click"}'
    )
  })

  it('merges existing ga4Event data with the generic data', function () {
    button.dataset.ga4Event = JSON.stringify({
      event_name: 'custom_event_name'
    })

    const ga4ButtonSetup = GOVUK.analyticsGa4.analyticsModules.Ga4ButtonSetup
    ga4ButtonSetup.init()

    expect(button.dataset.ga4Event).toEqual(
      '{"event_name":"custom_event_name","type":"button","text":"Button","section":"Title","action":"Button","method":"primary_click"}'
    )
  })

  it('adds ga4 event data to nodes with the button role', function () {
    const link = document.createElement('a')
    link.textContent = 'Link'
    link.role = 'button'
    button.replaceWith(link)

    const ga4ButtonSetup = GOVUK.analyticsGa4.analyticsModules.Ga4ButtonSetup
    ga4ButtonSetup.init()

    expect(link.dataset.ga4Event).toEqual(
      '{"event_name":"navigation","type":"button","text":"Link","section":"Title","action":"Link","method":"primary_click"}'
    )
  })
})
