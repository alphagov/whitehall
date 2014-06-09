module("admin-roles-form", {
  setup: function() {
    $('#qunit-fixture').append('\
      <select id="role_status" name="role_status">\
        <option value="active" selected="selected">Active</option>\
        <option value="no_longer_exists">No longer exists</option>\
        <option value="merged">Merged</option>\
      </select>\
      <p class="js-inactive-role-field">\
      	<label for="role_date_of_inactivity">Closed at?</label>\
	      <input id="test_child">\
      </p>\
      <p class="js-superseding-role-field">\
	      <label for="superseding_role_ids">Superseding roles</label>\
	      <select id="test_child_2">\
          <option value="12">Some organisation</option>\
        </select>\
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

test("should show inactive role fields when role is not active", function() {
    var $statusSelect = $('#role_status'),
        $inactiveGroup = $('.js-inactive-role-field');
    GOVUK.rolesForm.init();

    $statusSelect.val("no_longer_exists");

    $statusSelect.change();

    ok(!$inactiveGroup.is(':hidden'));
    ok(!$inactiveGroup.find('input').is(':disabled'));
});

test("should hide superseding role fields when role is active", function() {
    var $supersedingGroup = $('.js-superseding-role-field');
    GOVUK.rolesForm.init();
    ok($supersedingGroup.is(':hidden'));
    ok($supersedingGroup.find('select').is(':disabled'));
});

test("should show superseding role fields when role is supersedable", function() {
    var $statusSelect = $('#role_status'),
        $supersedingGroup = $('.js-superseding-role-field');
    GOVUK.rolesForm.init();

    $statusSelect.val("merged");
    $statusSelect.change();

    ok(!$supersedingGroup.is(':hidden'));
    ok(!$supersedingGroup.find('select').is(':disabled'));
});
