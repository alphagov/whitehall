module('admin-organisations-form', {
  setup: function () {
    $('#qunit-fixture').append(
      '<select id="organisation_govuk_status" name="organisation_govuk_status">' +
        '<option value="closed">Closed</option>' +
        '<option value="open" selected="selected">Open</option>' +
      '</select>' +
      '<p class="js-closed-organisation-field">' +
      '<select id="organisation_govuk_closed_status" name="organisation_govuk_closed_status">' +
        '<option value="merged">Merged</option>' +
        '<option value="no_longer_exists" selected="selected">No longer exists</option>' +
      '</select>' +
      '</p>' +
      '<p class="js-closed-organisation-field">' +
        '<label for="organisation_closed_at">Closed at?</label>' +
        '<input id="test_child">' +
      '</p>' +
      '<p class="js-superseded-organisation-field">' +
        '<label for="organisation_superseding_organisation_ids">Superseding organisations</label>' +
        '<input id="test_child_2">' +
      '</p>'
    )
  }
})

test('Should hide closed organisation fields when organisation is not closed', function () {
  var $closedGroup = $('.js-closed-organisation-field')
  GOVUK.organisationsForm.init()
  ok($closedGroup.is(':hidden'))
  ok($closedGroup.find('input').is(':disabled'))
})

test('should show closed organisation fields when organisation is closed', function () {
  var $select = $('#organisation_govuk_status')
  var $closedGroup = $('.js-closed-organisation-field')
  GOVUK.organisationsForm.init()

  $select.find('option[value=closed]').attr('selected', true)
  $select.change()

  ok(!$closedGroup.find('input').is(':disabled'))
  ok(!$closedGroup.is(':hidden'))
})

test('Should hide superseded organisation fields when organisation is not closed', function () {
  var $supersededGroup = $('.js-superseded-organisation-field')
  GOVUK.organisationsForm.init()
  ok($supersededGroup.is(':hidden'))
  ok($supersededGroup.find('input').is(':disabled'))
})

test('should show superseded organisation fields when organisation closed status is supersedable', function () {
  var $closedSelect = $('#organisation_govuk_status')
  var $closedStatusSelect = $('#organisation_govuk_closed_status')
  var $supersededGroup = $('.js-superseded-organisation-field')
  GOVUK.organisationsForm.init()
  $closedSelect.find('option[value=closed]').attr('selected', true)
  $closedSelect.change()
  $closedStatusSelect.find('option[value=merged]').attr('selected', true)
  $closedStatusSelect.change()

  ok(!$supersededGroup.is(':hidden'))
  ok(!$supersededGroup.find('input').is(':disabled'))
})
