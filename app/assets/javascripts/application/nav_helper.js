(function($) {
  $.fn.navHelper = function (options) {
    var _this = $(this);

    var settings = $.extend({
      sectionToggleClass : 'section_toggle',
      breakpointSelector : window,
      breakpoints: [],
      appendTo: _this
    }, options);

    var _navElSel = 'a:not(.' + settings.sectionToggleClass + ')';

    var currBreakpoint = {};

    var maxBreakWidth = 0;
    for (var i=0; i < settings.breakpoints.length; i++) {
      maxBreakWidth = Math.max( maxBreakWidth, settings.breakpoints[i].width );
    }

    var _toggleNavItems = function () {
      _this.find(_navElSel).not(currBreakpoint.exclude).toggle();
      if (_this.find(_navElSel).not(currBreakpoint.exclude).is(':visible')) {
        _this.addClass('expanded');
      } else {
        _this.removeClass('expanded');
      }
    }

    var _handleResize = function () {
      if ($(settings.breakpointSelector).width() > maxBreakWidth) {
        _this.find(_navElSel).show();
        _this.find('a.' + settings.sectionToggleClass).hide();
      } else {
        for (var i=0; i < settings.breakpoints.length; i++) {
          if ($(settings.breakpointSelector).width() <= settings.breakpoints[i].width) {
            currBreakpoint = settings.breakpoints[i];

            // show section toggle + label it
            if (currBreakpoint.label) {
              _this.find('a.' + settings.sectionToggleClass).text(currBreakpoint.label).show();
            }

            _this.find(_navElSel).not(currBreakpoint.exclude).hide();
            _this.find(currBreakpoint.exclude).show();
            _this.removeClass('expanded');
          }
        };
      }
    }

    // sort breakpoints largest > smallest
    settings.breakpoints.sort(function (x,y) {
      return (y.width - x.width);
    });

    $(settings.breakpointSelector).resize(_handleResize);

    $(settings.appendTo).append($.a(settings.collapsedLabel, {'class': settings.sectionToggleClass}));

    _this.find(_navElSel).addClass('nav_link');

    _this.find('a.' + settings.sectionToggleClass).click(function () {
      _toggleNavItems();
    });

    _handleResize();

    return $(this);
  }
})(jQuery);
