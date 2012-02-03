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
        $(settings.selectorsToResize).each(function (i, selector) {
          utils.setMinHeightToLargestItem(_this.find(selector));
        });
      };
    }

    var _resizingWait;
    var _resize_handler = function () {
      if (_this) {
        if(_resizingWait !== false) {
          clearTimeout(_resizingWait);
          _resizingWait = setTimeout(_afterResize, 200);
        }
      };
    };

    $(settings.breakpointSelector).resize(_resize_handler);
    _afterResize();

    return $(this);
  }
})(jQuery)
