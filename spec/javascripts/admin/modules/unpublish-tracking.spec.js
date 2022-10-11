describe('GOVUK.Modules.UnpublishTracking', function () {
  var form

  beforeEach(function () {
    form = document.createElement('form')
    form.setAttribute('data-unpublish-reason-label', 'Unpublish: consolidated into another GOV.UK page')
    form.innerHTML = `
      <fieldset class="govuk-fieldset">
        <legend class="govuk-fieldset__legend govuk-fieldset__legend--m"><h2 class="govuk-fieldset__heading">Do you need to reuse a previous withdrawal?</h2> </legend>
        <div class="govuk-radios" data-module="govuk-radios" data-govuk-radios-module-started="true">
          <div class="gem-c-radio govuk-radios__item">
            <input type="radio" name="previous_withdrawal_id" id="radio-1" value="8" class="govuk-radios__input" aria-describedby="label-hint-81db5f4d">
            <label for="radio-1" class="gem-c-label govuk-label govuk-radios__label">
              <time class="date" datetime="2022-08-24T18:07:34+01:00" lang="en">24 August 2022</time>
            </label
          </div>
          <div class="gem-c-radio govuk-radios__item">
            <input type="radio" name="previous_withdrawal_id" id="radio-2" value="10" class="govuk-radios__input" aria-describedby="label-hint-1c4b3c34">
            <label for="radio-2" class="gem-c-label govuk-label govuk-radios__label">
              <time class="date" datetime="2022-08-25T18:07:34+01:00" lang="en">25 August 2022</time>
            </label>
          </div>
          <div class="govuk-radios__divider">or</div>
          <div class="gem-c-radio govuk-radios__item">
            <input type="radio" name="previous_withdrawal_id" id="radio-3" value="new" class="govuk-radios__input" aria-controls="conditional-fe87df89" aria-expanded="false">
            <label for="radio-3" class="gem-c-label govuk-label govuk-radios__label">This is a new withdrawal</label>
          </div>
          <div class="govuk-radios__conditional govuk-radios__conditional--hidden govuk-body" id="conditional-fe87df89">
            <div class="gem-c-textarea govuk-form-group govuk-!-margin-bottom-6">
              <label for="textarea-5cd9182d" class="gem-c-label govuk-label govuk-label--s">Public explanation</label>
              <div id="hint-2e419619" class="gem-c-hint govuk-hint govuk-!-margin-bottom-3"> This is shown on the live site </div>
              <textarea name="unpublishing[explanation]" class="govuk-textarea" id="textarea-5cd9182d" rows="5" data-module="paste-html-to-govspeak" spellcheck="true" aria-describedby="hint-2e419619" data-paste-html-to-govspeak-module-started="true"></textarea>
            </div>
          </div>
        </div>
      </fieldset>
    `

    var unpublishTracking = new GOVUK.Modules.UnpublishTracking(form)
    unpublishTracking.init()
  })

  it('should send tracking event when form is submitted', function () {
    spyOn(GOVUK.analytics, 'trackEvent')
    form.dispatchEvent(new Event('submit'))

    expect(GOVUK.analytics.trackEvent).toHaveBeenCalledWith(
      'WithdrawUnpublishSelection',
      'WithdrawUnpublish-selection',
      { label: 'Unpublish: consolidated into another GOV.UK page' }
    )

    expect(GOVUK.analytics.trackEvent).not.toHaveBeenCalledWith(
      'WithdrawUnpublishSelection',
      'Withdraw-selection',
      jasmine.any(Object)
    )
  })

  it('should send two tracking event when form is submitted with withdrawal date selected', function () {
    spyOn(GOVUK.analytics, 'trackEvent')

    var radio = form.querySelector('input[name=previous_withdrawal_id]')
    radio.checked = true
    radio.dispatchEvent(new Event('change'))
    form.dispatchEvent(new Event('submit'))

    expect(GOVUK.analytics.trackEvent).toHaveBeenCalledWith(
      'WithdrawUnpublishSelection',
      'WithdrawUnpublish-selection',
      { label: 'Unpublish: consolidated into another GOV.UK page' }
    )

    expect(GOVUK.analytics.trackEvent).toHaveBeenCalledWith(
      'WithdrawUnpublishSelection',
      'Withdraw-selection',
      { label: '24 August 2022' }
    )
  })
})
