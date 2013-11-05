(function() {
  "use strict";
  window.GOVUK = window.GOVUK || {}

  var enhanceUnpublishingForm = {
    init: function(params) {
      this.$form = $(params.selector);
      this.$submit_button = $('input[type="submit"]', this.$form);
      this.$explanation = $('.js_explanation');
      this.$alt_url = $('.js_alt_url');
      this.$redirect = $('.js_redirect');
      this.$auto_redirect = $('.auto_redirect');

      this.refreshFormFields();
      $("input[name='unpublishing[unpublishing_reason_id]']", this.$form).change(function () {
        enhanceUnpublishingForm.refreshFormFields();
      });
    },

    refreshFormFields: function() {
      var selectedReason =  $("input[name='unpublishing[unpublishing_reason_id]']:checked").val();

      switch(selectedReason) {
        case '5': // Archiving
          enhanceUnpublishingForm.$explanation.show();
          enhanceUnpublishingForm.$alt_url.hide();
          enhanceUnpublishingForm.$redirect.hide();
          enhanceUnpublishingForm.$auto_redirect.hide();
          enhanceUnpublishingForm.$submit_button.val('Archive');
          break;
        case '1': // Published in error
          enhanceUnpublishingForm.$explanation.show();
          enhanceUnpublishingForm.$alt_url.show();
          enhanceUnpublishingForm.$redirect.show();
          enhanceUnpublishingForm.$auto_redirect.hide();
          enhanceUnpublishingForm.$submit_button.val('Unpublish');
          break;
        case '4': // Consolidating
          enhanceUnpublishingForm.$explanation.hide();
          enhanceUnpublishingForm.$alt_url.show();
          enhanceUnpublishingForm.$redirect.hide();
          enhanceUnpublishingForm.$auto_redirect.show();
          enhanceUnpublishingForm.$submit_button.val('Unpublish');
          break;
      }
    }
  };

  window.GOVUK.enhanceUnpublishingForm = enhanceUnpublishingForm;
}());
