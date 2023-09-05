window.GOVUK = window.GOVUK || {}
window.GOVUK.Modules = window.GOVUK.Modules || {}
;(function (Modules) {
  function OrganisationForm(module) {
    this.module = module
  }

  OrganisationForm.prototype.init = function () {
    this.setupCustomLogoVisibilityEventListener()
    this.setupNotDepartmentalPublicBodyFieldsEventListener()
  }

  OrganisationForm.prototype.setupCustomLogoVisibilityEventListener =
    function () {
      const form = this.module
      const customLogoDiv = form.querySelector(
        '.js-view-organisation__form__custom_logo'
      )
      const logoSelect = form.querySelector(
        '#organisation_organisation_logo_type_id'
      )
      const customLogoId = '14'

      logoSelect.addEventListener('change', function () {
        if (logoSelect.value === customLogoId) {
          customLogoDiv.classList.remove(
            'app-view-organisation__form__custom_logo--hidden'
          )
        } else {
          customLogoDiv.classList.add(
            'app-view-organisation__form__custom_logo--hidden'
          )
        }
      })
    }

  OrganisationForm.prototype.setupNotDepartmentalPublicBodyFieldsEventListener =
    function () {
      const form = this.module
      const nonDepartmentalDiv = form.querySelector(
        '.js-view-organisation__form__non-departmental-public-body-fields'
      )
      const typeSelect = form.querySelector(
        '#organisation_organisation_type_key'
      )
      const nonDepartmentalValues = [
        'advisory_ndpb',
        'executive_ndpb',
        'tribunal'
      ]

      typeSelect.addEventListener('change', function () {
        if (nonDepartmentalValues.includes(typeSelect.value)) {
          nonDepartmentalDiv.classList.remove(
            'app-view-organisation__form__non-departmental-public-body-fields--hidden'
          )
        } else {
          nonDepartmentalDiv.classList.add(
            'app-view-organisation__form__non-departmental-public-body-fields--hidden'
          )
        }
      })
    }

  Modules.OrganisationForm = OrganisationForm
})(window.GOVUK.Modules)
