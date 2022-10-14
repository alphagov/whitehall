describe('GOVUK.worldLocationFilter', function () {
  var form

  beforeEach(function () {
    form = document.createElement('form')

    form.classList.add('js-world-location-filter')
    form.innerHTML = '<select id="world_locations">' +
      '<option value="France">France</option>' +
      '<option value="Germany">Germany</option>' +
      '</select>' +
      '<button type="submit">Submit</button>'

    document.body.appendChild(form)
  })

  afterEach(function () {
    document.body.removeChild(form)
  })

  it('submits the form when the select changes', function () {
    spyOn(form, 'submit')
    GOVUK.worldLocationFilter.init()
    var select = form.querySelector('select')
    var event = new window.Event('change')
    select.dispatchEvent(event)
    expect(form.submit).toHaveBeenCalled()
  })

  it('hides the button when initialised', function () {
    GOVUK.worldLocationFilter.init()
    var button = form.querySelector('button')
    expect(button.classList).toContain('govuk-!-display-none')
  })
})
