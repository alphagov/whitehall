describe('GOVUK.Modules.PreventMultipleFormSubmissions', function () {
  var form, submitButton

  beforeEach(function () {
    form = document.createElement('form')
    form.setAttribute('data-module', 'prevent-multiple-form-submissions')

    submitButton = document.createElement('button')
    form.appendChild(submitButton)

    var module = new GOVUK.Modules.PreventMultipleFormSubmissions(form)
    module.init()
  })

  it('should initialise correctly', function () {
    expect(submitButton).not.toHaveClass('govuk-button--disabled')
    expect(submitButton.getAttribute('aria-disabled')).not.toEqual('true')
    expect(submitButton.getAttribute('disabled')).not.toEqual('disabled')
    expect(submitButton.getAttribute('disabled')).not.toEqual('true')
  })

  it('should disable the submit buttons when clicked', function () {
    form.dispatchEvent(new Event('submit'))

    expect(submitButton).toHaveClass('govuk-button--disabled')
    expect(submitButton.getAttribute('aria-disabled')).toEqual('true')
    expect(submitButton.getAttribute('disabled')).toEqual('disabled')
  })
})
