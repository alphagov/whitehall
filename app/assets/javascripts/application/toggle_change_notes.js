(function($) {
  $.fn.toggleChangeNotes = function (options) {
    options = $.extend(options, {
      header: 'h1',
      content: '.overlay'
    });
    this.each(function(i, el){
      var wrapper = $(el),
          header = wrapper.find(options.header),
          overlay = wrapper.find(options.content);

      if (header.length > 0 && overlay.length > 0) {
        wrapper.addClass('toggleable');

        header.html('<a href="#' + overlay.attr('id') + '">'+ header.html() +'</a>');

        overlay.hide();
        overlay.prepend('<span class="arrow"></span>');

        header.find('a').click(function (e) {
          e.preventDefault();
          wrapper.toggleClass('open')
          overlay.fadeToggle();
        });
      };
    });
    return this;
  };
})(jQuery);
