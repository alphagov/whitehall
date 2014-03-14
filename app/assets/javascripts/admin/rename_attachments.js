(function() {
  "use strict";
  window.GOVUK = window.GOVUK || {};

  function AdminRenameAttachments(options) {
    var $form = $(options.form_id);

    $form.on('ajax:beforeSend', function(event, xhr, settings) {
      $form.find('td').removeClass('error success');
      $form.find('span.help-block').remove();
    }).on('ajax:error', function(event, xhr, status) {
      $.each(xhr.responseJSON.errors, function(key, error) {
        $form.find("td#js-attachment-" + key)
          .addClass('error')
          .append('<span class="help-block">' + error + '</span>');
      });
    }).on('ajax:complete', function(xhr, status) {
      $form.find('input[type=hidden][name=commit]').remove();
      $form.find('input[name=commit]').removeAttr('disabled');
      $form.find('td.control-group').not('.error').addClass('success');
    });
  }

  GOVUK.AdminRenameAttachments = AdminRenameAttachments
}());

