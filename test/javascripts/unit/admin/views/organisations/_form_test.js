module("admin-organisations-form", {
  setup: function() {
    $('#qunit-fixture').append('\
      <select id="organisation_govuk_status" name="organisation_govuk_status">\
        <option value="closed">Closed</option>\
        <option value="open" selected="selected">Open</option>\
      </select>\
      <p class="js-closed-organisation-field">\
        <label for="organisation_closed_at">Closed at?</label>\
        <input id="test_child">\
      </p>'
    );
  }
});

test("Should hide closed organisation fields when organisation is not closed", function() {
  var $group = $('.js-closed-organisation-field');
  GOVUK.organisationsForm.init();
  ok($group.is(':hidden'));
  ok($group.find('input').is(':disabled'));
});

test("should show closed organisation fields when organisation is open", function() {
  var $select = $('#organisation_govuk_status'),
      $group = $('.js-closed-organisation-field');
  GOVUK.organisationsForm.init();

  $select.find('option[value=closed]').attr('selected', true);
  $select.change();

  ok(!$group.find('input').is(':disabled'));
  ok(!$group.is(':hidden'));
});
