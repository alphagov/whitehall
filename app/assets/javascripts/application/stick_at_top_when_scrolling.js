(function ($) {
  var _stickAtTopWhenScrolling = function() {
    var element = $(this);
    if (element.length > 0) {
      var elementVerticalPosition = element.offset().top - parseFloat(element.css('marginTop').replace(/auto/, 0));
      $(window).scroll(function (event) {
        var windowVerticalPosition = $(this).scrollTop();
        if (windowVerticalPosition >= elementVerticalPosition) {
          element.addClass('content-fixed');
        } else {
          element.removeClass('content-fixed');
        }
      });
    }
  }

  $.fn.extend({
    stickAtTopWhenScrolling: _stickAtTopWhenScrolling
  });
})(jQuery);
