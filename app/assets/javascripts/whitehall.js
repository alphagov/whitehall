jQuery(document).ready(function($) {
  $(".flash.notice, .flash.alert").flashNotice();

  // This is useful for toggling CSS helpers
  // whilst developing.. cmd+G
  var cmdDown = false;
  $('body').keydown(function(event) {
    if (event.keyCode == '91') {
      cmdDown = true;
    }
    if (cmdDown && event.keyCode == '71') {
      event.preventDefault();
      $(this).toggleClass('dev');
    }
  }).keyup(function(event) {
    if (event.keyCode == '91') {
      cmdDown = false;
    }
  });

  $(".chzn-select").chosen({allow_single_deselect: true});

  $("#completed_fact_check_requests").markLinkedAnchor();

  $('fieldset.sortable legend').each(function () {
    $(this).append(' (drag up and down to re-order)');
  })
});
