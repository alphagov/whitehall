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

  if(window.ieVersion && ieVersion === 8){
    $('textarea').each(function(i, el){
      $(el).css('width', $(el).width());
    });
  }

  // admin attachments are sortable
  $( "ol.existing-attachments.js-sortable" ).sortable({
    stop: function (event, ui) {
      $(this).find('input.ordering').each( function (index, input) {
        $(input).val(index);
      });
    }
  });

  // Admin UI for document collections
  if ($('div.document-collection-groups.index').length > 0) {
    GOVUK.documentCollectionDocFinder.init();
    GOVUK.documentCollectionCheckboxSelector.init();
  }

  // Inbound links on edition show page
  $('#inbound-links').hideExtraRows({rows: 10});

  // show/hide unnumbered HTML headings markdown help
  $('#attachment_manually_numbered_headings').change(function () {
    $('.js-manual-numbering-help').toggle($(this).is(':checked'));
  }).change();

  if ($('#diff').length > 0) {
    GOVUK.diff('title');
    GOVUK.diff('summary');
    GOVUK.diff('body');
  }

  GOVUK.largeImportLogs.init($('.large-data-set'));

  GOVUK.formatAdvice.init($('.subtype').filter('select'));
});

