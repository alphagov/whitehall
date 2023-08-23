describe('GOVUK.doubleClickProtection', function () {
  let form

  beforeEach(function () {
    form = $('<form action="/go" method="POST"><input type="submit" name="input_name" value="Save" /></form>')

    $(document.body).append(form)

    GOVUK.doubleClickProtection()
  })

  afterEach(function () {
    form.remove()
  })

  it('disables the button when the form is submit', function () {
    const submitTag = form.find('input[type=submit]')
    expect(submitTag.prop('disabled')).toBeFalsy()

    form.on('submit', function (e) {
      e.preventDefault()
      expect(submitTag.prop('disabled')).toBeTruthy()
    })

    submitTag.click()
  })

  it('creates a hidden input with the same name and value when the form is submit', function () {
    const submitTag = form.find('input[type=submit]')

    form.on('submit', function (e) {
      e.preventDefault()
      expect($('form input[type=hidden][name=input_name][value=Save]').length).toBeGreaterThan(0)
    })

    submitTag.click()
  })
})
