(function($) {

  var _featuredSectionCarousel = function(options) {
    var _this = $(this);
    var _wrapper;
    var _items = 0;
    var _currItem = 0;
    var _timeout;
    var _navEl;

    var settings = $.extend({
      'delay'           : 5000,
      'transitionSpeed' : 500,
      'navSelector'     : '.carousel-nav'
    }, options);

    var _createNavigation = function () {
      if (_this.find(settings.navSelector).length == 0) {
        var nav = $.div('', settings.navSelector);
        _items.each(function (i) {
          var nav_item = $.a(i+1, {href: '#' + $(this).attr('id')});
          nav_item.click(function () {
            _jumpTo($(this).attr('href'));
            return false;
          });
          nav.append(nav_item);
        });
        _this.append(nav);
        _navEl = _this.find(settings.navSelector);
        _highlightNavigation();
      }
    };

    var _highlightNavigation = function () {
      _navEl.find('a').removeClass('selected');
      _navEl.find('a[href=#' + $(_items[_currItem]).attr('id') + ']').addClass('selected');
    };

    var _resizeFeature = function (index, animate) {
      var h = $(_items[index]).outerHeight();
      if (h != null) {
        if (animate) {
          _this.animate({height: h});
        } else {
          _this.css({height: h});
        }
      }
    };

    var _animate = function (newTop) {
      _wrapper.animate({ top: newTop }, settings.transitionSpeed, function() {
        clearTimeout(_timeout);
        _timeout = setTimeout(_transition, settings.delay);
      });
    };

    var _transition = function () {
      if (_currItem >= _items.length-1) {
        // last item in the stack
        // to return to first without jumping 'up'
        // we'll reorder the list placing the current (and last)
        // item into the top of the featured list
        var item = $(_items[_currItem]).detach();
        _wrapper.prepend(item);
        _wrapper.css({top: 0});
        // this effectively resets our animation
        // so let's call transition again to
        // carry onto the next one.
        _currItem = 0;
        _items = _this.find('article');
        _transition();
      } else {
        var _nextTop = '-=' + $(_items[_currItem]).outerHeight();
        _currItem += 1;
        _highlightNavigation();
        _animate(_nextTop);
        _resizeFeature(_currItem, true);
      }
    };

    var _jumpTo = function (targetId) {
      _items.each(function (index) {
        if ("#" + $(this).attr('id') == targetId) {
          clearTimeout(_timeout);
          _currItem = index;
          _highlightNavigation();
          _animate(-$(this).position().top);
          _resizeFeature(_currItem, true);
        };
      });
    };

    var _setMinHeightToLargestItem = function () {
      // see utils.js
      utils.setMinHeightToLargestItem(_items);
      _resizeFeature(_currItem);
    }

    var _resizingWait = false;
    var _afterResize = function () {
      _wrapper.css({top: -$(_items[_currItem]).position().top});
      _resizeFeature(_currItem, false);
    }

    var _resize_handler = function () {
      if (_wrapper) {
        if (_resizingWait !== false)
          clearTimeout(_resizingWait);
        _resizingWait = setTimeout(_afterResize, 200);
      };
    };

    $(window).resize(_resize_handler);

    return function () {
      _this.addClass('carousel-enabled');
      _this.find('article').wrapAll($.div('', '.carousel-items'));
      _wrapper = _this.find('.carousel-items');
      _items = _this.find('article');
      if (_items.length > 1) {
        _wrapper.css({position: 'relative', top: 0});
        _createNavigation();
        _setMinHeightToLargestItem();
        _timeout = setTimeout(_transition, settings.delay);
        _wrapper.hover(function () {
            clearTimeout(_timeout);
          }, function () {
            _timeout = setTimeout(_transition, settings.delay);
          }
        );
      };
      return _this;
    }();
  };

  $.fn.extend({
    featuredSectionCarousel: _featuredSectionCarousel
  });
})(jQuery);