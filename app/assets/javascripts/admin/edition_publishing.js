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

(function($) {
  var hidePersonOverride = function() {
    if ($('input#person_override_active').prop('checked')) {
      $('.edition_person_override').show();
      $('.role_appointment').hide();
      $("#edition_role_appointment_id").val('');
    } else {
      $('.role_appointment').show();
      $('.edition_person_override').hide();
      $('#edition_person_override').val('');
    }
  }

  $('input#person_override_active').change(hidePersonOverride)
  hidePersonOverride();
})(jQuery);

(function($) {
  var hideScheduledPublication = function() {
    if ($('input#scheduled_publication_active').prop('checked')) {
      $('.scheduled_publication').show();
    } else {
      $('.scheduled_publication').hide();
    }
  }

  $('input#scheduled_publication_active').change(hideScheduledPublication)
  hideScheduledPublication();
})(jQuery);

(function($) {
  var $label = $('.check-date-valid'),
      $message = $('.date-warning-info').hide();
  if ($label.length > 0){
    var id = $($('.check-date-valid')[0]).attr('for'),
        $year = $('#' + id + '_1i'),
        $month = $('#' + id + '_2i'),
        $day = $('#' + id + '_3i');
    function checkDateValidity(){
      var year = $year[0].value,
          month = (parseInt($month[0].value) - 1),
          day = $day[0].value,
          dateSet = new Date(year, month, day),
          today = new Date();
      if (today < dateSet){
        $message.addClass('warning');
        $message.show();
      } else {
        $message.removeClass('warning');
        $message.hide();
      }
    }
    $year.bind('blur', checkDateValidity);
    $month.bind('blur', checkDateValidity);
    $day.bind('blur', checkDateValidity);
    checkDateValidity();
  }
})(jQuery);

(function($) {
  var publicationTypeChooser = $('.js-access-limited-by-default-checkbox');
  if (publicationTypeChooser.length > 0) {
    var accessLimitedByDefaultIds = publicationTypeChooser.data('access-limited-by-default-type-ids');
    var accessLimitedByDefault = function() {
      var chosenId = parseInt(publicationTypeChooser.val(), 10);
      if (accessLimitedByDefaultIds.indexOf(chosenId) >= 0) {
        $("input[name$='[access_limited]'][type=checkbox]").attr('checked', 'checked');
      }
    }

    if (accessLimitedByDefaultIds.length > 0) {
      publicationTypeChooser.change(accessLimitedByDefault)
      accessLimitedByDefault();
    }
  }
})(jQuery);

(function($){
  var $input = $('#edition_title'),
      $message = $('.title-length-info').hide(),
      $count = $message.find('.count');

  if($input.length > 0){
    $input.addClass('title-length-input');
    function checkLength(){
      var length = $input.val().split('').length;

      $count.text('Current length: '+length);
      if(length > 149){
        $input.removeClass('warning');
        $message.removeClass('warning');
        $input.addClass('error');
        $message.addClass('error');
        $message.show();
      }
      else if(length > 65){
        $input.removeClass('error');
        $message.removeClass('error');
        $input.addClass('warning');
        $message.addClass('warning');
        $message.show();
      }
      else {
        $input.removeClass('error');
        $message.removeClass('error');
        $input.removeClass('warning');
        $message.removeClass('warning');
      }
    }
    $input.bind('keyup', checkLength);
    checkLength();
  }
}(jQuery));
