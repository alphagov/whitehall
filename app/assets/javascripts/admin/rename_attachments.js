(function() {
  "use strict";
  window.GOVUK = window.GOVUK || {};

  function AdminRenameAttachments(options) {
    var $form = $(options.form_id);

    $form.on('ajax:beforeSend', function(event, xhr, settings) {
      $form.find('td').removeClass('field_with_errors');
      $form.find('span.alert-error').remove();
    }).on('ajax:error', function(event, xhr, status) {
      $.each(xhr.responseJSON.errors, function(key, error) {
        $form.find("td#js-attachment-" + key)
          .after('<span class="alert-error">' + error + '</span>')
          .parent().addClass('field_with_errors');
      });
    }).on('ajax:complete', function(xhr, status) {
      $form.find('input[type=hidden][name=commit]').remove();
      $form.find('input[name=commit]').removeAttr('disabled');
    });
  }

  GOVUK.AdminRenameAttachments = AdminRenameAttachments
}());

