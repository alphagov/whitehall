if (typeof(GOVUK) === 'undefined') { window.GOVUK = {}; }
GOVUK.formatAdvice = {
  init: function($subtypeFields) {
    if ($subtypeFields.length < 1) { return; }

    var $subformatAdvice = $('<p/>');
    $('#format-advice').append($subformatAdvice);

    $subtypeFields.change(function() {
      $field = $(this);
      var formatAdviceMap = $field.data('format-advice');
      $subformatAdvice.text(formatAdviceMap[$field.val()] || '');
    }).change();
  }
};
