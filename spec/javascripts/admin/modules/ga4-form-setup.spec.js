describe('GOVUK.Modules.Ga4FormSetup', function () {
  let button, container

  beforeEach(function () {
    document.title = 'Title - Text'

    container = document.createElement('form')
    button = document.createElement('button')
    button.type = 'submit'
    button.textContent = 'Button'
    container.appendChild(button)
  })

  it('adds ga4 event data to the container', function () {
    const Ga4FormSetup = new GOVUK.Modules.Ga4FormSetup(container)
    Ga4FormSetup.init()

    expect(container.dataset.ga4Form).toEqual(
      '{"event_name":"form_response","section":"Title","action":"button"}'
    )
  })
})
