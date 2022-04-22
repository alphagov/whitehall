describe('GOVUK.organisationsForm', function () {
  var container

  beforeEach(function () {
    container = $(
      '<div>' +
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
        '</p>' +
      '</div>'
    )

    $(document.body).append(container)
    GOVUK.organisationsForm.init()
  })

  afterEach(function () {
    container.remove()
  })

  it('should hide closed organisation fields when organisation is not closed', function () {
    expect(container.find('.js-closed-organisation-field').is(':hidden')).toBeTrue()
    expect(container.find('.js-closed-organisation-field input').is(':disabled')).toBeTrue()
  })

  it('should show closed organisation fields when organisation is closed', function () {
    container.find('#organisation_govuk_status').val('closed').trigger('change')

    expect(container.find('.js-closed-organisation-field').is(':hidden')).toBeFalse()
    expect(container.find('.js-closed-organisation-field input').is(':disabled')).toBeFalse()
  })

  it('should hide superseded organisation fields when organisation is not closed', function () {
    expect(container.find('.js-superseded-organisation-field').is(':hidden')).toBeTrue()
    expect(container.find('.js-superseded-organisation-field input').is(':disabled')).toBeTrue()
  })

  it('should show superseded organisation fields when organisation closed status is supersedable', function () {
    container.find('#organisation_govuk_status').val('closed').trigger('change')
    container.find('#organisation_govuk_closed_status').val('merged').trigger('change')

    expect(container.find('.js-superseded-organisation-field').is(':hidden')).toBeFalse()
    expect(container.find('.js-superseded-organisation-field input').is(':disabled')).toBeFalse()
  })
})
