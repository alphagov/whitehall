(function () {
  'use strict'
  window.GOVUK = window.GOVUK || {}

  var adminEditionWorkflowConfirmUnpublish = {
    init: function (params) {
      this.unpublishReasonIds = params.unpublish_reason_ids

      this.revealCorrectForm()
      this.hideExplanationIfRedirecting()
      this.revealNewWithdrawalFields()

      $("input[name='unpublishing_reason_id']").change(this.revealCorrectForm)
      $('#unpublishing_redirect').change(this.hideExplanationIfRedirecting)
      $("input[name='previous_withdrawal_id']").change(this.revealNewWithdrawalFields)
      $('main form').on('submit', this.trackFormSubmission)
    },

    revealCorrectForm: function () {
      var selectedReasonId = $("input[name='unpublishing_reason_id']:checked").val() - 0
      switch (selectedReasonId) {
        case adminEditionWorkflowConfirmUnpublish.unpublishReasonIds.Withdrawn:
          $('#js-withdraw-form').show()
          $('#js-published-in-error-form').hide()
          $('#js-consolidated-form').hide()
          break
        case adminEditionWorkflowConfirmUnpublish.unpublishReasonIds.PublishedInError:
          $('#js-withdraw-form').hide()
          $('#js-published-in-error-form').show()
          $('#js-consolidated-form').hide()
          break
        case adminEditionWorkflowConfirmUnpublish.unpublishReasonIds.Consolidated:
          $('#js-withdraw-form').hide()
          $('#js-published-in-error-form').hide()
          $('#js-consolidated-form').show()
          break
      }
    },

    hideExplanationIfRedirecting: function () {
      if ($('#unpublishing_redirect').prop('checked')) {
        $('#published_in_error_explanation').val('').closest('fieldset').hide()
      } else {
        $('#published_in_error_explanation').closest('fieldset').show()
      }
    },

    revealNewWithdrawalFields: function () {
      var withdrawalRadios = $("input[name='previous_withdrawal_id']")
      if (withdrawalRadios.length > 0) {
        var selected = withdrawalRadios.filter(':checked').val()
        $('#new-withdrawal').toggle(selected === 'new')
      }
    },

    trackFormSubmission: function () {
      var unpublishType = $("input[name='unpublishing_reason_id']:checked").parent().text().trim()
      GOVUKAdmin.trackEvent('WithdrawUnpublishSelection', 'WithdrawUnpublish-selection', { label: unpublishType })

      var withdrawalDate = $('input[name=previous_withdrawal_id]:checked').parent().find('strong').text().trim()
      if (withdrawalDate) {
        GOVUKAdmin.trackEvent('WithdrawUnpublishSelection', 'Withdraw-selection', { label: withdrawalDate })
      }
    }
  }

  window.GOVUK.adminEditionWorkflowConfirmUnpublish = adminEditionWorkflowConfirmUnpublish
}())
