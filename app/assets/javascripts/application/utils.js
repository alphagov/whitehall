var utils = {};

(function($) {

  utils.setMinHeightToLargestItem = function (selector) {
    var max = 0;
    $(selector).each(function() {
      max = Math.max( max, $(this).height() );
    });
    $(selector).css({'min-height': max + 'px'});
  }

})(jQuery);
