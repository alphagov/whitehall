describe('GOVUK.analyticsGa4.analyticsModules.Ga4FormSetup', function () {
  let button, container

  beforeEach(function () {
    document.title = 'Title - Text'

    container = document.createElement('form')
    container.setAttribute('data-module', 'ga4-form-setup')
    button = document.createElement('button')
    button.type = 'submit'
    button.textContent = 'Button'
    container.appendChild(button)
    document.body.appendChild(container)
  })

  it('adds ga4 event data to the container', function () {
    const Ga4FormSetup = GOVUK.analyticsGa4.analyticsModules.Ga4FormSetup
    Ga4FormSetup.init()

    expect(container.dataset.ga4Form).toEqual(
      '{"event_name":"form_response","action":"button"}'
    )
  })
})
