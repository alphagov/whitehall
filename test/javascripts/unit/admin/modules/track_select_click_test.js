var form =
  '<form id="non-english" class="js-supports-non-english"></form>'

var policiesTrackedFieldset =
'  <fieldset class="policies">' +
'    <label for="edition_policy_content_ids">Policies</label>' +
'    <input name="edition[policy_content_ids][]" type="hidden" value="" />' +
'    <select multiple="multiple" class="chzn-select form-control" data-placeholder="Choose policies..." name="edition[policy_content_ids][]" id="edition_policy_content_ids" data-track-label="/government/admin/publication/new" data-track-category="taxonSelectionPolicies" data-module="track-select-click">' +
'      <option value=""></option>' +
'      <option value="17e4ab26-ee1f-4383-a345-d165c0b75fbf">School and college funding</option>' +
'      <option value="26e3144d-b07f-4329-9401-54f503349cd1">Civil contingencies and resilience</option>' +
'      <option value="2dcb5926-db6e-4347-b6d8-64fa9d5779a5">Brexit</option>' +
'    </select>' +
'  </fieldset>'

var policyAreasTrackedFieldset =
'  <fieldset class="edition-topic-fields">' +
'    <label for="edition_topic_ids">Policy Areas</label>' +
'    <input name="edition[topic_ids][]" type="hidden" value="" />' +
'    <select multiple="multiple" class="chzn-select form-control" data-placeholder="Choose policy areas..." name="edition[topic_ids][]" id="edition_topic_ids" data-track-label="/government/admin/publication/new" data-track-category="taxonSelectionPolicyAreas" data-module="track-select-click">' +
'      <option value=""></option>' +
'      <option value="43">Arts and culture</option>' +
'      <option value="44">Borders and immigration</option>' +
'      <option value="46">Business and enterprise</option>' +
'    </select>' +
'  </fieldset>'

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


module("TrackSelectClick", {
  setup: function() {
    this.subject = new GOVUKAdmin.Modules.TrackSelectClick();

    $('#qunit-fixture').append(form)
    $('#qunit-fixture form').append(policiesTrackedFieldset)
    $('#qunit-fixture form').append(policyAreasTrackedFieldset)
    $('#qunit-fixture form').append(primarySpecialistSectorTrackedFieldset)
    $('#qunit-fixture form').append(secondarySpecialistSectorTrackedFieldset)

    GOVUK.adminEditionsForm.init({
      selector: 'form#non-english',
      right_to_left_locales:["ar"]
    });
    $('.js-hidden').hide();
  }
});

test("the policies fieldset should send a tracking event on change", function () {
  var policiesSelectBox = $('#edition_policy_content_ids');
  var spy = sinon.spy(GOVUKAdmin, 'trackEvent');

  this.subject.start(policiesSelectBox);

  policiesSelectBox.val('17e4ab26-ee1f-4383-a345-d165c0b75fbf').change();

  sinon.assert.calledOnce(spy);
  deepEqual(
    spy.args[0],
    ["taxonSelectionPolicies", "School and college funding", {}]
  );

  spy.restore()
});

test("the policy areas fieldset should send a tracking event on change", function () {
  var policyAreasSelectBox = $('#edition_topic_ids');
  var spy = sinon.spy(GOVUKAdmin, 'trackEvent');

  this.subject.start(policyAreasSelectBox);

  policyAreasSelectBox.val('44').change();

  sinon.assert.calledOnce(spy);
  deepEqual(
    spy.args[0],
    ["taxonSelectionPolicyAreas", "Borders and immigration", {}]
  );

  spy.restore()
});

test("the primary specialist sector fieldset should send a tracking event on change", function () {
  var primarySpecialistSectorSelectBox = $('#edition_primary_specialist_sector_tag');
  var spy = sinon.spy(GOVUKAdmin, 'trackEvent');

  this.subject.start(primarySpecialistSectorSelectBox);

  primarySpecialistSectorSelectBox.val('5285dff5-e786-4b88-b113-1d78b19ac8e1').change();

  sinon.assert.calledOnce(spy);
  deepEqual(
    spy.args[0],
    ["taxonSelectionPrimarySpecialist", "Benefits: Universal Credit", {}]
  );

  spy.restore()
});


test("the additional specialist sector fieldset should send a tracking event on change", function () {
  var additionalSpecialistSectorSelectBox = $('#edition_secondary_specialist_sector_tags');
  var spy = sinon.spy(GOVUKAdmin, 'trackEvent');

  this.subject.start(additionalSpecialistSectorSelectBox);

  additionalSpecialistSectorSelectBox.val('3e275a11-0fae-425b-a7a1-fe434594693f').change();

  sinon.assert.calledOnce(spy);
  deepEqual(
    spy.args[0],
    ["taxonSelectionAdditionalSpecialist", "Animal welfare: Pets", {}]
  );

  spy.restore()
});
