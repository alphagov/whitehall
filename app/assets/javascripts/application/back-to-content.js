(function () {
  "use strict"
  var root = this,
      $ = root.jQuery;

  if(typeof root.GOVUK === 'undefined') { root.GOVUK = {}; }

  var backToContent = {
    _hasScrolled: false,
    _scrollTimeout: false,

    init: function(){
      var $els = $('.js-back-to-content');

      if($els.length > 0){
        backToContent.$els = $els;

        if(backToContent._scrollTimeout === false) {
          $(window).scroll(backToContent.onScroll);
          backToContent._scrollTimeout = window.setInterval(backToContent.checkScroll, 50);
        }
        $(window).resize(backToContent.onResize);
        backToContent.checkScroll();
      }
    },
    onScroll: function(){
      backToContent._hasScrolled = true;
    },
    checkScroll: function(){
      if(backToContent._hasScrolled === true){
        backToContent._hasScrolled = false;

        var windowVerticalPosition = $(window).scrollTop();
        backToContent.$els.each(function(i, el){
          var $el = $(el),
              $nav = $($el.find('a').attr('href')),
              padding = 100;

          if ($nav.height() + $nav.offset().top + padding < windowVerticalPosition){
            backToContent.show($el);
          } else {
            backToContent.hide($el);
          }
        });
      }
    },
    hide: function($el){
      $el.addClass('visuallyhidden');
    },
    show: function($el){
      if($(window).width() > 768) {
        $el.removeClass('visuallyhidden');
      }
    }
  }
  root.GOVUK.backToContent = backToContent;
}).call(this);
