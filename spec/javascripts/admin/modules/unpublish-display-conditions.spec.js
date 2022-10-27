describe('GOVUK.Modules.UnpublishDisplayConditions', function () {
  var body

  beforeEach(function () {
    body = document.createElement('div')
    body.innerHTML = `
      <div data-module="unpublish-display-conditions">
        <div class="govuk-form-group govuk-!-margin-bottom-6">
          <fieldset class="govuk-fieldset">
            <legend class="govuk-fieldset__legend govuk-fieldset__legend--m"><h2 class="govuk-fieldset__heading">Do you want to unpublish or withdraw this document?</h2> </legend>
            <div class="govuk-body">Learn more about withdrawing and unpublishing content on our <a href="https://www.gov.uk/guidance/how-to-publish-on-gov-uk/unpublishing-and-archiving" class="govuk-link">publishing guide</a>.</div>
            <div class="govuk-radios">
              <div class="gem-c-radio govuk-radios__item">
                <input type="radio" name="unpublishing_reason" id="radio-published-in-error" value="1" class="govuk-radios__input">
                <label for="radio-published-in-error" class="gem-c-label govuk-label govuk-radios__label">Unpublish: published in error</label>
              </div>
              <div class="gem-c-radio govuk-radios__item">
                <input type="radio" name="unpublishing_reason" id="radio-published-consolidated" value="4" class="govuk-radios__input">
                <label for="radio-published-consolidated" class="gem-c-label govuk-label govuk-radios__label">Unpublish: consolidated into another GOV.UK page</label>
              </div>
              <div class="govuk-radios__divider">or</div>
              <div class="gem-c-radio govuk-radios__item">
                <input type="radio" name="unpublishing_reason" id="radio-withdraw" value="5" class="govuk-radios__input">
                <label for="radio-withdraw" class="gem-c-label govuk-label govuk-radios__label">Withdraw: no longer current government policy/activity</label>
              </div>
            </div>
          </fieldset>
        </div>
        <div class="unpublish-withdraw-form-wrapper js-unpublish-withdraw-form__withdrawal">
          this is the withdrawal section
        </div>
        <div class="unpublish-withdraw-form-wrapper js-unpublish-withdraw-form__published-in-error">
          this is the error section
          <div class="gem-c-checkboxes govuk-form-group">
            <div class="govuk-checkboxes__item">
              <input type="checkbox" name="unpublishing[redirect]" id="checkboxes-cb24c6f1-0" value="1" class="govuk-checkboxes__input">
              <label for="checkboxes-cb24c6f1-0" class="govuk-label govuk-checkboxes__label">Redirect to URL automatically?</label>
            </div>
          </div>
          <div class="gem-c-textarea govuk-form-group govuk-!-margin-bottom-6">
            <label for="published_in_error_explanation" class="gem-c-label govuk-label govuk-label--s">Public explanation</label>
            <textarea name="unpublishing[explanation]" class="govuk-textarea" id="published_in_error_explanation" rows="5"></textarea>
          </div>
        </div>
        <div class="unpublish-withdraw-form-wrapper js-unpublish-withdraw-form__consolidated">
          this is the consolidated section
        </div>
      </div>
    `
    var checkbox = body.querySelector('.govuk-checkboxes__item input[name="unpublishing[redirect]"]')
    checkbox.checked = true
    var unpublishDisplayConditions = new GOVUK.Modules.UnpublishDisplayConditions(body)
    unpublishDisplayConditions.init()
  })

  it('should not show any section if nothing is selected', function () {
    expect(body.querySelector('.js-unpublish-withdraw-form__published-in-error').style.display).not.toEqual('block')
    expect(body.querySelector('.js-unpublish-withdraw-form__consolidated').style.display).not.toEqual('block')
    expect(body.querySelector('.js-unpublish-withdraw-form__withdrawal').style.display).not.toEqual('block')
  })

  it('should only show publish in error section when selecting unpublish: published in error', function () {
    var radio = body.querySelector('#radio-published-in-error')
    radio.checked = true
    radio.dispatchEvent(new Event('change'))

    expect(body.querySelector('.js-unpublish-withdraw-form__published-in-error').style.display).toEqual('block')
    expect(body.querySelector('.js-unpublish-withdraw-form__consolidated').style.display).not.toEqual('block')
    expect(body.querySelector('.js-unpublish-withdraw-form__withdrawal').style.display).not.toEqual('block')
  })

  it('should only show consolidated section when selecting unpublish: consolidated', function () {
    var radio = body.querySelector('#radio-published-consolidated')
    radio.checked = true
    radio.dispatchEvent(new Event('change'))

    expect(body.querySelector('.js-unpublish-withdraw-form__published-in-error').style.display).not.toEqual('block')
    expect(body.querySelector('.js-unpublish-withdraw-form__consolidated').style.display).toEqual('block')
    expect(body.querySelector('.js-unpublish-withdraw-form__withdrawal').style.display).not.toEqual('block')
  })

  it('should only show withdrawal section when selecting withdrawal', function () {
    var radio = body.querySelector('#radio-withdraw')
    radio.checked = true
    radio.dispatchEvent(new Event('change'))

    expect(body.querySelector('.js-unpublish-withdraw-form__published-in-error').style.display).not.toEqual('block')
    expect(body.querySelector('.js-unpublish-withdraw-form__consolidated').style.display).not.toEqual('block')
    expect(body.querySelector('.js-unpublish-withdraw-form__withdrawal').style.display).toEqual('block')
  })

  it('should show last chosen option if user changes their selected option', function () {
    var radio = body.querySelector('#radio-withdraw')
    radio.checked = true
    radio.dispatchEvent(new Event('change'))

    expect(body.querySelector('.js-unpublish-withdraw-form__published-in-error').style.display).not.toEqual('block')
    expect(body.querySelector('.js-unpublish-withdraw-form__consolidated').style.display).not.toEqual('block')
    expect(body.querySelector('.js-unpublish-withdraw-form__withdrawal').style.display).toEqual('block')

    var radio2 = body.querySelector('#radio-published-consolidated')
    radio2.checked = true
    radio2.dispatchEvent(new Event('change'))

    expect(body.querySelector('.js-unpublish-withdraw-form__published-in-error').style.display).not.toEqual('block')
    expect(body.querySelector('.js-unpublish-withdraw-form__consolidated').style.display).toEqual('block')
    expect(body.querySelector('.js-unpublish-withdraw-form__withdrawal').style.display).not.toEqual('block')
  })

  it('should hide public explanation section when "Redirect to URL automatically?" is pre-checked', function () {
    expect(body.querySelector('.js-unpublish-withdraw-form__published-in-error div.gem-c-textarea').style.display).toEqual('none')
  })

  it('should show/hide public explanation section when "Redirect to URL automatically?" is unchecked/checked', function () {
    var checkbox = body.querySelector('.govuk-checkboxes__item input[name="unpublishing[redirect]"]')
    checkbox.checked = false
    checkbox.dispatchEvent(new Event('change'))

    expect(body.querySelector('.js-unpublish-withdraw-form__published-in-error div.gem-c-textarea').style.display).toEqual('block')

    checkbox.checked = true
    checkbox.dispatchEvent(new Event('change'))

    expect(body.querySelector('.js-unpublish-withdraw-form__published-in-error div.gem-c-textarea').style.display).toEqual('none')
  })
})
