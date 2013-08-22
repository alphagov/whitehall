(function($) {
  $(function() {
    $(".js-edition-select-filter input[type=submit]").hide();
    $(".js-edition-select-filter select").change(function() {
      $(this).parent().submit();
    })
  })
})(jQuery);

