(function() {
  "use strict";
  window.GOVUK = window.GOVUK || {}

  var rolesForm = {
    init: function init(params) {
      $().ready(function($) {
        rolesForm.toggleInactiveRoleField();
        rolesForm.toggleSupersedingField();
      });
    },

    toggleInactiveRoleField: function toggleInactiveRoleField() {
      var $inactiveFields = $('.js-inactive-role-field'),
      $statusField = $('#role_status');

      $statusField.change(enabledInactiveRoleFieldsIfInactive);
      enabledInactiveRoleFieldsIfInactive();

      function enabledInactiveRoleFieldsIfInactive() {
        if ( $statusField.val() != "active" ) {
          enableInactiveRoleFields();
          rolesForm.toggleSupersedingField();
        }
        else {
          disableInactiveRoleFields();
        }
      }

      function enableInactiveRoleFields() {
        $inactiveFields.show();
        $('input, select', $inactiveFields).removeAttr('disabled');
      }

      function disableInactiveRoleFields() {
        $inactiveFields.hide();
        $('input, select', $inactiveFields).attr('disabled', true);
      }
    },

    toggleSupersedingField: function toggleSupersedingField() {
      var $supersedingField = $('.js-superseding-role-field'),
      $statusField = $('#role_status');

      $statusField.change(enableSupersedingRoleFieldIfInactive);
      enableSupersedingRoleFieldIfInactive();

      function enableSupersedingRoleFieldIfInactive() {
        var superseding_org_fields = ['replaced', 'split', 'merged'];
        if (superseding_org_fields.indexOf($statusField.val()) > -1 ) {
          enableSupersedingRoleField();
        }
        else {
          disableSupersedingRoleField();
        }
      }

      function enableSupersedingRoleField() {
        $supersedingField.show();
        $('select', $supersedingField).removeAttr('disabled');
      }

      function disableSupersedingRoleField() {
        $supersedingField.hide();
        $('option', $supersedingField).removeAttr('selected');
        $('.search-choice', $supersedingField).remove();
        $('input, select', $supersedingField).attr('disabled', true);
      }
    }
  };

  window.GOVUK.rolesForm = rolesForm;
}());
