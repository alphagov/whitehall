(function() {
  "use strict";
  window.GOVUK = window.GOVUK || {};

  function AdminAttachmentsForm(options) {
    $('#attachment_manually_numbered_headings').change(function () {
      $('.js-manual-numbering-help').toggle($(this).is(':checked'));
    }).change();
  }

  GOVUK.AdminAttachmentsForm = AdminAttachmentsForm;
}());
