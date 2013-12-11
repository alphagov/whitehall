(function() {
  "use strict";
  window.GOVUK = window.GOVUK || {};

  function EditionsIndex(options) {
    var $filter_form = $(options.filter_form);

    $(function(){
      $("select", $filter_form).change(function() {
        $(this).parent().submit();
      });
      $(".js-btn-enter", $filter_form).each(function() {
        var btn = $(this);
        btn.siblings('input').on('change paste keydown', function() {
          btn.show();
        });
      });
    });
  }

  GOVUK.EditionsIndex = EditionsIndex;
}());
