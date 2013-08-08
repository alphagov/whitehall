module("create-new", {
  setup: function() {
    $('#qunit-fixture').append('<select id="organisation_govuk_status" name="organisation_govuk_status"><option value="closed">Closed</option><option value="open" selected="selected">Open</option></select><div id="organisation_closed_at_group"><label for="organisation_closed_at">Closed at?</label><input id="test_child"></div>');
  }
});

test("Should hide child elements", function() {
  var $select = $('.organisation_govuk_status'),
      $group = $('#organisation_closed_at_group');
  GOVUK.hideClosedAtDates();
  ok($group.find('*').is(':hidden'));
});
