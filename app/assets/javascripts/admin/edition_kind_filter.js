(function($) {
  $(function() {
    $(".edition-kind-filter input[type=submit]").hide();
    $(".edition-kind-filter select").change(function() {
      $(".edition-kind-filter form").submit();
    })
  })
})(jQuery);