(function() {
  "use strict";
  window.GOVUK = window.GOVUK || {}

  var rolesForm = {
    init: function init(params) {
      $().ready(function($) {
        rolesForm.hideClosedAtFields();
        rolesForm.hideSupersedingField();
      });
    },

    hideClosedAtFields: function hideClosedAtFields() {
      var $closedFields = $('.js-inactive-role-field'),
      $statusField = $('#role_status');

      $statusField.change(enabledInactiveRoleFieldsIfInactive);
      enabledInactiveRoleFieldsIfInactive();

      function enabledInactiveRoleFieldsIfInactive() {
        if ( $statusField.val() === "inactive" ) {
          enableInactiveRoleFields();
          rolesForm.hideSupersedingField();
        }
        else {
          disableInactiveRoleFields();
        }
      }

      function enableInactiveRoleFields() {
        $closedFields.show();
        $('input, select', $closedFields).removeAttr('disabled');
      }

      function disableInactiveRoleFields() {
        $closedFields.hide();
        $('input, select', $closedFields).attr('disabled', true);
      }
    },

    hideSupersedingField: function hideSupersedingField() {
      var $supersedingField = $('.js-superseding-role-field'),
      $reasonForInactivityField = $('#role_reason_for_inactivity');

      $reasonForInactivityField.change(enableSupersedingRoleFieldIfInactive);
      enableSupersedingRoleFieldIfInactive();

      function enableSupersedingRoleFieldIfInactive() {
        var superseding_org_fields = ['replaced', 'split', 'merged'];
        if (superseding_org_fields.indexOf($reasonForInactivityField.val()) > -1 ) {
          enableSupersedingRoleField();
        }
        else {
          disableSupersedingRoleField();
        }
      }

      function enableSupersedingRoleField() {
        $supersedingField.show();
        $('input, select', $supersedingField).removeAttr('disabled');
      }

      function disableSupersedingRoleField() {
        $supersedingField.hide();
        $('input, select', $supersedingField).val('');
        $('.search-choice', $supersedingField).remove();
        $('input, select', $supersedingField).attr('disabled', true);
      }
    }
  };

  window.GOVUK.rolesForm = rolesForm;
}());
