(function ($) {
  var _enableChangeNoteHighlighting = function() {
    var form = $(this);
    var changeNoteLabels = form.find("label[for=edition_change_note]");
    var changeNoteTextareas = form.find("textarea#edition_change_note");
    var changeNoteElements = changeNoteLabels.add(changeNoteTextareas);

    if ((changeNoteLabels.length > 0) && (changeNoteTextareas.length > 0)) {
      var buttonValue = form.find("input[type=submit]")[0].value;
      var publishButtonLink = $("<a/>").text(buttonValue).addClass("button").attr("href", "#edition_publishing");

      publishButtonLink.click(function() {
        publishButtonLink.hide();
        $(changeNoteElements).wrap($("<div class='field_with_errors' />"));
        form.show();
      });

      form.hide();
      form.before(publishButtonLink);

      form.find('input[type=checkbox][name="edition[minor_change]"]').click(function(event) {
        changeNoteElements.attr('disabled', $(this).prop('checked') ? 'disabled' : null);
      });
    };

  }

  $.fn.extend({
    enableChangeNoteHighlighting: _enableChangeNoteHighlighting
  });
})(jQuery);

jQuery(function($) {
  $("#edition_publishing").enableChangeNoteHighlighting();
});

(function($){
  var $input = $('#edition_summary'),
      $message = $('.summary-length-info').hide(),
      $count = $message.find('.count');

  if($input.length > 0){
    $input.addClass('summary-length-input');
    function checkLength(){
      var length = $input.val().split('').length;

      $count.text('Current length: '+length);
      if(length > 140){
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
}(jQuery));
