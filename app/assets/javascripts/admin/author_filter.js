(function($) {
  $(function() {
    $(".author-filter input[type=submit]").hide();
    $(".author-filter select").change(function() {
      $(".author-filter form").submit();
    })
  })
})(jQuery);