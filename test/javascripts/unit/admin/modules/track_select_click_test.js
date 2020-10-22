/* global GOVUKAdmin */

var form =
  '<form id="non-english" class="js-supports-non-english"></form>'

var primarySpecialistSectorTrackedFieldset =
'  <fieldset class="edition-specialist-sector-fields">' +
'    <label for="edition_primary_specialist_sector_tag">Primary specialist sector tag</label>' +
'    <select class="chzn-select form-control" data-placeholder="Choose a primary specialist sector..." name="edition[primary_specialist_sector_tag]" id="edition_primary_specialist_sector_tag" data-track-label="/government/admin/publication/new" data-track-category="taxonSelectionPrimarySpecialist" data-module="track-select-click">' +
'      <option value=""></option>' +
'      <optgroup label="Animal welfare">' +
'       <option value="3e275a11-0fae-425b-a7a1-fe434594693f">Animal welfare: Pets</option>' +
'      </optgroup>' +
'      <optgroup label="Benefits">' +
'       <option value="5285dff5-e786-4b88-b113-1d78b19ac8e1">Benefits: Universal Credit</option>' +
'       <option value="cc9eb8ab-7701-43a7-a66d-bdc5046224c0">Benefits: Child Benefit</option>' +
'      </optgroup>' +
'      <optgroup label="Business and enterprise">' +
'       <option value="05dd1330-d26e-4683-9717-b61019eae6e4">Business and enterprise: Licensing</option>' +
'      </optgroup>' +
'    </select>' +
'  </fieldset>'

var secondarySpecialistSectorTrackedFieldset =
'  <fieldset class="edition-specialist-sector-fields">' +
'    <label for="edition_secondary_specialist_sector_tags">Additional specialist sectors</label>' +
'    <select class="chzn-select form-control" data-placeholder="Choose additional specialist sectors..." name="edition[secondary_specialist_sector_tags][]" id="edition_secondary_specialist_sector_tags" data-track-label="/government/admin/publication/new" data-track-category="taxonSelectionAdditionalSpecialist" data-module="track-select-click">' +
'      <option value=""></option>' +
'      <optgroup label="Animal welfare">' +
'       <option value="3e275a11-0fae-425b-a7a1-fe434594693f">Animal welfare: Pets</option>' +
'      </optgroup>' +
'      <optgroup label="Benefits">' +
'       <option value="5285dff5-e786-4b88-b113-1d78b19ac8e1">Benefits: Universal Credit</option>' +
'       <option value="cc9eb8ab-7701-43a7-a66d-bdc5046224c0">Benefits: Child Benefit</option>' +
'      </optgroup>' +
'      <optgroup label="Business and enterprise">' +
'       <option value="05dd1330-d26e-4683-9717-b61019eae6e4">Business and enterprise: Licensing</option>' +
'      </optgroup>' +
'    </select>' +
'  </fieldset>'

module('TrackSelectClick', {
  setup: function () {
    this.subject = new GOVUKAdmin.Modules.TrackSelectClick()

    $('#qunit-fixture').append(form)
    $('#qunit-fixture form').append(primarySpecialistSectorTrackedFieldset)
    $('#qunit-fixture form').append(secondarySpecialistSectorTrackedFieldset)

    GOVUK.adminEditionsForm.init({
      selector: 'form#non-english',
      right_to_left_locales: ['ar']
    })
    $('.js-hidden').hide()
  }
})

test('the primary specialist sector fieldset should send a tracking event on change', function () {
  var primarySpecialistSectorSelectBox = $('#edition_primary_specialist_sector_tag')
  var spy = sinon.spy(GOVUKAdmin, 'trackEvent')

  this.subject.start(primarySpecialistSectorSelectBox)

  primarySpecialistSectorSelectBox.val('5285dff5-e786-4b88-b113-1d78b19ac8e1').change()

  sinon.assert.calledOnce(spy)
  deepEqual(
    spy.args[0],
    ['taxonSelectionPrimarySpecialist', 'Benefits: Universal Credit', {}]
  )

  spy.restore()
})

test('the additional specialist sector fieldset should send a tracking event on change', function () {
  var additionalSpecialistSectorSelectBox = $('#edition_secondary_specialist_sector_tags')
  var spy = sinon.spy(GOVUKAdmin, 'trackEvent')

  this.subject.start(additionalSpecialistSectorSelectBox)

  additionalSpecialistSectorSelectBox.val('3e275a11-0fae-425b-a7a1-fe434594693f').change()

  sinon.assert.calledOnce(spy)
  deepEqual(
    spy.args[0],
    ['taxonSelectionAdditionalSpecialist', 'Animal welfare: Pets', {}]
  )

  spy.restore()
})
