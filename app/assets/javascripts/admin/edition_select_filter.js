(function($) {
  $(function() {
    $(".js-edition-select-filter select").change(function() {
      $(this).parent().submit();
    })
  })
})(jQuery);
