(function($) {
  $.fn.toggler = function (options) {
    options = $.extend({
      header: '.toggle',
      content: '.overlay',
      showArrow: true,
      actLikeLightbox: false
    }, options);
    this.each(function(i, el){
      var wrapper = $(el),
          header = wrapper.find(options.header),
          overlay = wrapper.find(options.content);

      function toggle() {
        wrapper.toggleClass('open')
        overlay.toggleClass('visuallyhidden');
        $(document).trigger('govuk.pageSizeChanged');
      }

      if (header.length > 0 && overlay.length > 0) {
        header.attr('tabindex', 0);
        wrapper.addClass('toggleable');

        overlay.addClass('visuallyhidden');
        overlay.removeClass('js-hidden');

        if (options.showArrow){
          overlay.prepend('<span class="arrow"></span>');
        }

        header.keyup(function(e) {
          if (e.which == 13) {
            e.preventDefault();
            toggle();
          }
        });

        header.click(function (e) {
          e.preventDefault();
        });

        header.mouseup(function (e) {
          e.preventDefault();
          toggle();
        });
        if(options.actLikeLightbox) {
          $(document).click(function(e){
            if($(e.target).closest(wrapper).length === 0 && wrapper.hasClass('open')){
              toggle();
            }
          });
        }
      };
    });
    return this;
  };
})(jQuery);
