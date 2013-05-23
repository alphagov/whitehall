(function($) {
  $(function() {
    $(".organisation-filter input[type=submit]").hide();
    $(".organisation-filter select").change(function() {
      $(".organisation-filter form").submit();
    })
  })
})(jQuery);