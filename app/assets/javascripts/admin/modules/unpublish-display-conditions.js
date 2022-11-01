window.GOVUK = window.GOVUK || {}
window.GOVUK.Modules = window.GOVUK.Modules || {};

(function (Modules) {
  function UnpublishDisplayConditions (module) {
    this.module = module

    // Need to pull this from the UnpublishingReason Model
    // For now this should be safe as the IDs are hardcoded in Model
    // REF: https://github.com/alphagov/whitehall/blob/main/app/models/unpublishing_reason.rb
    this.unpublishReasonIds = {
      PublishedInError: 1,
      Consolidated: 4,
      Withdrawn: 5
    }
  }

  UnpublishDisplayConditions.prototype.init = function () {
    this.initUnpublishTypeListener()
    this.initUnpublishRedirectListener()
  }

  UnpublishDisplayConditions.prototype.initUnpublishRedirectListener = function () {
    var checkbox = this.module.querySelector('.govuk-checkboxes__item input[name="unpublishing[redirect]"]')

    checkbox.addEventListener('change', function (e) {
      var display = e.currentTarget.checked ? 'none' : 'block'
      this.module.querySelector('.js-unpublish-withdraw-form__published-in-error div.app-c-govspeak-editor').style.display = display
    }.bind(this))

    if (checkbox.checked) {
      var event = new Event('change')
      checkbox.dispatchEvent(event)
    }
  }

  UnpublishDisplayConditions.prototype.initUnpublishTypeListener = function () {
    var options = this.module.querySelectorAll('.govuk-radios__input[name="unpublishing_reason"]')

    options.forEach(function (option) {
      option.addEventListener('change', function (e) {
        this.showConditionalQuestions(parseInt(e.target.value))
      }.bind(this))

      if (option.checked) {
        var event = new Event('change')
        option.dispatchEvent(event)
      }
    }.bind(this))
  }

  UnpublishDisplayConditions.prototype.showConditionalQuestions = function (unpublishingReasonId) {
    var showSection = function (selectedSectionId) {
      var sections = ['withdrawal', 'published-in-error', 'consolidated']

      sections.forEach(function (sectionId) {
        var display = sectionId === selectedSectionId ? 'block' : 'none'
        this.module.querySelector('.js-unpublish-withdraw-form__' + sectionId).style.display = display
      }.bind(this))
    }.bind(this)

    switch (unpublishingReasonId) {
      case this.unpublishReasonIds.Withdrawn:
        showSection('withdrawal')

        break
      case this.unpublishReasonIds.PublishedInError:
        showSection('published-in-error')

        break
      case this.unpublishReasonIds.Consolidated:
        showSection('consolidated')

        break
    }
  }

  Modules.UnpublishDisplayConditions = UnpublishDisplayConditions
})(window.GOVUK.Modules)
