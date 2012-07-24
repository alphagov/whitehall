(function($) {
  $.fn.toggleChangeNotes = function (options) {
    options = $.extend({
      header: '.toggle',
      content: '.overlay'
    }, options);
    this.each(function(i, el){
      var wrapper = $(el),
          header = wrapper.find(options.header),
          overlay = wrapper.find(options.content);

      if (header.length > 0 && overlay.length > 0) {
        wrapper.addClass('toggleable');

        overlay.addClass('visuallyhidden');
        overlay.prepend('<span class="arrow"></span>');

        header.mouseup(function (e) {
          e.preventDefault();
          wrapper.toggleClass('open')
          overlay.toggleClass('visuallyhidden');
        });
      };
    });
    return this;
  };
})(jQuery);
