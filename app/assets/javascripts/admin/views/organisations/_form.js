(function () {
  'use strict'
  window.GOVUK = window.GOVUK || {}

  var organisationsForm = {
    init: function init (params) {
      $().ready(function ($) {
        organisationsForm.hideClosedAtFields()
        organisationsForm.hideSupersededByField()
        organisationsForm.toggleCustomLogoField()
      })
    },

    hideClosedAtFields: function hideClosedAtFields () {
      var $closedFields = $('.js-closed-organisation-field')
      var $govUkStatusField = $('#organisation_govuk_status')

      $govUkStatusField.change(enableClosedOrgFieldsIfClosed)
      enableClosedOrgFieldsIfClosed()

      function enableClosedOrgFieldsIfClosed () {
        if ($govUkStatusField.val() === 'closed') {
          enableClosedOrgFields()
          organisationsForm.hideSupersededByField()
        } else {
          disableClosedOrgFields()
        }
      }

      function enableClosedOrgFields () {
        $closedFields.show()
        $('input, select', $closedFields).removeAttr('disabled')
      }

      function disableClosedOrgFields () {
        $closedFields.hide()
        $('input, select', $closedFields).attr('disabled', true)
      }
    },

    hideSupersededByField: function hideSupersededByField () {
      var $supersededField = $('.js-superseded-organisation-field')
      var $govUkClosedStatusField = $('#organisation_govuk_closed_status')

      $govUkClosedStatusField.change(enableSupersededOrgFieldIfClosed)
      enableSupersededOrgFieldIfClosed()

      function enableSupersededOrgFieldIfClosed () {
        var superseded_org_fields = ['replaced', 'split', 'merged', 'changed_name', 'devolved']
        if (superseded_org_fields.indexOf($govUkClosedStatusField.val()) > -1) {
          enableSupersededOrgField()
        } else {
          disabledSupersededOrgField()
        }
      }

      function enableSupersededOrgField () {
        $supersededField.show()
        $('input, select', $supersededField).removeAttr('disabled')
      }

      function disabledSupersededOrgField () {
        $supersededField.hide()
        $('input, select', $supersededField).val('')
        $('.search-choice', $supersededField).remove()
        $('input, select', $supersededField).attr('disabled', true)
      }
    },

    toggleCustomLogoField: function toggleCustomLogoField () {
      var $logo_selector = $('#organisation_organisation_logo_type_id')
      var value_for_custom_logo = 14
      $logo_selector.chosen().change(function (event) {
        if ($(this).val() == value_for_custom_logo) {
          $('.organisation-custom-logo').slideDown()
        } else {
          $('.organisation-custom-logo').slideUp()
        }
      })
    }
  }

  window.GOVUK.organisationsForm = organisationsForm
}())
