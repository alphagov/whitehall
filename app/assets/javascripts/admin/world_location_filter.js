(function($) {
  $(function() {
    $(".world-location-filter input[type=submit]").hide();
    $(".world-location-filter select").change(function() {
      $(".world-location-filter form").submit();
    })
  })
})(jQuery);