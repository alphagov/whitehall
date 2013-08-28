(function($) {
  $(function() {
    $(".date-filter input[type=submit]").hide();
    $(".date-filter .date").keypress(function(e) {
      if(e.which == 13) {
        $("form.date-filter").submit();
      };
    })
  })
})(jQuery);
