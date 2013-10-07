(function($) {
  $(function() {
    $(".js-edition-select-filter select").change(function() {
      $(this).parent().submit();
    });
    $(".js-btn-enter").each(function() {
      var btn = $(this);
      btn.siblings('input').on('change paste keydown', function() {
        btn.show();
      });
    });
  });
})(jQuery);
