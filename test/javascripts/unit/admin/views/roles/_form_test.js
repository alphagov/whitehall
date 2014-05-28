module("admin-roles-form", {
  setup: function() {
    $('#qunit-fixture').append('\
      <select id="role_status" name="role_status">\
	<option value="inactive">Inactive</option>\
	<option value="active" selected="selected">Active</option>\
      </select>\
      <p class="js-inactive-role-field">\
      <select id="role_reason_for_inactivity" name="role_reason_for_inactivity">\
	<option value="merged">Merged</option>\
	<option value="no_longer_exists" selected="selected">No longer exists</option>\
      </select>\
      </p>\
      <p class="js-inactive-role-field">\
	<label for="role_date_of_inactivity">Closed at?</label>\
	<input id="test_child">\
      </p>\
      <p class="js-superseding-role-field">\
	<label for="superseding_role_ids">Superseding roles</label>\
	<input id="test_child_2">\
      </p>'
    );
  }
});

test("should hide inactive role fields when role is active", function() {
    var $inactiveGroup = $('.js-inactive-role-field');
    GOVUK.rolesForm.init();
    ok($inactiveGroup.is(':hidden'));
    ok($inactiveGroup.find('input').is(':disabled'));
});

test("should show inactive role fields when role is inactive", function() {
    var $select = $('#role_status'),
	$inactiveGroup = $('.js-inactive-role-field');
    GOVUK.rolesForm.init();

    $select.find('option[value=inactive]').attr('selected', true);
    $select.change();

    ok(!$inactiveGroup.is(':hidden'));
    ok(!$inactiveGroup.find('input').is(':disabled'));
});

test("should hide superseding role fields when role is active", function() {
    var $supersedingGroup = $('.js-superseding-role-field');
    GOVUK.rolesForm.init();
    ok($supersedingGroup.is(':hidden'));
    ok($supersedingGroup.find('input').is(':disabled'));
});

test("should show superseding role fields when role inactive status is supersedable", function() {
    var $statusSelect = $('#role_status'),
    $reasonForInactivitySelect = $('#role_reason_for_inactivity'),
    $supersedingGroup = $('.js-superseding-role-field');
    GOVUK.rolesForm.init();
    $statusSelect.find('option[value=inactive]').attr('selected', true);
    $statusSelect.change();
    $reasonForInactivitySelect.find('option[value=merged]').attr('selected', true);
    $reasonForInactivitySelect.change();

    ok(!$supersedingGroup.is(':hidden'));
    ok(!$supersedingGroup.find('input').is(':disabled'));
});
