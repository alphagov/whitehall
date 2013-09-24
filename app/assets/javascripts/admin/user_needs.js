(function ($) {

  var fieldset = $('#user-needs');

  // Shrink fieldset if user needs have been provided
  if (fieldset.find('#edition_user_need_ids').val() !== null) {
    var heading = fieldset.find('h2');
    var extraFields = heading.nextAll();
    heading
      .text(heading.text() + ' (click to show/hide)')
      .addClass('enhanced')
      .click(function() {
        extraFields.slideToggle();
      }).click();
  }

}(jQuery));
