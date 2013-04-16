(function($){
  var _enableSummaryLengthCounting = function () {
    var $input = $(this),
        $message = $($input.data('countMessageSelector')).hide(),
        $count = $message.find('.count'),
        threshold = $input.data('countMessageThreshold');

    if($input.length > 0){
      $input.addClass('summary-length-input');
      function checkLength(){
        var length = $input.val().split('').length;

        $count.text('Current length: '+length);
        if(length > threshold){
          $input.addClass('warning');
          $message.addClass('warning');
          $message.show();
        } else {
          $input.removeClass('warning');
          $message.removeClass('warning');
        }
      }
      $input.bind('keyup', checkLength);
      checkLength();
    }
  }
  $.fn.extend({
    enableSummaryLengthCounting: _enableSummaryLengthCounting
  });
})(jQuery);
jQuery(function($) {
  $(".js-summary-length-counting").enableSummaryLengthCounting();
});
