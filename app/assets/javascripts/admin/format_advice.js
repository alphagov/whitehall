if (typeof(GOVUK) === 'undefined') { window.GOVUK = {}; }
GOVUK.formatAdvice = {
  init: function($subtypeFields) {
    if ($subtypeFields.length < 1) { return; }

    var $subformatAdvice = $('<p/>');
    $('#format-advice').append($subformatAdvice);

    $subtypeFields.change(function() {
      $field = $(this);
      var formatAdviceMap = $field.data('format-advice');

      var adviceText = formatAdviceMap[$field.val()];
      if (adviceText) {
        var selectedText = $field.find(':selected').text();
        var adviceHTML = '<strong>'+selectedText+'</strong>: '+adviceText;
        $subformatAdvice.html(adviceHTML);
      } else {
        $subformatAdvice.text('');
      }
    }).change();
  }
};
