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
})