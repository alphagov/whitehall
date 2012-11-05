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
    options = $.extend({
      rows: 1
    }, options);

    this.each(function(i, el){
      var $children = $(el).children();

      if ($children.length > 1) {
        // measure the height of the first element
        var firstTop = getOffset($children.first()),
            lineCount = 0;

        $children.slice(1).each(function(i, el) {
          if((lineCount < options.rows) && getOffset($(el)) > firstTop){
            firstTop = getOffset($(el));
            lineCount = lineCount + 1;
          }
          if(lineCount >= options.rows){
            $(el).addClass('js-hidden');
          }
        });

        if(lineCount >= options.rows){
          var openButton = $('<a class="show-other-content" href="#" title="Show additional content"><span class="plus">+&nbsp;</span>others</a>');

          openButton.on('click', function(e) {
            e.preventDefault();
            $children.filter('.js-hidden').removeClass('js-hidden').addClass('js-shown');
            if (options.showWrapper) {
              options.showWrapper.remove();
            }
            else {
              $(e.target).remove();
            }
          });

          if (options.showWrapper) {
            openButton = options.showWrapper.append(openButton);
          }

          if (options.appendToParent) {
            $children.first().parent().append(openButton);
          } else {
            $children.first().parent().after(openButton);
          }
        }
      }
    });
    return this;
  };
}(jQuery));
