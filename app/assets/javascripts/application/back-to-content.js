(function () {
  'use strict'
  var root = this
  var $ = root.jQuery

  if (typeof root.GOVUK === 'undefined') { root.GOVUK = {} }

  var backToContent = {
    _hasScrolled: true,
    _scrollTimeout: false,

    init: function () {
      var $els = $('.js-back-to-content')

      if ($els.length > 0) {
        backToContent.$els = $els

        if (backToContent._scrollTimeout === false) {
          $(window).scroll(backToContent.onScroll)
          backToContent._scrollTimeout = window.setInterval(backToContent.checkScroll, 50)
        }
        $(window).resize(backToContent.onResize)
        backToContent.checkScroll()
      }
    },
    onScroll: function () {
      backToContent._hasScrolled = true
    },
    checkScroll: function () {
      if (backToContent._hasScrolled === true) {
        backToContent._hasScrolled = false

        var windowVerticalPosition = $(window).scrollTop()

        backToContent.$els.each(function (i, el) {
          var $el = $(el)
          var padding = 50
          var start = $el.data('backToContent-start')
          var stop = $el.data('backToContent-stop')
          var offset = $el.data('backToContent-offset')
          var windowOffset = $el.data('backToContent-windowOffset')
          var $nav
          var top

          if (!start) {
            $nav = $($el.find('a').attr('href'))
            start = $nav.height() + $nav.offset().top + padding
            $el.data('backToContent-start', start)

            top = $el.css('top') === 'auto'

            offset = $('#page').offset().top - (top ? -15 : 15) // 15px from the $gutter-half in the css
            $el.data('backToContent-offset', offset)

            windowOffset = top ? $(window).height() - $el.height() : 0
            $el.data('backToContent-windowOffset', windowOffset)

            stop = $('.js-back-to-content-stop').offset().top - padding - windowOffset + $el.height()
            $el.data('backToContent-stop', stop)
          }

          if (start < windowVerticalPosition) {
            backToContent.show($el)
          } else {
            backToContent.hide($el)
          }
          if (stop < windowVerticalPosition) {
            backToContent.stick($el, stop - offset + windowOffset)
          } else {
            backToContent.unstick($el)
          }
        })
      }
    },
    stick: function ($el, position) {
      $el.css({ position: 'absolute', top: position })
    },
    unstick: function ($el) {
      $el.css({ position: '', top: '' })
    },
    hide: function ($el) {
      $el.addClass('visuallyhidden')
    },
    show: function ($el) {
      if ($(window).width() > 768) {
        $el.removeClass('visuallyhidden')
      }
    }
  }
  root.GOVUK.backToContent = backToContent
}).call(this)
