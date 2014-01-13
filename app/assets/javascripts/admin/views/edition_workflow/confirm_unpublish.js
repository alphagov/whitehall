(function() {
  "use strict";
  window.GOVUK = window.GOVUK || {}

  var adminEditionWorkflowConfirmUnpublish = {
    init: function(params) {
      this.unpublishReasonIds = params.unpublish_reason_ids

      this.revealCorrectForm();
      this.hideExplanationIfRedirecting();

      $("input[name='unpublishing_reason_id']").change(this.revealCorrectForm);
      $('#unpublishing_redirect').change(this.hideExplanationIfRedirecting);
    },

    revealCorrectForm: function() {
      var selectedReasonId = $("input[name='unpublishing_reason_id']:checked").val()-0;
      switch(selectedReasonId) {
        case adminEditionWorkflowConfirmUnpublish.unpublishReasonIds.Archived:
          $('#js-archive-form').show();
          $('#js-published-in-error-form').hide();
          $('#js-consolidated-form').hide();
          break;
        case adminEditionWorkflowConfirmUnpublish.unpublishReasonIds.PublishedInError:
          $('#js-archive-form').hide();
          $('#js-published-in-error-form').show();
          $('#js-consolidated-form').hide();
          break;
        case adminEditionWorkflowConfirmUnpublish.unpublishReasonIds.Consolidated:
          $('#js-archive-form').hide();
          $('#js-published-in-error-form').hide();
          $('#js-consolidated-form').show();
          break;
      }
    },

    hideExplanationIfRedirecting: function() {
      if ( $("#unpublishing_redirect").prop('checked') ) {
        $('#published_in_error_explanation').val('').closest('fieldset').hide();
      } else {
        $('#published_in_error_explanation').closest('fieldset').show();
      }
    }
  };

  window.GOVUK.adminEditionWorkflowConfirmUnpublish = adminEditionWorkflowConfirmUnpublish;
}());
