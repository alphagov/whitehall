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

  describe('#setupWorldNewsStoryVisibilityToggle when a NewsArticle is a WorldNewsStory', function () {
    beforeEach(function () {
      form.innerHTML =
        subtypeFieldsWithWorldNewsStorySelected() +
        localeFields() +
        associationsFields()
      const editionForm = new GOVUK.Modules.EditionForm(form)
      editionForm.init()
    })

    it('should hide the ministers field & reset and hide the organisation fields on page load', function () {
      const ministersFields = form.querySelector(
        '.app-view-edit-edition__appointment-fields'
      )
      const organisationFields = form.querySelector(
        '.app-view-edit-edition__organisation-fields'
      )

      expect(ministersFields.classList).toContain(
        'app-view-edit-edition__appointment-fields--hidden'
      )
      expect(organisationFields.classList).toContain(
        'app-view-edit-edition__organisation-fields--hidden'
      )
      organisationFields.querySelectorAll('select').forEach(function (select) {
        expect(select.value).toBe('')
      })
    })

    it('should reset & hide the locale & world location fields, and show the organisation and ministers fields when WorldNewsStory is deselected', function () {
      const subtypeSelect = form.querySelector('#edition_news_article_type_id')
      const localeDiv = form.querySelector(
        '.app-view-edit-edition__locale-field'
      )
      const localeCheckbox = form.querySelector(
        '#edition_create_foreign_language_only-0'
      )
      const localeSelect = form.querySelector('#edition_primary_locale')

      const ministersDiv = form.querySelector(
        '.app-view-edit-edition__appointment-fields'
      )
      const organisationDiv = form.querySelector(
        '.app-view-edit-edition__organisation-fields'
      )
      const worldLocationDiv = form.querySelector(
        '.app-view-edit-edition__world-organisation-fields'
      )
      const worldLocationSelect = worldLocationDiv.querySelector('select')

      subtypeSelect.value = '4'
      subtypeSelect.dispatchEvent(new Event('change'))

      localeCheckbox.checked = true
      localeCheckbox.value = '1'
      localeSelect.value = 'ar'
      subtypeSelect.value = '1'
      worldLocationSelect.value = '1'

      subtypeSelect.dispatchEvent(new Event('change'))

      expect(localeDiv.classList).toContain(
        'app-view-edit-edition__locale-field--hidden'
      )
      expect(localeCheckbox.value).toEqual('0')
      expect(localeCheckbox.checked).toEqual(false)
      expect(localeSelect.value).toEqual('')

      expect(worldLocationDiv.classList).toContain(
        'app-view-edit-edition__world-organisation-fields--hidden'
      )
      expect(worldLocationSelect.value).toEqual('')

      expect(ministersDiv.classList).not.toContain(
        'app-view-edit-edition__ministers-fields--hidden'
      )
      expect(organisationDiv.classList).not.toContain(
        'app-view-edit-edition__organisation-fields--hidden'
      )
    })
  })

  describe('#setupWorldNewsStoryVisibilityToggle when a NewsArticle is not a WorldNewsStory', function () {
    beforeEach(function () {
      form.innerHTML = subtypeFields() + localeFields() + associationsFields()
      const editionForm = new GOVUK.Modules.EditionForm(form)
      editionForm.init()
    })

    it('should hide the locale fields and world-location-fields on page load', function () {
      const localeFields = form.querySelector(
        '.app-view-edit-edition__locale-field'
      )
      const worldLocationFields = form.querySelector(
        '.app-view-edit-edition__world-organisation-fields'
      )

      expect(localeFields.classList).toContain(
        'app-view-edit-edition__locale-field--hidden'
      )
      expect(worldLocationFields.classList).toContain(
        'app-view-edit-edition__world-organisation-fields--hidden'
      )
    })

    it('should show the locale & world location fields, and hide and reset the ministers & org fields when WorldNewsStory is selected', function () {
      const select = form.querySelector('#edition_news_article_type_id')

      select.value = '4'
      select.dispatchEvent(new Event('change'))

      const localeFields = form.querySelector(
        '.app-view-edit-edition__locale-field'
      )
      const ministersDiv = form.querySelector(
        '.app-view-edit-edition__appointment-fields'
      )
      const ministersSelect = ministersDiv.querySelector('select')
      const organisationDiv = form.querySelector(
        '.app-view-edit-edition__organisation-fields'
      )
      const organisationSelect1 = organisationDiv.querySelectorAll('select')[0]
      const organisationSelect2 = organisationDiv.querySelectorAll('select')[1]
      const worldLocationDiv = form.querySelector(
        '.app-view-edit-edition__world-organisation-fields'
      )

      expect(localeFields.classList).not.toContain(
        'app-view-edit-edition__locale-field--hidden'
      )
      expect(worldLocationDiv.classList).not.toContain(
        'app-view-edit-edition__world-organisation-fields--hidden'
      )
      expect(ministersDiv.classList).toContain(
        'app-view-edit-edition__appointment-fields--hidden'
      )
      expect(ministersSelect.value).toEqual('')
      expect(organisationDiv.classList).toContain(
        'app-view-edit-edition__organisation-fields--hidden'
      )
      expect(organisationSelect1.value).toEqual('')
      expect(organisationSelect2.value).toEqual('')
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

  describe('#setupUpdateDocumentSlugCheckbox', function () {
    beforeEach(function () {
      form.innerHTML = updateSlugCheckboxFields()
      const editionForm = new GOVUK.Modules.EditionForm(form)
      editionForm.init()
    })

    it('should hide the checkbox on page load', function () {
      const checkboxContainer = form.querySelector(
        '.js-update-document-slug-checkbox'
      )

      expect(checkboxContainer.classList).toContain(
        'app-view-edit-edition__update-slug-checkbox--hidden'
      )
    })

    it('should show the checkbox when the title input changes', function () {
      const titleInput = form.querySelector('#edition_title')
      const checkboxContainer = form.querySelector(
        '.js-update-document-slug-checkbox'
      )

      titleInput.value = 'New title'
      titleInput.dispatchEvent(new Event('input'))

      expect(checkboxContainer.classList).not.toContain(
        'app-view-edit-edition__update-slug-checkbox--hidden'
      )
    })

    it('should hide the checkbox when the title is reverted to original value', function () {
      const titleInput = form.querySelector('#edition_title')
      const checkboxContainer = form.querySelector(
        '.js-update-document-slug-checkbox'
      )
      const originalTitle = titleInput.value

      titleInput.value = 'New title'
      titleInput.dispatchEvent(new Event('input'))
      expect(checkboxContainer.classList).not.toContain(
        'app-view-edit-edition__update-slug-checkbox--hidden'
      )

      titleInput.value = originalTitle
      titleInput.dispatchEvent(new Event('input'))
      expect(checkboxContainer.classList).toContain(
        'app-view-edit-edition__update-slug-checkbox--hidden'
      )
    })
  })

  function subtypeFields() {
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

  function subtypeFieldsWithWorldNewsStorySelected() {
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

  function updateSlugCheckboxFields() {
    return (
      '<textarea name="edition[title]" class="govuk-textarea govuk-js-character-count" id="edition_title" rows="1">Original title</textarea>' +
      '<div class="js-update-document-slug-checkbox">' +
      '<input type="checkbox" name="edition[should_update_document_slug]" value="1">' +
      '<label>Update document slug</label>' +
      '</div>'
    )
  }
})
