jQuery(document).ready(function($) {
  $(".flash.notice, .flash.alert").flashNotice();

  // This is useful for toggling CSS helpers
  // whilst developing..
  $('body').keydown(function(event) {
    if (event.keyCode == '66') {
      event.preventDefault();
      $(this).toggleClass('dev');
    }
  });
});