describe('GOVUK.adminEditionsForm', function () {
  var form

  beforeEach(function () {
    form = $('<form id="non-english" class="js-supports-non-english" />')
    $(document.body).append(form)
  })

  afterEach(function () {
    form.remove()
  })

  describe('foreign language handling', function () {
    beforeEach(function () {
      form.append(foreignLanguageFieldset(), titleFieldset())
      GOVUK.adminEditionsForm.init({
        selector: 'form#non-english',
        right_to_left_locales: ['ar']
      })
      form.find('.js-hidden').hide()
    })

    it('initially hides the locale input', function () {
      expect(form.find('.foreign-language-select').is(':hidden')).toBeTrue()
    })

    it('shows and hides the locale input when foreign language only checbox is toggled', function () {
      form.find('#create_foreign_language_only').click()
      expect(form.find('.foreign-language-select').is(':visible')).toBeTrue()
      form.find('#create_foreign_language_only').click()
      expect(form.find('.foreign-language-select').is(':visible')).toBeFalse()
    })

    it('applies classes to the fieldsets when a right-to-left language is selected', function () {
      form.find('#create_foreign_language_only').click()
      form.find('#edition_primary_locale').val('ar').change()
      expect(form.find('fieldset').hasClass('right-to-left')).toBeTrue()
    })

    it('resets fieldset classes when a right-to-left language is unselected', function () {
      form.find('#create_foreign_language_only').click()
      form.find('#edition_primary_locale').val('ar').change()
      form.find('#edition_primary_locale').val('cy').change()
      expect(form.find('fieldset').hasClass('right-to-left')).toBeFalse()
    })
  })

  describe('foreign language handling in world news stories', function () {
    beforeEach(function () {
      form.append(newsArticleTypeSelect(), foreignLanguageFieldset(), titleFieldset())
      GOVUK.adminEditionsForm.init({
        selector: 'form#non-english',
        right_to_left_locales: ['ar']
      })
      form.find('.js-hidden').hide()
    })

    it('shows the foreign language options when a "World news story" is selected', function () {
      form.find('#edition_news_article_type_id').val('2').change() // Press release
      expect(form.find('.foreign-language').is(':hidden')).toBeTrue()
      form.find('#edition_news_article_type_id').val('4').change() // World news story
      expect(form.find('.foreign-language').is(':hidden')).toBeFalse()
    })

    it('hides and resets the foreign language options when a "World news story" is unselected', function () {
      form.find('#edition_news_article_type_id').val('4').change() // World news story
      form.find('#create_foreign_language_only').click()
      form.find('#edition_primary_locale').val('cy')
      form.find('#edition_news_article_type_id').val('2').change() // Press release

      expect(form.find('.foreign-language').is(':hidden')).toBeTrue()
      expect(form.find('#create_foreign_language_only').prop('checked')).toBeFalse()
      expect(form.find('#edition_primary_locale').val()).toEqual('')
    })
  })

  describe('image uploading', function () {
    beforeEach(function () {
      form.append(imageFieldset())
      GOVUK.adminEditionsForm.init({
        selector: 'form#non-english',
        right_to_left_locales: ['ar']
      })
      form.find('.js-hidden').hide()
    })

    it('defaults to hiding the image upload', function () {
      expect(form.find('.js-show-image-uploader').is(':hidden')).toBeTrue()
    })

    it("doesn't show an image upload field when no-image is selected", function () {
      form.find('#edition_image_display_option_no_image').click()
      expect(form.find('.js-show-image-uploader').is(':hidden')).toBeTrue()
    })

    it("doesn't show an image upload field when organisation-image is selected", function () {
      form.find('#edition_image_display_option_organisation_image').click()
      expect(form.find('.js-show-image-uploader').is(':hidden')).toBeTrue()
    })

    it('shows an image upload field when custom image is selected', function () {
      form.find('#edition_image_display_option_custom_image').click()
      expect(form.find('.js-show-image-uploader').is(':hidden')).toBeFalse()
    })
  })

  describe('first published at fields', function () {
    beforeEach(function () {
      form.append(firstPublishedAtFieldset())
      GOVUK.adminEditionsForm.init({
        selector: 'form#non-english',
        right_to_left_locales: ['ar']
      })
      form.find('.js-hidden').hide()
    })

    it('shows first published field based on previously published radio buttons', function () {
      expect(form.find('.js-show-first-published').is(':hidden')).toBeTrue()
      form.find('#edition_previously_published_true').click()
      expect(form.find('.js-show-first-published').is(':hidden')).toBeFalse()
      form.find('#edition_previously_published_false').click()
      expect(form.find('.js-show-first-published').is(':hidden')).toBeTrue()
    })

    it('defaults the time to 00:00', function () {
      expect(form.find('#edition_first_published_at_4i').val()).toEqual('00')
      expect(form.find('#edition_first_published_at_5i').val()).toEqual('00')
    })
  })

  describe('news article role appointments', function () {
    beforeEach(function () {
      form.append(newsArticleTypeSelect(), titleFieldset(), roleAppointmentsFieldset())
      GOVUK.adminEditionsForm.init({
        selector: 'form#non-english',
        right_to_left_locales: ['ar']
      })
      form.find('.js-hidden').hide()
    })

    it('shows the role appointments field by default', function () {
      expect(form.find('fieldset.role-appointments').is(':visible')).toBeTrue()
    })

    it('hides and resets the role appointments field when a "World News Story" is selected', function () {
      form.find('#edition_role_appointment_ids').val(['3849', '3850'])
      form.find('#edition_news_article_type_id').val('4').change() // World news story
      expect(form.find('fieldset.role-appointments').is(':visible')).toBeFalse()
      expect(form.find('#edition_role_appointment_ids').val()).toEqual(null)
    })

    it('shows the role appointments field when a "World News Story" is unselected', function () {
      form.find('#edition_news_article_type_id').val('4').change() // World news story
      expect(form.find('fieldset.role-appointments').is(':visible')).toBeFalse()
      form.find('#edition_news_article_type_id').val('2').change() // Press release
      expect(form.find('fieldset.role-appointments').is(':visible')).toBeTrue()
    })
  })

  describe('news article worldwide organisation', function () {
    beforeEach(function () {
      form.append(newsArticleTypeSelect(), titleFieldset(), worldwideOrganisationsFieldset())
      GOVUK.adminEditionsForm.init({
        selector: 'form#non-english',
        right_to_left_locales: ['ar']
      })
      form.find('.js-hidden').hide()
    })

    it('hides the worldwide organisation fields by default', function () {
      expect(form.find('fieldset.worldwide-organisations').is(':hidden')).toBeTrue()
    })

    it('shows the worldwide organisation fields when a "World News Story" is selected', function () {
      form.find('#edition_news_article_type_id').val('4').change() // World news story
      expect(form.find('fieldset.worldwide-organisations').is(':hidden')).toBeFalse()
    })

    it('hides and resets the worldwide organisation fields when a "World News Story" is unselected', function () {
      form.find('#edition_news_article_type_id').val('4').change() // World news story
      expect(form.find('fieldset.worldwide-organisations').is(':hidden')).toBeFalse()
      form.find('#edition_worldwide_organisation_ids').val(['1', '2'])

      form.find('#edition_news_article_type_id').val('2').change() // Press release
      expect(form.find('fieldset.worldwide-organisations').is(':hidden')).toBeTrue()
      expect(form.find('#edition_worldwide_organisation_ids').val()).toEqual(null)
    })
  })

  describe('news article organisation', function () {
    beforeEach(function () {
      form.append(newsArticleTypeSelect(), titleFieldset(), organisationsFieldset())
      GOVUK.adminEditionsForm.init({
        selector: 'form#non-english',
        right_to_left_locales: ['ar']
      })
      form.find('.js-hidden').hide()
    })

    it('shows the organisation fields by default', function () {
      expect(form.find('fieldset.organisations').is(':visible')).toBeTrue()
    })

    it('hides and resets the organisation fields when a "World News Story" is selected', function () {
      form.find('#edition_lead_organisation_ids_1').val('1212')
      form.find('#edition_supporting_organisation_ids_1').val('1025')
      form.find('#edition_news_article_type_id').val('4').change() // World news story
      expect(form.find('fieldset.organisations').is(':visible')).toBeFalse()
      expect(form.find('#edition_lead_organisation_ids_1').val()).toEqual('')
      expect(form.find('#edition_supporting_organisation_ids_1').val()).toEqual('')
    })

    it('shows the organisations field when a "World News Story" is unselected', function () {
      form.find('#edition_news_article_type_id').val('4').change() // World news story
      expect(form.find('fieldset.organisations').is(':visible')).toBeFalse()
      form.find('#edition_news_article_type_id').val('2').change() // Press release
      expect(form.find('fieldset.organisations').is(':visible')).toBeTrue()
    })
  })

  function newsArticleTypeSelect () {
    return $(
      '<div class="form-group">' +
        '<label class="required" for="edition_news_article_type_id">News article type</label>' +
        '<select class="chzn-select form-control subtype"' +
                'data-placeholder="Choose News article type…"' +
                'data-format-advice="' +
                  '{&quot;1&quot;:&quot;<p>News written exclusively for GOV.UK which users need, can act on and can’t get from other sources. Avoid duplicating press releases.</p>&quot;,' +
                  '&quot;2&quot;:&quot;<p>Unedited press releases as sent to the media, and official statements from the organisation or a minister.</p><p>Do <em>not</em> use for: statements to Parliament. Use the “Speech” format for those.</p>&quot;,' +
                  '&quot;3&quot;:&quot;<p>Government statements in response to media coverage, such as rebuttals and ‘myth busters’.</p><p>Do <em>not</em> use for: statements to Parliament. Use the “Speech” format for those.</p>&quot;,' +
                  '&quot;4&quot;:&quot;<p>Announcements specific to one or more world location. Don’t duplicate news published by another department.</p>&quot;,&quot;999&quot;:&quot;<p>DO NOT USE. This is a legacy category for content created before sub-types existed.</p>&quot;}"' +
                'name="edition[news_article_type_id]"' +
                'id="edition_news_article_type_id">' +
          '<optgroup label="Common types">' +
            '<option value="1">News story</option>' +
            '<option value="2">Press release</option>' +
            '<option value="3">Government response</option>' +
            '<option value="4">World news story</option>' +
          '</optgroup>' +
        '</select>' +
      '</div>'
    )
  }

  function foreignLanguageFieldset () {
    return $(
      '<fieldset class="foreign-language">' +
        '<div class="checkbox">' +
          '<label class="checkbox" for="create_foreign_language_only">' +
            '<input type="checkbox" name="create_foreign_language_only" id="create_foreign_language_only" value="1" /> Create a foreign language only news article' +
          '</label>' +
        '</div>' +
        '<div class="form-group foreign-language-select js-hidden">' +
          '<label for="edition_primary_locale">Document language</label>' +
          '<div class="form-inline add-label-margin">' +
            '<select class="form-control input-md-6" name="edition[primary_locale]" id="edition_primary_locale">' +
              '<option value="">Choose foreign language...</option>' +
              '<option value="ar">العربية (Arabic)</option>' +
              '<option value="cy">Cymraeg (Welsh)</option>' +
            '</select>' +
          '</div>' +
          '<p class="warning">Warning: News stories without an English version cannot have other translations.</p>' +
        '</div>' +
      '</fieldset>'
    )
  }

  function titleFieldset () {
    return $(
      '<fieldset>' +
        '<label for="edition_title">Title</label>' +
        '<input id="edition_title" name="edition[title]" size="30" type="text" />' +
      '</fieldset>'
    )
  }

  function firstPublishedAtFieldset () {
    return $(
      '<fieldset class="first-published-date well">' +
        '<p class="required">This document <span>*</span></p>' +
        '<label class="radio" for="edition_previously_published_false">' +
          '<input id="edition_previously_published_false" name="edition[previously_published]" type="radio" value="true">' +
          'has never been published before. It is new.' +
      '</label>' +
      '<label class="radio" for="edition_previously_published_true">' +
        '<input id="edition_previously_published_true" name="edition[previously_published]" type="radio" value="false">' +
        'has previously been published on another website.' +
      '</label>' +
        '<div class="js-show-first-published" style="display: none;">' +
            '<label class="required extra-label" for="edition_first_published_at">Its original publication date was <span>*</span></label>' +
            '<select class="date" id="edition_first_published_at_1i" name="edition[first_published_at(1i)]">' +
              '<option value=""></option>' +
              '<option value="2014">2014</option>' +
              '<option value="2013">2013</option>' +
              '<option value="2012">2012</option>' +
            '</select>' +
            '<select class="date" id="edition_first_published_at_2i" name="edition[first_published_at(2i)]">' +
              '<option value=""></option>' +
              '<option value="1">January</option>' +
              '<option value="2">February</option>' +
              '<option value="3">March</option>' +
            '</select>' +
            '<select class="date" id="edition_first_published_at_3i" name="edition[first_published_at(3i)]">' +
              '<option value=""></option>' +
              '<option value="1">1</option>' +
              '<option value="2">2</option>' +
              '<option value="3">3</option>' +
            '</select>' +
             '— <select class="date" id="edition_first_published_at_4i" name="edition[first_published_at(4i)]">' +
              '<option value=""></option>' +
              '<option value="00">00</option>' +
              '<option value="01">01</option>' +
              '<option value="02">02</option>' +
              '<option value="03">03</option>' +
            '</select>' +
             ': <select class="date" id="edition_first_published_at_5i" name="edition[first_published_at(5i)]">' +
              '<option value=""></option>' +
              '<option value="00">00</option>' +
              '<option value="01">01</option>' +
              '<option value="02">02</option>' +
              '<option value="03">03</option>' +
            '</select>' +
          '<span class="explanation">Only complete this field if the document is not new.</span>' +
        '</div>' +
      '</fieldset>'
    )
  }

  function imageFieldset () {
    return $(
      '<fieldset class="image_section">' +
        '<div class="radio">' +
          '<label for="edition_image_display_option">' +
            '<input type="radio" value="no_image" name="edition[image_display_option]" id="edition_image_display_option_no_image">' +
            '<strong>Dont use an image</strong>' +
            '<p class="hint">No image will be shown on page</p>' +
          '</label>' +
        '</div>' +
        '<div class="radio">' +
          '<label class="radio" for="edition_image_display_option">' +
            '<input type="radio" value="custom_image" name="edition[image_display_option]" id="edition_image_display_option_custom_image">' +
            '<strong>Use the default organisation image</strong>' +
            '<p class="hint">The image set in the organisation page will be shown</p>' +
          '</label>' +
        '</div>' +
        '<div class="radio">' +
          '<label class="radio" for="edition_image_display_option">' +
            '<input type="radio" value="organisation_image" name="edition[image_display_option]" id="edition_image_display_option_organisation_image">' +
            '<strong>Use a custom image</strong>' +
            '<p class="hint">Upload a custom image</p>' +
          '</label>' +
        '</div>' +
        '<div class="js-show-image-uploader show-image-uploader">' +
          '<fieldset id="image_fields" class="images multiple_file_uploads">' +
            '<div class="file_upload well">' +
              '<h3 class="remove-top-margin">New image</h3>' +
              '<p>Images must be 960px wide and 640px tall.</p>' +
              '<div class="form-group"><label for="edition_images_attributes_0_image_data_attributes_file">File</label><input class="js-upload-image-input" type="file" name="edition[images_attributes][0][image_data_attributes][file]" id="edition_images_attributes_0_image_data_attributes_file"><input type="hidden" name="edition[images_attributes][0][image_data_attributes][file_cache]" id="edition_images_attributes_0_image_data_attributes_file_cache"></div>' +
              '<div class="form-group"><label for="edition_images_attributes_0_alt_text">Alt text</label><input class="form-control" type="text" name="edition[images_attributes][0][alt_text]" id="edition_images_attributes_0_alt_text"></div>' +
              '<div class="form-group"><label for="edition_images_attributes_0_caption">Caption</label><div class="highlightTextarea"><div class="highlighterContainer"><div class="highlighter"></div></div>' +
              '<textarea rows="2" class="form-control" name="edition[images_attributes][0][caption]" id="edition_images_attributes_0_caption"></textarea></div></div>' +
            '</div>' +
          '</fieldset>' +
        '</div>' +
      '</fieldset> '
    )
  }

  function roleAppointmentsFieldset () {
    return $(
      '<fieldset class="role-appointments">' +
        '<label for="edition_role_appointment_ids">Ministers</label>' +
        '<input name="edition[role_appointment_ids][]" type="hidden" value="" />' +
        '<select multiple="multiple" class="chzn-select form-control" data-placeholder="Choose ministers…" name="edition[role_appointment_ids][]" id="edition_role_appointment_ids">' +
          '<option value=""></option>' +
          '<option value="3850">Lord O&#39;Shaughnessy, Parliamentary Under Secretary of State for Health, Department of Health</option>' +
          '<option value="3849">Lord O&#39;Shaughnessy, Lord in Waiting (Government Whip), Office of the Leader of the House of Lords</option>' +
          '<option value="1148">Henry Addington 1st Viscount Sidmouth, Prime Minister (17 March 1801 to 10 May 1804), Cabinet Office and Prime Minister&#39;s Office, 10 Downing Street</option>' +
        '</select>' +
      '</fieldset>'
    )
  }

  function worldwideOrganisationsFieldset () {
    return $(
      '<fieldset class="worldwide-organisations">' +
        '<label class="required" for="edition_worldwide_organisation_ids">' +
          'Select the worldwide organisations associated with this news article' +
        '</label>' +
        '<input name="edition[worldwide_organisation_ids][]" type="hidden" value="" />' +
        '<select multiple="multiple" class="chzn-select form-control" data-placeholder="Worldwide organisations…" name="edition[worldwide_organisation_ids][]" id="edition_worldwide_organisation_ids">' +
          '<option value=""></option>' +
          '<option value="1">British High Commission Port of Spain</option>' +
          '<option value="2">British Embassy Lima</option>' +
          '<option value="3">British High Commission Kingston</option>' +
        '</select>' +
      '</fieldset>'
    )
  }

  function organisationsFieldset () {
    return $(
      '<fieldset class="named organisations">' +
        '<div class="row">' +
          '<fieldset class="named col-md-6 lead-organisations">' +
            '<legend>Lead organisations</legend>' +
            '<div class="form-group">' +
              '<label for="edition_edition[lead_organisation_ids][]">' +
                '<div class="add-label-margin">Organisation 1</div>' +
                '<div class="normal">' +
                  '<select name="edition[lead_organisation_ids][]" id="edition_lead_organisation_ids_1" class="chzn-select-non-ie form-control" data-placeholder="Choose a lead organisation which produced this document…">' +
                    '<option value=""></option>' +
                    '<option value="1212"> Northern Ireland Housing Executive  (NIHE)</option>' +
                    '<option value="1025">Academy for Justice Commissioning</option>' +
                  '</select>' +
                '</div>' +
              '</label>' +
            '</div>' +
          '</fieldset>' +
          '<fieldset class="named col-md-6 supporting-organisations">' +
            '<legend>Supporting organisations</legend>' +
            '<div class="form-group">' +
              '<label for="edition_edition[supporting_organisation_ids][]">' +
                '<div class="add-label-margin">Organisation 1</div>' +
                '<div class="normal">' +
                  '<select name="edition[supporting_organisation_ids][]" id="edition_supporting_organisation_ids_1" class="chzn-select-non-ie form-control" data-placeholder="Choose a supporting organisation which produced this document…">' +
                    '<option value=""></option>' +
                    '<option value="1212"> Northern Ireland Housing Executive  (NIHE)</option>' +
                    '<option value="1025">Academy for Justice Commissioning</option>' +
                  '</select>' +
                '</div>' +
              '</label>' +
            '</div>' +
          '</fieldset>' +
        '</div>' +
      '</fieldset>'
    )
  }
})
