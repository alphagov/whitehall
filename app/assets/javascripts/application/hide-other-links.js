/*global $ */
/*jslint
 white: true,
 vars: true,
 indent: 2
*/
(function($) {
  "use strict";
  $.fn.hideOtherLinks = function(options) {
    var config = { linkElement: 'a', alwaysVisibleClass: '.always-visible' };
    $.extend(config, options);

    $(this).each(function(i, elm){
      var $el = $(elm),
          showHide = $('<span class="other-content" />'),
          shownElements = [],
          hiddenElements = [],
          currentlyAppending = shownElements,
          fullStop = false;

      // Don't hide 2 or fewer links if they're short
      if ($el.children(config.linkElement).length <= 2 && $el.text().length <= 100) {
        return;
      }

      $($el.contents()).each(function(i, el) {
        if (el.nodeValue && (el.nodeValue === "." || el.nodeValue.match(/^\s+$/))) {
          fullStop = (el.nodeValue === ".");
          return;
        }
        currentlyAppending.push(el);
        if($(el).is(config.linkElement) && !$(el).next(config.linkElement).is(config.alwaysVisibleClass)) {
          currentlyAppending = hiddenElements;
        }
      });

      if (hiddenElements.length) {

        $el.empty();

        $(shownElements).each(function(i, el) {
          $el[0].appendChild(el);
        });

        $(hiddenElements).each(function(i, el) {
          showHide[0].appendChild(el);
        });

        $el.append(showHide);
        if (fullStop) {
          $el.append(".");
        }

        showHide.hide();

        var otherCount = showHide.children(config.linkElement).length;
        var toggle = $('<a href="#" class="show-other-content" title="Show additional links"><span class="plus">+&nbsp;</span>'+ otherCount +' other'+ (otherCount > 1 ? 's' : '') +'</a>');

        toggle.on('click', function(e) {
          e.preventDefault();
          $(this).remove();
          showHide.show().focus();
        });

        showHide.before(toggle);

        $el.attr('aria-live', 'polite');

      }

    });
    return this;
  };
})(jQuery);
