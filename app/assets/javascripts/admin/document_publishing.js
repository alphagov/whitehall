(function ($) {
  var _enableChangeNoteHighlighting = function() {
    var form = $(this);
    var changeNoteLabels = form.find("label[for=document_change_note]");
    var changeNoteTextareas = form.find("textarea#document_change_note");
    var changeNoteElements = changeNoteLabels.add(changeNoteTextareas);

    if ((changeNoteLabels.length > 0) && (changeNoteTextareas.length > 0)) {
      var buttonValue = form.find("input[type=submit]")[0].value;
      var publishButtonLink = $("<a/>").text(buttonValue).addClass("button").attr("href", "#document_publishing");

      publishButtonLink.click(function() {
        publishButtonLink.hide();
        $(changeNoteElements).wrap($("<div class='field_with_errors' />"));
        form.show();
      });

      form.hide();
      form.before(publishButtonLink);
    };
  }

  $.fn.extend({
    enableChangeNoteHighlighting: _enableChangeNoteHighlighting
  });
})(jQuery);

jQuery(function($) {
  $("#document_publishing").enableChangeNoteHighlighting();
})