if (typeof(GOVUK) === 'undefined') { window.GOVUK = {}; }
GOVUK.formatAdvice = {
  init: function($subtypeFields) {
    if ($subtypeFields.length < 1) { return; }

    $subtypeFields.change(function() {
      var $field = $(this);
      var $container = $field.parent();
      var formatAdviceMap = $field.data('format-advice');

      $container.find('.govspeak').remove();

      var adviceText = formatAdviceMap[$field.val()];
      if (adviceText) {
        var adviceHTML = '<strong class="govspeak">Use this subformat for…</strong> '+adviceText;
        $container.append(adviceHTML);
      }
    }).change();
  }
};
