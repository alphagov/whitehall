jQuery(document).ready(function($) {
  $(".chzn-select").chosen({allow_single_deselect: true, search_contains: true});

  $("#completed_fact_check_requests").markLinkedAnchor();

  $('fieldset.sortable legend').each(function () {
    $(this).append(' (drag up and down to re-order)');
  })

  $('.document .body').enhanceYoutubeVideoLinks();

  var url = document.location.toString();
  if (url.match('#')) {
    $('.nav-tabs a[href=#'+url.split('#')[1]+']').tab('show') ;
  }
  $('.nav-tabs a').on('shown', function (e) {
    window.location.hash = e.target.hash;
    window.scrollTo(0, 0);
  })
})
