describe('GOVUKAdmin.Modules.TrackSelectClick', function () {
  var form, trackSelectClick

  beforeEach(function () {
    form = $(
      '<form id="non-english" class="js-supports-non-english">' +
        '<fieldset class="edition-specialist-sector-fields">' +
          '<label for="edition_primary_specialist_sector_tag">Primary specialist topic tag</label>' +
          '<select class="chzn-select form-control" data-placeholder="Choose a primary specialist topic…" name="edition[primary_specialist_sector_tag]" id="edition_primary_specialist_sector_tag" data-track-label="/government/admin/publication/new" data-track-category="taxonSelectionPrimarySpecialist" data-module="track-select-click">' +
            '<option value=""></option>' +
            '<optgroup label="Animal welfare">' +
              '<option value="3e275a11-0fae-425b-a7a1-fe434594693f">Animal welfare: Pets</option>' +
            '</optgroup>' +
            '<optgroup label="Benefits">' +
              '<option value="5285dff5-e786-4b88-b113-1d78b19ac8e1">Benefits: Universal Credit</option>' +
              '<option value="cc9eb8ab-7701-43a7-a66d-bdc5046224c0">Benefits: Child Benefit</option>' +
            '</optgroup>' +
            '<optgroup label="Business and enterprise">' +
              '<option value="05dd1330-d26e-4683-9717-b61019eae6e4">Business and enterprise: Licensing</option>' +
            '</optgroup>' +
          '</select>' +
        '</fieldset>' +
      '</form>'
    )
    $(document.body).append(form)

    $('.js-hidden').hide()

    trackSelectClick = new GOVUKAdmin.Modules.TrackSelectClick()
  })

  afterEach(function () {
    form.remove()
  })

  it('should send a tracking event on change when a select value changes', function () {
    var specialistSectorSelectBox = form.find('select')
    spyOn(GOVUKAdmin, 'trackEvent')

    trackSelectClick.start(specialistSectorSelectBox)

    specialistSectorSelectBox.val('5285dff5-e786-4b88-b113-1d78b19ac8e1').change()

    expect(GOVUKAdmin.trackEvent).toHaveBeenCalledWith('taxonSelectionPrimarySpecialist', 'Benefits: Universal Credit', jasmine.any(Object))
  })
})
