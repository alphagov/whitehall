describe('GOVUK.analyticsGa4.analyticsModules.Ga4LinkSetup', function () {
  let link, container

  beforeEach(function () {
    document.title = 'Title - Text'

    container = document.createElement('div')
    container.setAttribute('data-module', 'ga4-link-setup')
    link = document.createElement('a')
    link.textContent = 'Link'
    container.appendChild(link)
    document.body.appendChild(container)
  })

  it('adds ga4 event data to links contained within', function () {
    const Ga4LinkSetup = GOVUK.analyticsGa4.analyticsModules.Ga4LinkSetup
    Ga4LinkSetup.init()

    expect(link.dataset.ga4Event).toEqual(
      '{"event_name":"navigation","type":"generic_link"}'
    )
  })

  it('sends type:"button" for links with role="button"', function () {
    link.role = 'button'

    const Ga4LinkSetup = GOVUK.analyticsGa4.analyticsModules.Ga4LinkSetup
    Ga4LinkSetup.init()

    expect(link.dataset.ga4Event).toEqual(
      '{"event_name":"navigation","type":"button"}'
    )
  })
})
