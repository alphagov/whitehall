window.GOVUK = window.GOVUK || {}
window.GOVUK.Modules = window.GOVUK.Modules || {};

(function (Modules) {
  function UnpublishTracking (module) {
    this.module = module
  }

  UnpublishTracking.prototype.init = function () {
    this.initSubmitListener()
  }

  UnpublishTracking.prototype.initSubmitListener = function () {
    this.module.addEventListener('submit', function (e) {
      var unpublishType = e.target.getAttribute('data-unpublish-reason-label').trim()
      GOVUK.analytics.trackEvent('WithdrawUnpublishSelection', 'WithdrawUnpublish-selection', { label: unpublishType })

      var withdrawalDate = e.target.querySelector('input[name=previous_withdrawal_id]:checked')
      if (withdrawalDate) {
        withdrawalDate = e.target.querySelector('label[for="' + withdrawalDate.id + '"]').innerText.trim()
        GOVUK.analytics.trackEvent('WithdrawUnpublishSelection', 'Withdraw-selection', { label: withdrawalDate })
      }
    })
  }

  Modules.UnpublishTracking = UnpublishTracking
})(window.GOVUK.Modules)
