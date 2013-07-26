(function () {
  "use strict"
  var root = this,
      $ = root.jQuery;
  if(typeof root.GOVUK === 'undefined') { root.GOVUK = {}; }

  var sticky = {
    _hasScrolled: false,
    _scrollTimeout: false,

    init: function(){
      var $els = $('.js-stick-at-top-when-scrolling');

      if($els.length > 0){
        sticky.$els = $els;

        if(sticky._scrollTimeout === false) {
          $(window).scroll(sticky.onScroll);
          sticky._scrollTimeout = window.setInterval(sticky.checkScroll, 50);
        }
        $(window).resize(sticky.onResize);
      }
      if(root.GOVUK.stopScrollingAtFooter){
        $els.each(function(i,el){
          var $img = $(el).find('img');
          if($img.length > 0){
            var image = new Image();
            image.onload = function(){
              root.GOVUK.stopScrollingAtFooter.addEl($(el), $(el).outerHeight());
            };
            image.src = $img.attr('src');
          } else {
            root.GOVUK.stopScrollingAtFooter.addEl($(el), $(el).outerHeight());
          }
        });
      }
    },
    onScroll: function(){
      sticky._hasScrolled = true;
    },
    checkScroll: function(){
      if(sticky._hasScrolled === true){
        sticky._hasScrolled = false;

        var windowVerticalPosition = $(window).scrollTop();
        sticky.$els.each(function(i, el){
          var $el = $(el),
              scrolledFrom = $el.data('scrolled-from');

          if (scrolledFrom && windowVerticalPosition < scrolledFrom){
            sticky.release($el);
          } else if($(window).width() > 768 && windowVerticalPosition >= $el.offset().top) {
            sticky.stick($el);
          }
        });
      }
    },
    stick: function($el){
      if (!$el.hasClass('content-fixed')) {
        $el.data('scrolled-from', $el.offset().top);
        var height = Math.max($el.height(), 1);
        $el.before('<div class="shim" style="width: '+ $el.width() + 'px; height: ' + height + 'px">&nbsp;</div>');
        $el.css('width', $el.width() + "px").addClass('content-fixed');
      }
    },
    release: function($el){
      if($el.hasClass('content-fixed')){
        $el.data('scrolled-from', false);
        $el.removeClass('content-fixed').css('width', '');
        $el.siblings('.shim').remove();
      }
    }
  }
  root.GOVUK.stickAtTopWhenScrolling = sticky;
}).call(this);
