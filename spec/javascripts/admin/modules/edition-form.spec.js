describe('GOVUK.Modules.EditionForm', function () {
  var form

  beforeEach(function () {
    form = document.createElement('form')
    form.setAttribute('data-module', 'EditionForm')
  })

  describe('#setupSubtypeFormatAdviceEventListener', function () {
    beforeEach(function () {
      form.innerHTML = subtypeFields() + localeFields() + associationsFields()
      var editionForm = new GOVUK.Modules.EditionForm(form)
      editionForm.init()
    })

    it('should render subtype guidance based when the subtype format select changes value', function () {
      var select = form.querySelector('#edition_news_article_type_id')

      select.value = '1'
      select.dispatchEvent(new Event('change'))
      var subtypeAdvice = form.querySelector('.js-app-view-edition-form__subtype-format-advice')

      expect(subtypeAdvice.innerHTML).toBe('<strong>Use this subformat for…</strong> <p>News written exclusively for GOV.UK which users need, can act on and can’t get from other sources. Avoid duplicating press releases.</p>')
    })

    it('should remove subtype guidance when the subtype format select is unselected', function () {
      var select = form.querySelector('#edition_news_article_type_id')

      select.value = '1'
      select.dispatchEvent(new Event('change'))
      select.value = '0'
      select.dispatchEvent(new Event('change'))

      var subtypeAdvice = form.querySelector('.js-app-view-edition-form__subtype-format-advice')
      expect(subtypeAdvice).toBe(null)
    })
  })

  describe('#setupWorldNewsStoryVisibilityToggle when a NewsArticle is a WorldNewsStory', function () {
    beforeEach(function () {
      form.innerHTML = subtypeFieldsWithWorldNewsStorySelected() + localeFields() + associationsFields()
      var editionForm = new GOVUK.Modules.EditionForm(form)
      editionForm.init()
    })

    it('should hide the ministers and organisation fields on page load', function () {
      var ministersFields = form.querySelector('.app-view-edit-edition__appointment-fields')
      var organisationFields = form.querySelector('.app-view-edit-edition__organisation-fields')

      expect(ministersFields.classList).toContain('app-view-edit-edition__appointment-fields--hidden')
      expect(organisationFields.classList).toContain('app-view-edit-edition__organisation-fields--hidden')
    })

    it('should reset the locale checkbox and select values when WorldNewsStory is deselected', function () {
      var select = form.querySelector('#edition_news_article_type_id')
      var localeCheckbox = form.querySelector('#edition_create_foreign_language_only-0')
      var localeSelect = form.querySelector('#edition_primary_locale')

      select.value = '4'
      select.dispatchEvent(new Event('change'))

      localeCheckbox.checked = true
      localeCheckbox.value = '1'
      localeSelect.value = 'ar'
      select.value = '1'
      select.dispatchEvent(new Event('change'))

      expect(localeCheckbox.value).toEqual('0')
      expect(localeCheckbox.checked).toEqual(false)
      expect(localeSelect.value).toEqual('')
    })
  })

  describe('#setupWorldNewsStoryVisibilityToggle when a NewsArticle is not a WorldNewsStory', function () {
    beforeEach(function () {
      form.innerHTML = subtypeFields() + localeFields() + associationsFields()
      var editionForm = new GOVUK.Modules.EditionForm(form)
      editionForm.init()
    })

    it('should hide the locale fields and world-location-fields on page load', function () {
      var localeFields = form.querySelector('.app-view-edit-edition__locale-field')
      var worldLocationFields = form.querySelector('.app-view-edit-edition__world-location-fields')

      expect(localeFields.classList).toContain('app-view-edit-edition__locale-field--hidden')
      expect(worldLocationFields.classList).toContain('app-view-edit-edition__world-location-fields--hidden')
    })

    it('should render the locale fields when WorldNewsStory is selected', function () {
      var select = form.querySelector('#edition_news_article_type_id')

      select.value = '4'
      select.dispatchEvent(new Event('change'))

      var localeFields = form.querySelector('.app-view-edit-edition__locale-field')

      expect(localeFields.style.display).not.toContain('app-view-edit-edition__locale-field--hidden')
    })
  })

  describe('#setupSpeechSubtypeEventListeners', function () {
    beforeEach(function () {
      form.innerHTML = speechFields() + associationsFields()
      var editionForm = new GOVUK.Modules.EditionForm(form)
      editionForm.init()
    })

    it('updates the labels of speaker fields to `writer` and hides and resets the location field when authored_article is selected ', function () {
      var select = form.querySelector('#edition_speech_type_id')
      var deliveredByLabel = form.querySelector('#edition_role_appointment .govuk-fieldset__heading')
      var hasProfileRadioLabel = form.querySelector('#edition_role_appointment label[for="edition_role_appointment_speaker_on_govuk"]')
      var noProfileRadioLabel = form.querySelector('#edition_role_appointment label[for="edition_role_appointment_speaker_not_on_govuk"]')
      var deliveredOnLabel = form.querySelector('#edition_delivered_on .govuk-fieldset__legend')
      var locationDiv = form.querySelector('.js-app-view-edit-edition__speech-location-field')
      var locationInput = locationDiv.querySelector('input[name="edition[location]"]')

      select.value = '6'
      locationInput.value = 'To be deleted.'
      select.dispatchEvent(new Event('change'))

      expect(deliveredByLabel.textContent).toEqual('Writer (required)')
      expect(hasProfileRadioLabel.textContent).toEqual('Writer has a profile on GOV.UK')
      expect(noProfileRadioLabel.textContent).toEqual('Writer does not have a profile on GOV.UK')
      expect(deliveredOnLabel.textContent).toEqual('Written on')
      expect(locationDiv.classList[1]).toEqual('app-view-edit-edition__speech-location--hidden')
      expect(locationInput.value).toEqual('')
    })

    it('updates the labels of speaker fields to `speaker` and shows the location field when the authored_article is deselected ', function () {
      var select = form.querySelector('#edition_speech_type_id')
      var deliveredByLabel = form.querySelector('#edition_role_appointment .govuk-fieldset__heading')
      var hasProfileRadioLabel = form.querySelector('#edition_role_appointment label[for="edition_role_appointment_speaker_on_govuk"]')
      var noProfileRadioLabel = form.querySelector('#edition_role_appointment label[for="edition_role_appointment_speaker_not_on_govuk"]')
      var deliveredOnLabel = form.querySelector('#edition_delivered_on .govuk-fieldset__legend')
      var locationDiv = form.querySelector('.js-app-view-edit-edition__speech-location-field')
      var locationInput = locationDiv.querySelector('input[name="edition[location]"]')

      select.value = '6'
      locationInput.value = 'To be deleted.'
      select.dispatchEvent(new Event('change'))

      select.value = '1'
      select.dispatchEvent(new Event('change'))

      expect(deliveredByLabel.textContent).toEqual('Speaker (required)')
      expect(hasProfileRadioLabel.textContent).toEqual('Speaker has a profile on GOV.UK')
      expect(noProfileRadioLabel.textContent).toEqual('Speaker does not have a profile on GOV.UK')
      expect(deliveredOnLabel.textContent).toEqual('Delivered on')
      expect(locationDiv.classList.length).toEqual(1)
      expect(locationDiv.classList[0]).toEqual('js-app-view-edit-edition__speech-location-field')
    })
  })

  function subtypeFields () {
    return (
      '<div class="app-view-edition-form__subtype-fields js-app-view-edition-form__subtype-fields" data-format-advice="{&quot;1&quot;:&quot;\u003cp\u003eNews written exclusively for GOV.UK which users need, can act on and can’t get from other sources. Avoid duplicating press releases.\u003c/p\u003e&quot;,&quot;2&quot;:&quot;\u003cp\u003eUnedited press releases as sent to the media, and official statements from the organisation or a minister.\u003c/p\u003e\u003cp\u003eDo \u003cem\u003enot\u003c/em\u003e use for: statements to Parliament. Use the “Speech” format for those.\u003c/p\u003e&quot;,&quot;3&quot;:&quot;\u003cp\u003eGovernment statements in response to media coverage, such as rebuttals and ‘myth busters’.\u003c/p\u003e\u003cp\u003eDo \u003cem\u003enot\u003c/em\u003e use for: statements to Parliament. Use the “Speech” format for those.\u003c/p\u003e&quot;,&quot;4&quot;:&quot;\u003cp\u003eAnnouncements specific to one or more world location. Don’t duplicate news published by another department.\u003c/p\u003e&quot;}">' +
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

  function subtypeFieldsWithWorldNewsStorySelected () {
    return (
      '<div class="app-view-edition-form__subtype-fields js-app-view-edition-form__subtype-fields" data-format-advice="{&quot;1&quot;:&quot;\u003cp\u003eNews written exclusively for GOV.UK which users need, can act on and can’t get from other sources. Avoid duplicating press releases.\u003c/p\u003e&quot;,&quot;2&quot;:&quot;\u003cp\u003eUnedited press releases as sent to the media, and official statements from the organisation or a minister.\u003c/p\u003e\u003cp\u003eDo \u003cem\u003enot\u003c/em\u003e use for: statements to Parliament. Use the “Speech” format for those.\u003c/p\u003e&quot;,&quot;3&quot;:&quot;\u003cp\u003eGovernment statements in response to media coverage, such as rebuttals and ‘myth busters’.\u003c/p\u003e\u003cp\u003eDo \u003cem\u003enot\u003c/em\u003e use for: statements to Parliament. Use the “Speech” format for those.\u003c/p\u003e&quot;,&quot;4&quot;:&quot;\u003cp\u003eAnnouncements specific to one or more world location. Don’t duplicate news published by another department.\u003c/p\u003e&quot;}">' +
        '<div class="govuk-form-group gem-c-select">' +
          '<label class="govuk-label govuk-label--s" for="edition_news_article_type_id">News article type</label>' +
          '<select name="edition[news_article_type_id]" id="edition_news_article_type_id" class="govuk-select gem-c-select__select--full-width">' +
            '<option value=""></option>' +
            '<option value="1">News story</option>' +
            '<option value="2">Press release</option>' +
            '<option value="3">Government response</option>' +
            '<option value="4" selected="selected">World news story</option></select>' +
        '</div>' +
      '</div>'
    )
  }

  function localeFields () {
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

  function associationsFields () {
    return (
      '<div class="app-view-edit-edition__appointment-fields">' +
      '</div>' +
      '<div class="app-view-edit-edition__organisation-fields">' +
      '</div>' +
      '<div class="app-view-edit-edition__world-location-fields">' +
      '</div>'
    )
  }

  function speechFields () {
    return (
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
      '</fieldset>' +

      '<div class="js-app-view-edit-edition__speech-location-field">' +
        '<input name="edition[location]" type="text">' +
      '</div>'
    )
  }
})
