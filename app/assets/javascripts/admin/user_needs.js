(function ($) {

  var $fieldset = $('#user-needs');

  // Shrink fieldset if user needs have been provided
  if ($('#edition_user_need_ids').val() !== null) {
    var $heading = $fieldset.find('h2');
    $heading
      .text($heading.text() + ' (click to show/hide)')
      .addClass('enhanced')
      .click(function() {
        $(this).nextAll().slideToggle();
      }).click();
  }

  // Autocomplete fields to reduce duplicates
  $fieldset.find('.user-need-input').each(function(index, input) {
    $(input).autocomplete({
      source: $(input).data('source'),
      autoFocus: true
    });
  });

}(jQuery));
