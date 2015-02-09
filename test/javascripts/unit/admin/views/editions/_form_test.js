module("admin-edition-form: ", {
  setup: function() {
    $('#qunit-fixture').append(
      '<form id="non-english" class="js-supports-non-english">' +
        '<fieldset class="js-hidden">' +
          '<label for="edition_primary_locale">Document language</label>' +
          '<select id="edition_primary_locale" name="edition[primary_locale]">' +
            '<option value="" selected="selected">Choose foreign language</option>' +
            '<option value="en" selected="selected">English (English)</option>' +
            '<option value="ar">العربية (Arabic)</option>' +
            '<option value="cy">Cymraeg (Welsh)</option>' +
          '</select>' +
          '<p class="warning">Warning: Foreign language documents do not support translations.</p>' +
        '</fieldset>' +
        '<fieldset>' +
          '<label for="edition_title">Title</label>' +
          '<input id="edition_title" name="edition[title]" size="30" type="text" />' +
        '</fieldset>' +
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
          '</fieldset>' +
      '</form>');

    GOVUK.adminEditionsForm.init({
      selector: 'form#non-english',
      right_to_left_locales:["ar"]
    });
    $('.js-hidden').hide();
  }
});

test("the fieldset containing the locale input fields should initially be hidden", function () {
  ok($('form#non-english:first-child fieldset').is(':hidden'), 'fieldset containing locale inputs is not hidden');
});

test("all other fieldsets should be visible", function () {
  ok($('form#non-english:not(:first-child fieldset)').is(':visible'), 'other fieldsets should still be visible');
});

test("inserts a link that reveals the locale input fields when clicked", function () {
  equal($('form#non-english a.foreign-language-only').length, 1, "A link exists for foreign-language only documents");

  $('a.foreign-language-only').click();
  ok($('form#non-english:first-child fieldset').is(':visible'), 'fieldset containing locale inputs becomes visible');
  ok($('form#non-english:not(:first-child fieldset)').is(':visible'), 'other fieldsets should still be visible');
});

test("cancelling foreign language only document hides and resets the locale fields", function () {
  $('a.foreign-language-only').click();

  // choose another language
  $('#edition_primary_locale').val('cy').change();
  equal($('#edition_primary_locale option:selected').val(), 'cy', 'foreign-language selected');

  // reset the form
  $('a.cancel-foreign-language-only').click();

  equal($('#edition_primary_locale option:selected').val(), '', 'locale reset back to English');
  ok($('form#non-english:first-child fieldset').is(':hidden'), 'fieldset containing locale inputs has become hidden');
});

test("selecting and deselecting right-to-left languages applies the appropriate classes to the fieldsets", function () {
  $('a.foreign-language-only').click();

  $('#edition_primary_locale').val('ar').change();
  ok($('form#non-english fieldset').hasClass('right-to-left'), 'form fieldsets have "right-to-left" class');

  $('#edition_primary_locale').val('cy').change();
  ok(!$('form#non-english fieldset').hasClass('right-to-left'), 'form fieldsets no longer have "right-to-left" class');

  // also resets on cancel
  $('#edition_primary_locale').val('ar').change();
  ok($('form#non-english fieldset').hasClass('right-to-left'), 'form fieldsets have "right-to-left" class');
  $('a.cancel-foreign-language-only').click();
  ok(!$('form#non-english fieldset').hasClass('right-to-left'), 'form fieldsets no longer have "right-to-left" class');
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

