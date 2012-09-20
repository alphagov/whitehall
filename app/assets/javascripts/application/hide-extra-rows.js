/*global $ */
/*jslint
 white: true,
 vars: true,
 indent: 2
*/
(function($) {
  "use strict";
  function getOffset(el) {
    return parseInt(el.position().top, 10);
  }

  $.fn.hideExtraRows = function(options) {
    options = options || {};

    if (this.length > 1) {
      // measure the height of the first element
      var firstTop = getOffset(this.first()),
          toHide = false;

      this.slice(1).each(function(i, el) {
        if (toHide || (!toHide && getOffset($(el)) > firstTop)) {
          toHide = true;
          $(el).addClass('js-hidden');
        }
      });

      if (toHide) {
        var openButton = $('<a class="show-other-content" href="#" title="Show additional content"><span class="plus">+&nbsp;</span>others</a>');

        openButton.on('click', $.proxy(function(e) {
          e.preventDefault();
          this.filter('.js-hidden').removeClass('js-hidden').addClass('js-shown');
          if (options.showWrapper) {
            options.showWrapper.remove();
          }
          else {
            $(e.target).remove();
          }
        }, this));

        if (options.showWrapper) {
          openButton = options.showWrapper.append(openButton);
        }

        if (options.appendToParent) {
          this.first().parent().append(openButton);
        }
        else {
          this.first().parent().after(openButton);
        }
      }
    }

    return this;
  };
}(jQuery));
