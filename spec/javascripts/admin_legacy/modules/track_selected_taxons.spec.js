describe('GOVUKAdmin.Modules.TrackSelectedTaxons', function () {
  var form, trackSelectedTaxons

  beforeEach(function () {
    form = $(
      '<form id="taxon-form" class="js-supports-non-english" onsubmit="function(){return false;}">' +
        '<div class="content">' +
          '<div class="taxon-breadcrumb">' +
            '<ol>' +
              '<li>Parent 1</li>' +
              '<li>Child 1</li>' +
            '</ol>' +
          '</div>' +
          '<div class="taxon-breadcrumb">' +
            '<ol>' +
              '<li>Parent 2</li>' +
              '<li>Child 2</li>' +
            '</ol>' +
          '</div>' +
        '</div>' +
        '<input type="button" id="save" name="save" value="Save tagging changes" data-module="track-selected-taxons" ' +
          'data-track-category="taxonSelection" data-track-label="/government/admin/editions/798947/tags/edit">' +
      '</form>'
    )

    $(document.body).append(form)

    GOVUK.adminEditionsForm.init({
      selector: 'form#taxon-form',
      right_to_left_locales: ['ar']
    })

    trackSelectedTaxons = new GOVUKAdmin.Modules.TrackSelectedTaxons()
  })

  afterEach(function () {
    form.remove()
  })

  it('should send a GA event for each taxon breadcrumb when saved', function () {
    spyOn(GOVUKAdmin, 'trackEvent')

    trackSelectedTaxons.start(form.find('#save'))
    form.find('#save').click()

    expect(GOVUKAdmin.trackEvent).toHaveBeenCalledWith('taxonSelection', 'Parent 1 > Child 1', jasmine.any(Object))
    expect(GOVUKAdmin.trackEvent).toHaveBeenCalledWith('taxonSelection', 'Parent 2 > Child 2', jasmine.any(Object))
  })
})
