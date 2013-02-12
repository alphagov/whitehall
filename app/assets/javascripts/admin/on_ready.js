jQuery(document).ready(function($) {
  if(typeof GOVUK === 'undefined') { window.GOVUK = {}; }
  $(".chzn-select").chosen({allow_single_deselect: true, search_contains: true});
  if(typeof ieVersion === 'undefined'){
    $(".chzn-select-non-ie").addClass('chzn-select').chosen({allow_single_deselect: true, search_contains: true});
  }


  $("#completed_fact_check_requests").markLinkedAnchor();

  $('fieldset.sortable legend').each(function () {
    $(this).append(' (drag up and down to re-order)');
  })

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
  $('.js-toggle-nav').toggler({header: ".toggler", content: ".content", showArrow: false, actLikeLightbox: true})

  GOVUK.duplicateFields.init();

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
})
