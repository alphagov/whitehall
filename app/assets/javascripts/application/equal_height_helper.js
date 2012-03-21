(function($) {
  $.fn.equalHeightHelper = function (options) {
    var _this = $(this);

    var settings = $.extend({
      'breakpointSelector' : window,
      'breakpointWidth'    : 768,
      'selectorsToResize'   : []
    }, options);

    var _resetHeight = function () {
      $(settings.selectorsToResize).each(function (i, selector) {
        _this.find(selector).css('min-height', '0');
      });
    }

    var _afterResize = function () {
      _resetHeight();
      if ($(settings.breakpointSelector).width() >= settings.breakpointWidth) {
        $.each(settings.selectorsToResize, function (i, selector) {
          _this.each(function(i, container) {
            utils.setMinHeightToLargestItem($(container).find(selector));
          });
        });
      };
    }

    var _resizingWait;
    var _resize_handler = function () {
      try {
        if (_this) {
          if(_resizingWait !== false)
            clearTimeout(_resizingWait);
          _resizingWait = setTimeout(_afterResize, 200);
        }
      } catch(err) {
        //do nothing
      }
    };

    $(settings.breakpointSelector).resize(_resize_handler);
    _afterResize();

    return $(this);
  }
})(jQuery)
