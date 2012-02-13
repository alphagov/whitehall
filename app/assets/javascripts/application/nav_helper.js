(function($) {
  $.fn.navHelper = function (options) {
    var _this = $(this);

    var settings = $.extend({
      'sectionToggleClass' : 'section_toggle',
      'breakpointSelector' : window,
      'breakpointWidth'    : 768,
      'collapsedLabel'     : 'All Sections'
    }, options);

    var _navElSel = 'a:not(.' + settings.sectionToggleClass + ')';

    _this.prepend($.a(settings.collapsedLabel, {class: settings.sectionToggleClass}));

    _this.find(_navElSel).addClass('nav_link');

    _this.find('a.' + settings.sectionToggleClass).click(function () {
      _this.find(_navElSel).toggle();
    });

    var _handleResize = function () {
      if ($(settings.breakpointSelector).width() >= settings.breakpointWidth) {
        _this.find(_navElSel).show();
        _this.find('a.' + settings.sectionToggleClass).hide();
      } else {
        _this.find(_navElSel).hide();
        _this.find('a.' + settings.sectionToggleClass).show();
      }
    }

    $(settings.breakpointSelector).resize(_handleResize);
    _handleResize();

    return $(this);
  }
})(jQuery)
