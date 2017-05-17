var form =
  '<form id="non-english" class="js-supports-non-english"></form>'

var newsArticleTypeSelect =
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

var foreignLanguageFieldset =
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

var titleFieldset =
  '<fieldset>' +
    '<label for="edition_title">Title</label>' +
    '<input id="edition_title" name="edition[title]" size="30" type="text" />' +
  '</fieldset>'

var firstPublishedAtFieldset =
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
          '<option value="02" selected="selected">02</option>' +
          '<option value="03">03</option>' +
        '</select>' +
         ': <select class="date" id="edition_first_published_at_5i" name="edition[first_published_at(5i)]">' +
          '<option value=""></option>' +
          '<option value="00">00</option>' +
          '<option value="01">01</option>' +
          '<option value="02">02</option>' +
          '<option value="03" selected="selected">03</option>' +
        '</select>' +
      '<span class="explanation">Only complete this field if the document is not new.</span>' +
    '</div>' +
  '</fieldset>'

module("admin-edition-form-foreign-language: ", {
  setup: function() {
    $('#qunit-fixture').append(form)
    $('form').append(foreignLanguageFieldset)
    $('form').append(titleFieldset)

    GOVUK.adminEditionsForm.init({
      selector: 'form#non-english',
      right_to_left_locales:["ar"]
    });
    $('.js-hidden').hide();
  }
});

test("the div containing the locale input fields should initially be hidden", function () {
  ok($('div.foreign-language-select').is(':hidden'), 'div containing locale inputs is not hidden');
});

test("checking 'Create a foreign language only news article' reveals the locale input fields", function () {
  $('input#create_foreign_language_only').click()

  ok($('div.foreign-language-select').is(':visible'), 'div containing locale inputs becomes visible');
});

test("unchecking 'Create a foreign language only news article' hides and resets the locale fields", function () {
  $('input#create_foreign_language_only').click()
  ok($('div.foreign-language-select').is(':visible'), 'div containing locale inputs has become visible');

  // choose another language
  $('#edition_primary_locale').val('cy').change();
  equal($('#edition_primary_locale option:selected').val(), 'cy', 'foreign-language selected');

  // reset the form
  $('input#create_foreign_language_only').click()

  equal($('#edition_primary_locale option:selected').val(), '', 'locale reset back to English');
  ok($('div.foreign-language-select').is(':hidden'), 'div containing locale inputs has become hidden');
});

test("selecting and deselecting right-to-left languages applies the appropriate classes to the fieldsets", function () {
  $('input#create_foreign_language_only').click()

  $('#edition_primary_locale').val('ar').change();
  ok($('form#non-english fieldset').hasClass('right-to-left'), 'form fieldsets have "right-to-left" class');

  $('#edition_primary_locale').val('cy').change();
  ok(!$('form#non-english fieldset').hasClass('right-to-left'), 'form fieldsets no longer have "right-to-left" class');

  // also resets on cancel
  $('#edition_primary_locale').val('ar').change();
  ok($('form#non-english fieldset').hasClass('right-to-left'), 'form fieldsets have "right-to-left" class');
  $('input#create_foreign_language_only').click()
  ok(!$('form#non-english fieldset').hasClass('right-to-left'), 'form fieldsets no longer have "right-to-left" class');
});

module("admin-edition-form-foreign-language-for-news-articles: ", {
  setup: function() {
    $('#qunit-fixture').append(form)
    $('form').append(newsArticleTypeSelect)
    $('form').append(foreignLanguageFieldset)
    $('form').append(titleFieldset)

    GOVUK.adminEditionsForm.init({
      selector: 'form#non-english',
      right_to_left_locales:["ar"]
    });
    $('.js-hidden').hide();
  }
});

test("the foreign language fieldset should initially be hidden", function () {
  ok($('fieldset.foreign-language').is(':hidden'), 'fieldset containing foreign language options is not hidden');
});

test("the foreign language fieldset should only be visible when selecting the 'World news story' News Article type", function () {
  $select = $('select#edition_news_article_type_id')

  $select.find("option:contains(News story)").prop('selected', true).change();
  ok($('fieldset.foreign-language').is(':hidden'), 'fieldset containing foreign language options is not hidden');

  $select.find("option:contains(Press release)").prop('selected', true).change();
  ok($('fieldset.foreign-language').is(':hidden'), 'fieldset containing foreign language options is not hidden');

  $select.find("option:contains(Government response)").prop('selected', true).change();
  ok($('fieldset.foreign-language').is(':hidden'), 'fieldset containing foreign language options is not hidden');

  $select.find("option:contains(World news story)").prop('selected', true).change();
  ok($('fieldset.foreign-language').is(':visible'), 'fieldset containing foreign language options is not visible');
});

test("unselecting 'World news story' hides and resets the locale fields", function () {
  $select = $('select#edition_news_article_type_id')

  $select.find("option:contains(World news story)").prop('selected', true).change();
  ok($('fieldset.foreign-language').is(':visible'), 'fieldset containing foreign language options is not visible');

  $('input#create_foreign_language_only').click()
  ok($('div.foreign-language-select').is(':visible'), 'div containing locale inputs has become visible');

  $('#edition_primary_locale').val('cy').change();
  equal($('#edition_primary_locale option:selected').val(), 'cy', 'foreign-language selected');

  $select.find("option:contains(News story)").prop('selected', true).change();

  equal($('#edition_primary_locale option:selected').val(), '', 'locale reset back to English');
  ok($('fieldset.foreign-language').is(':hidden'), 'fieldset containing foreign language options is not hidden');
});

module("admin-edition-form-first-published-at: ", {
  setup: function() {
    $('#qunit-fixture').append(form)
    $('form').append(firstPublishedAtFieldset)

    GOVUK.adminEditionsForm.init({
      selector: 'form#non-english',
      right_to_left_locales:["ar"]
    });
    $('.js-hidden').hide();
  }
});

test("first_published time fields default to 00 if not set", function() {
  // original field values should not be changed
  equal($('#edition_first_published_at_4i').val(), '02', 'hour field has original value');
  equal($('#edition_first_published_at_5i').val(), '03', 'minute field has original value');

  $('#edition_first_published_at_4i').val('');
  $('#edition_first_published_at_5i').val('');
  // rerun init script now that time fields have blank value
  GOVUK.adminEditionsForm.toggleFirstPublishedDate();
  equal($('#edition_first_published_at_4i').val(), '00', 'empty hour field defaulted to 00');
  equal($('#edition_first_published_at_5i').val(), '00', 'empty minute field defaulted to 00');
  // date field should not be changed
  equal($('#edition_first_published_at_3i').val(), '', 'empty day field not changed');
});

test("previously_published radio buttons toggle visibility of first_published date selector", function() {
  ok($('.js-show-first-published').is(':hidden'), 'date selector hidden by default');
  $('#edition_previously_published_true').click();
  ok($('.js-show-first-published').is(':visible'), 'date selector shown when "previously published" selected');

  $('#edition_previously_published_false').click();
  ok($('.js-show-first-published').is(':hidden'), 'date selector hidden when "document is new" selected');
});
