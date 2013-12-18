GOVUK.init(GOVUK.chosenSelects);

jQuery(document).ready(function($) {
  if(typeof GOVUK === 'undefined') { window.GOVUK = {}; }

  $("#completed_fact_check_requests").markLinkedAnchor();

  $('.document .body').enhanceYoutubeVideoLinks();

  var url = document.location.toString();
  if (url.match('#')) {
    $('.nav-tabs a[href=#'+url.split('#')[1]+']').tab('show') ;
  }
  $(':not(.attachment-mode-select).nav-tabs a').on('shown', function (e) {
    var before_shown_scroll_y = window.pageYOffset;
    var before_shown_scroll_x = window.pageXOffset;
    window.location.hash = e.target.hash;
    window.scrollTo(before_shown_scroll_y, before_shown_scroll_y);
  })

  $('.sidebar.remarks-history a').on('shown', function (e) {
    // Chrome isn't redrawing this properly. Try and trick it by toggling the
    // display value
    var $el = $($(e.target).attr('href'))
    // switch display to inline
    $el.css('display', 'inline')
    // and back to block
    $el.css('display', '');
  });

  $('.js-create-new').toggler({header: ".toggler", content: "ul", showArrow: false, actLikeLightbox: true});
  $('.js-more-nav').toggler({header: ".toggler", content: "ul", showArrow: false, actLikeLightbox: true});

  GOVUK.createNew.init();
  GOVUK.doubleClickProtection();
  GOVUK.duplicateFields.init();
  GOVUK.formChangeProtection.init($('#edit_edition'), 'You have unsaved changes that will be lost if you leave this page.');
  GOVUK.hideClosedAtDates();
  GOVUK.toggleCustomLogoField();

  $('.attachment-mode-select label[data-target]').click(function (e) {
    $(this).tab('show');
  });
  $('.attachment-mode-select label[data-target]').on('shown', function(e) {
    $(this).parents('li').addClass('active');
    $(this).parents('li').siblings().removeClass('active');
  });
  $('.attachment-mode-select label[data-target] input:checked').parent().tab('show');
  $('.attachment-mode-select label[data-target]').on('shown', function(e) {
    var before_shown_scroll_y = window.pageYOffset;
    var before_shown_scroll_x = window.pageXOffset;
    window.location.hash = $(this).data('target');
    window.scrollTo(before_shown_scroll_y, before_shown_scroll_y);
  });

  if (window.location.hash && $('.tab-content').length > 0) {
    // we may need to preload the tabs
    var hash = window.location.hash.substring(1);
    // ... if it's not already selected.
    $('a[href$=#' + hash + '][data-toggle=tab]:not(.active)').tab('show');
  }

  if($('select#edition_speech_type_id').length) {
    GOVUK.updateSpeechHeaders();
    $('select#edition_speech_type_id').on('change', function(e) {
      GOVUK.updateSpeechHeaders();
    });
  }

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

