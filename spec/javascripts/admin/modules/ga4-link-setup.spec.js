describe('GOVUK.Modules.Ga4LinkSetup', function () {
  let link, container

  beforeEach(function () {
    document.title = 'Title - Text'

    container = document.createElement('div')
    link = document.createElement('a')
    link.textContent = 'Link'
    container.appendChild(link)
  })

  it('adds ga4 event data to links contained within', function () {
    const Ga4LinkSetup = new GOVUK.Modules.Ga4LinkSetup(container)
    Ga4LinkSetup.init()

    expect(link.dataset.ga4Event).toEqual(
      '{"event_name":"navigation","type":"generic_link","section":"Title"}'
    )
  })
})
