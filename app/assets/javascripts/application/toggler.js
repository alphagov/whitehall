(function($) {
  $.fn.toggler = function (options) {
    options = $.extend({
      header: '.toggle',
      content: '.overlay'
    }, options);
    this.each(function(i, el){
      var wrapper = $(el),
          header = wrapper.find(options.header),
          overlay = wrapper.find(options.content);

      function toggle() {
        wrapper.toggleClass('open')
        overlay.toggleClass('visuallyhidden');
      }

      if (header.length > 0 && overlay.length > 0) {
        header.attr('tabindex', 0);
        wrapper.addClass('toggleable');

        overlay.addClass('visuallyhidden');
        overlay.prepend('<span class="arrow"></span>');

        header.keyup(function(e) {
          if (e.which == 13) {
            e.preventDefault();
            toggle();
          }
        });

        header.mouseup(function (e) {
          e.preventDefault();
          toggle();
        });
      };
    });
    return this;
  };
})(jQuery);
