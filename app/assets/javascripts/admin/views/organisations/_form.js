(function() {
  "use strict";
  window.GOVUK = window.GOVUK || {}

  var organisationsForm = {
    init: function init(params) {
      $().ready(function($) {
        organisationsForm.hideClosedAtFields();
        organisationsForm.toggleCustomLogoField();
      });
    },

    hideClosedAtFields: function hideClosedAtFields() {
      var $closedFields = $('.js-closed-organisation-field'),
          $govUkStatusField = $('#organisation_govuk_status');

      $govUkStatusField.change(enableClosedOrgFieldsIfClosed);
      enableClosedOrgFieldsIfClosed();

      function enableClosedOrgFieldsIfClosed() {
        if ( $govUkStatusField.val() === "closed" )
          enableClosedOrgFields();
        else
          disableClosedOrgFields();
      }

      function enableClosedOrgFields() {
        $closedFields.show();
        $('input, select', $closedFields).removeAttr('disabled');
      }

      function disableClosedOrgFields() {
        $closedFields.hide();
        $('input, select', $closedFields).attr('disabled', true);
      }
    },

    toggleCustomLogoField: function toggleCustomLogoField() {
      var $logo_selector = $('#organisation_organisation_logo_type_id');
      var value_for_custom_logo = 14;
      $logo_selector.chosen().change(function(event) {
        if ($(this).val() == value_for_custom_logo) {
          $('.organisation-custom-logo').slideDown();
        }
        else {
          $('.organisation-custom-logo').slideUp();
        }
      });
    }
  };

  window.GOVUK.organisationsForm = organisationsForm;
}());
