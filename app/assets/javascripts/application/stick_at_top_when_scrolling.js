(function ($) {
  var _stickAtTopWhenScrolling = function() {
    var element = $(this), elementVerticalPosition;
    if (element.length == 0) {
      return;
    }

    elementVerticalPosition = element.offset().top - parseFloat(element.css('marginTop').replace(/auto/, 0));
        
    function adaptStickiness() {
      var windowVerticalPosition = $(window).scrollTop();
      if ($(window).width() > 768 && windowVerticalPosition >= elementVerticalPosition) {
        if (!element.hasClass('content-fixed')) {
          element.css('width', element.width() + "px");
          element.addClass('content-fixed');
        }
      } else {
        element.removeClass('content-fixed');
        element.css('width', '');
      }      
    }

    $(window).scroll(adaptStickiness);
    $(window).resize(adaptStickiness);
  }

  $.fn.extend({
    stickAtTopWhenScrolling: _stickAtTopWhenScrolling
  });
})(jQuery);
