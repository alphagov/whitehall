describe('GOVUK.Modules.EditionForm', function () {
  let form, currentYear

  beforeEach(function () {
    form = document.createElement('form')
    form.setAttribute('data-module', 'EditionForm')
    currentYear = new Date().getFullYear()
  })

  describe('#setupSubtypeFormatAdviceEventListener', function () {
    beforeEach(function () {
      form.innerHTML = subtypeFields() + localeFields() + associationsFields()
      const editionForm = new GOVUK.Modules.EditionForm(form)
      editionForm.init()
    })

    it('should render subtype guidance based when the subtype format select changes value', function () {
      const select = form.querySelector('#edition_news_article_type_id')

      select.value = '1'
      select.dispatchEvent(new Event('change'))
      const subtypeAdvice = form.querySelector(
        '.js-app-view-edition-form__subtype-format-advice'
      )

      expect(subtypeAdvice.innerHTML).toBe(
        '<strong>Use this subformat for…</strong> <p>News written exclusively for GOV.UK which users need, can act on and can’t get from other sources. Avoid duplicating press releases.</p>'
      )
    })

    it('should remove subtype guidance when the subtype format select is unselected', function () {
      const select = form.querySelector('#edition_news_article_type_id')

      select.value = '1'
      select.dispatchEvent(new Event('change'))
      select.value = '0'
      select.dispatchEvent(new Event('change'))

      const subtypeAdvice = form.querySelector(
        '.js-app-view-edition-form__subtype-format-advice'
      )
      expect(subtypeAdvice).toBe(null)
    })
  })

  describe('#setupSpeechSubtypeEventListeners', function () {
    beforeEach(function () {
      form.innerHTML = speechFields(currentYear)
      const editionForm = new GOVUK.Modules.EditionForm(form)
      editionForm.init()
    })

    it('updates the labels of speaker fields to `writer` and hides and resets the location field when authored_article is selected ', function () {
      const select = form.querySelector('#edition_speech_type_id')
      const deliveredByLabel = form.querySelector(
        '#edition_role_appointment .govuk-fieldset__heading'
      )
      const hasProfileRadioLabel = form.querySelector(
        '#edition_role_appointment label[for="edition_role_appointment_speaker_on_govuk"]'
      )
      const noProfileRadioLabel = form.querySelector(
        '#edition_role_appointment label[for="edition_role_appointment_speaker_not_on_govuk"]'
      )
      const deliveredOnLabel = form.querySelector(
        '#edition_delivered_on .govuk-fieldset__legend'
      )
      const locationDiv = form.querySelector(
        '.js-app-view-edit-edition__speech-location-field'
      )
      const locationInput = locationDiv.querySelector(
        'input[name="edition[location]"]'
      )

      select.value = '6'
      locationInput.value = 'To be deleted.'
      select.dispatchEvent(new Event('change'))

      expect(deliveredByLabel.textContent).toEqual('Writer (required)')
      expect(hasProfileRadioLabel.textContent).toEqual(
        'Writer has a profile on GOV.UK'
      )
      expect(noProfileRadioLabel.textContent).toEqual(
        'Writer does not have a profile on GOV.UK'
      )
      expect(deliveredOnLabel.textContent).toEqual('Written on')
      expect(locationDiv.classList[1]).toEqual(
        'app-view-edit-edition__speech-location--hidden'
      )
      expect(locationInput.value).toEqual('')
    })

    it('updates the labels of speaker fields to `speaker` and shows the location field when the authored_article is deselected ', function () {
      const select = form.querySelector('#edition_speech_type_id')
      const deliveredByLabel = form.querySelector(
        '#edition_role_appointment .govuk-fieldset__heading'
      )
      const hasProfileRadioLabel = form.querySelector(
        '#edition_role_appointment label[for="edition_role_appointment_speaker_on_govuk"]'
      )
      const noProfileRadioLabel = form.querySelector(
        '#edition_role_appointment label[for="edition_role_appointment_speaker_not_on_govuk"]'
      )
      const deliveredOnLabel = form.querySelector(
        '#edition_delivered_on .govuk-fieldset__legend'
      )
      const locationDiv = form.querySelector(
        '.js-app-view-edit-edition__speech-location-field'
      )
      const locationInput = locationDiv.querySelector(
        'input[name="edition[location]"]'
      )

      select.value = '6'
      locationInput.value = 'To be deleted.'
      select.dispatchEvent(new Event('change'))

      select.value = '1'
      select.dispatchEvent(new Event('change'))

      expect(deliveredByLabel.textContent).toEqual('Speaker (required)')
      expect(hasProfileRadioLabel.textContent).toEqual(
        'Speaker has a profile on GOV.UK'
      )
      expect(noProfileRadioLabel.textContent).toEqual(
        'Speaker does not have a profile on GOV.UK'
      )
      expect(deliveredOnLabel.textContent).toEqual('Delivered on')
      expect(locationDiv.classList.length).toEqual(1)
      expect(locationDiv.classList[0]).toEqual(
        'js-app-view-edit-edition__speech-location-field'
      )
    })

    describe('#setupSpeechDeliverdOnWarningEventListener', function () {
      beforeEach(function () {
        form.innerHTML = speechFields(currentYear)
        const editionForm = new GOVUK.Modules.EditionForm(form)
        editionForm.init()
      })

      it('shows the speech delivered_on in future warning to the user when they input a date in the future', function () {
        const deliveredOnFieldset = form.querySelector('#edition_delivered_on')
        deliveredOnFieldset.querySelector('input').value = '1'
        deliveredOnFieldset.querySelectorAll('input')[1].value = '1'
        deliveredOnFieldset.querySelectorAll('input')[2].value = currentYear + 1

        deliveredOnFieldset
          .querySelector('input')
          .dispatchEvent(new Event('change'))

        const warning = form.querySelector(
          '.js-app-view-edit-edition__delivered-on-warning'
        )

        expect(warning.classList).not.toContain(
          'app-view-edit-edition__delivered-on-warning--hidden'
        )
      })

      it('does not show the speech delivered_on in future warning to the user when they select a date in the past', function () {
        const deliveredOnFieldset = form.querySelector('#edition_delivered_on')
        deliveredOnFieldset.querySelector('input').value = '1'
        deliveredOnFieldset.querySelectorAll('input')[1].value = '1'
        deliveredOnFieldset.querySelectorAll('input')[2].value = currentYear

        deliveredOnFieldset.dispatchEvent(new Event('change'))

        const warning = form.querySelector(
          '.js-app-view-edit-edition__delivered-on-warning'
        )

        expect(warning.classList).toContain(
          'app-view-edit-edition__delivered-on-warning--hidden'
        )
      })
    })
  })

  function subtypeFields() {
    return (
      '<div class="app-view-edition-form__subtype-fields js-app-view-edition-form__subtype-fields" data-format-advice="{&quot;1&quot;:&quot;\u003cp\u003eNews written exclusively for GOV.UK which users need, can act on and can’t get from other sources. Avoid duplicating press releases.\u003c/p\u003e&quot;,&quot;2&quot;:&quot;\u003cp\u003eUnedited press releases as sent to the media, and official statements from the organisation or a minister.\u003c/p\u003e\u003cp\u003eDo \u003cem\u003enot\u003c/em\u003e use for: statements to Parliament. Use the ‘Speech’ format for those.\u003c/p\u003e&quot;,&quot;3&quot;:&quot;\u003cp\u003eGovernment statements in response to media coverage, such as rebuttals and ‘myth busters’.\u003c/p\u003e\u003cp\u003eDo \u003cem\u003enot\u003c/em\u003e use for: statements to Parliament. Use the \'Speech\' format for those.\u003c/p\u003e&quot;,&quot;4&quot;:&quot;\u003cp\u003eAnnouncements specific to one or more world location. Do not duplicate news published by another department.\u003c/p\u003e&quot;}">' +
      '<div class="govuk-form-group gem-c-select">' +
      '<label class="govuk-label govuk-label--s" for="edition_news_article_type_id">News article type</label>' +
      '<select name="edition[news_article_type_id]" id="edition_news_article_type_id" class="govuk-select gem-c-select__select--full-width">' +
      '<option value=""></option>' +
      '<option value="1">News story</option>' +
      '<option value="2">Press release</option>' +
      '<option value="3">Government response</option>' +
      '<option value="4">World news story</option></select>' +
      '</div>' +
      '</div>'
    )
  }

  function localeFields() {
    return (
      '<div class="app-view-edit-edition__locale-field app-view-edit-edition__locale-field--hidden">' +
      '<input type="checkbox" name="edition[create_foreign_language_only]" id="edition_create_foreign_language_only-0" value="0" checked="checked">' +
      '<select name="edition[primary_locale]" id="edition_primary_locale" class="govuk-select gem-c-select__select--full-width">' +
      '<option value=""></option>' +
      '<option value="ar">العربيَّة (Arabic)</option>' +
      '<option value="az">Azeri (Azeri)</option>' +
      '<option value="be">Беларуская (Belarusian)</option>' +
      '</select>' +
      '</div>'
    )
  }

  function associationsFields() {
    return (
      '<div class="app-view-edit-edition__appointment-fields">' +
      '<select name="edition[role_appointment_ids][]" id="edition_role_appointment_ids-select">' +
      '<option value=""></option>' +
      '<option value="1" selected="selected">Random Lord 1</option>' +
      '<option value="2">Random Lord 2</option>' +
      '</select>' +
      '</div>' +
      '<div class="app-view-edit-edition__organisation-fields">' +
      '<select name="edition[lead_organisation_ids][]" id="edition_lead_organisation_ids_1">' +
      '<option value=""></option>' +
      '<option value="1" selected="selected">Org 1</option>' +
      '<option value="2">Org 2</option>' +
      '</select>' +
      '<select name="edition[lead_organisation_ids][]" id="edition_lead_organisation_ids_2">' +
      '<option value=""></option>' +
      '<option value="1">Org 1</option>' +
      '<option value="2" selected="selected">Org 2</option>' +
      '</select>' +
      '</div>' +
      '<div class="app-view-edit-edition__world-organisation-fields">' +
      '<select name="edition[world_location_ids][]" id="edition_world_location_ids-select">' +
      '<option value=""></option>' +
      '<option value="1" selected="selected">Country 1</option>' +
      '<option value="2">Country 2</option>' +
      '</select>' +
      '</div>'
    )
  }

  function speechFields() {
    return `
        '<div>' +
          '<div class="govuk-form-group gem-c-select">' +
            '<label class="govuk-label govuk-label--s" for="edition_speech_type_id">Speech type</label>' +
            '<select name="edition[speech_type_id]" id="edition_speech_type_id" class="govuk-select gem-c-select__select--full-width">' +
              '<option value=""></option>' +
              '<option value="1">Transcript</option>' +
              '<option value="2">Draft text</option>' +
              '<option value="3">Speaking notes</option>' +
              '<option value="4">Written statement to Parliament</option>' +
              '<option value="5">Oral statement to Parliament</option>' +
              '<option value="6">Authored article</option>' +
            '</select>' +
          '</div>' +
        '</div>' +

        '<div id="edition_role_appointment">' +
          '<fieldset class="govuk-fieldset">' +
             '<legend class="govuk-fieldset__legend">' +
                '<h2 class="govuk-fieldset__heading">Speaker (required)</h2>' +
             '</legend>' +
               '<input type="radio" name="speaker_radios" id="edition_role_appointment_speaker_on_govuk">' +
               '<label for="edition_role_appointment_speaker_on_govuk">Speaker has a profile on GOV.UK</label>' +
               '<input type="radio" name="speaker_radios" id="edition_role_appointment_speaker_not_on_govuk">' +
               '<label for="edition_role_appointment_speaker_not_on_govuk">Speaker does not have a profile on GOV.UK</label>' +
             '</div>' +
          '</fieldset>' +
        '</div>' +
        '<fieldset class="govuk-fieldset" id="edition_delivered_on">' +
          '<legend class="govuk-fieldset__legend govuk-fieldset__legend--l">Delivered on</legend>' +
          '<div class="app-c-datetime-fields__date-time-wrapper">' +
            '<input type="text" id="edition_delivered_on_3i" name="edition[delivered_on(3i)]" />' +
            '<input type="text" id="edition_delivered_on_2i" name="edition[delivered_on(2i)]" />' +
            '<input type="text" id="edition_delivered_on_1i" name="edition[delivered_on(1i)]" />' +
          '</div>' +
        '</fieldset>' +
        '<div class="js-app-view-edit-edition__delivered-on-warning app-view-edit-edition__delivered-on-warning--hidden">' +
        '</div>' +
        '<div class="js-app-view-edit-edition__speech-location-field">' +
          '<input name="edition[location]" type="text">' +
        '</div>'
      `
  }
})
