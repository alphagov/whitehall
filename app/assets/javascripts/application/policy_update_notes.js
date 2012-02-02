(function($) {
  $.fn.policyUpdateNotes = function (options) {
    var _this = $(this);
    var _link;

    if (_link = $(options.link)) {
      _this.hide();
      if (!_link.is('a')) {
        _link.wrap('<a href="#"></a>');
        _link = _link.parent();
      };

      _link.click(function () {
        _this.fadeToggle();
        return false;
      })
    };

    return _this;
  };
})(jQuery);