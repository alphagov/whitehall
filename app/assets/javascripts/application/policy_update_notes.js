(function($) {
  $.fn.policyUpdateNotes = function (options) {
    if ($(this).length > 0) {
      var _this = $(this);
      var _link;

      if (_link = $(options.link)) {
        _this.hide();
        if (!_link.is('a')) {
          _link.wrap('<a href="#"></a>');
          _link = _link.parent();
        };

        _link.click(function (e) {
          e.preventDefault();
          _this.fadeToggle();
        })
      };
    }
    return $(this);
  };
})(jQuery);