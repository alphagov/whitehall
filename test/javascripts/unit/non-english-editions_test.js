module("non-english-editions: ", {
  setup: function() {
    this.$localeFieldsContainer = $(
      '<form id="non-english">' +
        '<fieldset>' +
          '<label for="edition_locale">Document language</label>' +
          '<select id="edition_locale" name="edition[locale]">' +
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
      '</form>');
    $('#qunit-fixture').append(this.$localeFieldsContainer);

    $('form#non-english').setupNonEnglishSupport();
  }
});

test("hides the fieldset containing the locale input fields", function () {
  ok($('form#non-english:first-child fieldset').is(':hidden'), 'fieldset containing locale inputs has become hidden');
});

test("does not hide other fieldsets", function () {
  ok($('form#non-english:first-child fieldset').is(':visible'), 'other fieldsets should still be visible');
});

test("inserts a link that reveals the locale input fields when clicked", function () {
  equal($('form#non-english a.foreign-language-only').length, 1, "A link exists for foreign-language only documents");

  $('a.foreign-language-only').click();
  ok($('form#non-english:first-child fieldset').is(':visible'), 'fieldset containing locale inputs becomes visible');
  ok($('form#non-english:first-child fieldset').is(':visible'), 'other fieldsets should still be visible');
});

test("cancelling foreign language only document hides and resets the locale fields", function () {
  $('a.foreign-language-only').click();

  // choose another language
  $('#edition_locale').val('cy');
  equal($('#edition_locale option:selected').val(), 'cy', 'foreign-language selected');

  // reset the form
  $('a.cancel-foreign-language-only').click();
  equal($('#edition_locale option:selected').val(), 'en', 'locale reset back to English');
  ok($('form#non-english:first-child fieldset').is(':hidden'), 'fieldset containing locale inputs has become hidden');
});

