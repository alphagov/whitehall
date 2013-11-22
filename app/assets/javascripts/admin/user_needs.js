(function ($) {

  var $fieldset = $('.user-needs');

  // Autocomplete fields to reduce duplicates
  $fieldset.find('.user-need-input').each(function(index, input) {
    $(input).autocomplete({
      source: $(input).data('source'),
      autoFocus: true
    });
  });

  // Add user needs with ajax
  var addContainer = $('.js-add-user-need');

  function submitForm() {
    var data = {
      user: $.trim(addContainer.find('#edition_user_needs_attributes_0_user').val()),
      need: $.trim(addContainer.find('#edition_user_needs_attributes_0_need').val()),
      goal: $.trim(addContainer.find('#edition_user_needs_attributes_0_goal').val()),
      organisation_id: addContainer.find('#edition_user_needs_attributes_0_organisation_id').val()
    };
    if (!data.user || !data.need || !data.goal) {
      alert("All three fields must be filled to create a user need.");
      return;
    }
    $.ajax({
      url: addContainer.data('add-user-need-url'),
      type: 'POST',
      data: {user_need: data},
      dataType: 'json',
      success: function(response) {
        addContainer.find('input[type="text"]').val('');
        var select = addContainer.find('select');
        var option = $('<option>');
        option.attr({
          value: response.id,
          selected: 'selected'
        });
        option.text(response.text);
        option.appendTo(select);
        select.trigger('chosen:updated');
      }
    });
  }

  addContainer.find('.js-create').click(function(e) {
    e.preventDefault();
    submitForm();
  });
  addContainer.find('input').keypress(function(e) {
    if (e.which == 13) {
      e.preventDefault();
      submitForm();
    }
  });

}(jQuery));
