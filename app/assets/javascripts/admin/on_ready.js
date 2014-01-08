GOVUK.init(GOVUK.ieHandler);
GOVUK.init(GOVUK.formsHelper);
GOVUK.init(GOVUK.navBarHelper);
GOVUK.init(GOVUK.tabs);

jQuery(document).ready(function($) {
  if(typeof GOVUK === 'undefined') { window.GOVUK = {}; }

  GOVUK.doubleClickProtection();
  GOVUK.duplicateFields.init();
  GOVUK.formChangeProtection.init($('#edit_edition'), 'You have unsaved changes that will be lost if you leave this page.');
  GOVUK.hideClosedAtDates();
  GOVUK.toggleCustomLogoField();

  $("form.js-supports-non-english").setupNonEnglishSupport();

  if ($('#diff').length > 0) {
    GOVUK.diff('title');
    GOVUK.diff('summary');
    GOVUK.diff('body');
  }

  GOVUK.largeImportLogs.init($('.large-data-set'));

  GOVUK.formatAdvice.init($('.subtype').filter('select'));
});

