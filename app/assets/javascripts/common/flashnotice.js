(function ($) {
  /*
  *
  * Fades flash notices out after they are shown
  *
  */
  $.fn.flashNotice = function () {
    $(this).fadeIn();

    if (!$(this).hasClass('alert')) {
      var element = $(this);
      var timeout = setTimeout(function () { element.fadeOut(); }, 3000);
    }

    $(this).css('cursor', 'pointer').click(function () {
      if (timeout) {
        clearTimeout(timeout);
      }

      $(this).fadeOut();
    });
  };

  $.fn.showNotice = function (message) {
    $(this).html("<p class='flash notice'>"+message+"</p>");
    $(".notice", this).flashNotice();
  };

  $.fn.showAlert = function (message) {
    $(this).html("<p class='flash alert'>"+message+"</p>");
    $(".alert", this).flashNotice();
  };

})(jQuery);
