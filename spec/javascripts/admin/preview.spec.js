describe('jQuery.enablePreview', function () {
  var form, csrfMeta

  beforeEach(function () {
    form = $(
      '<form>' +
        '<textarea id="blah"># preview this</textarea>' +
        '<label for="blah"></label>' +
        '<fieldset class="images">' +
          '<div class="image lead"><input name="edition[images_attributes][0][id]" type="hidden" value="1"></div>' +
          '<div class="image"><input name="edition[images_attributes][1][id]" type="hidden" value="2"></div>' +
        '</fieldset>' +
        '<fieldset class="attachments">' +
          '<input id="edition_edition_attachments_attributes_0_attachment_attributes_id" name="edition[edition_attachments_attributes][0][attachment_attributes][id]" type="hidden" value="276">' +
        '</fieldset>' +
        '<select id="edition_alternative_format_provider_id">' +
          '<option value="1">Ministry of Song</option>' +
          '<option value="2" selected="selected">Ministry of Silly Walks</option>' +
        '</select>' +
      '</form>'
    )

    $(document.body).append(form)

    csrfMeta = $('<meta name=csrf-token content=our-csrf-token />')
    $(document.head).append(csrfMeta)
    form.find('textarea').enablePreview()

    jasmine.Ajax.install()
  })

  afterEach(function () {
    form.remove()
    csrfMeta.remove()
    jasmine.Ajax.uninstall()
  })

  it('should post to generate a preview when the preview button is clicked', function () {
    form.find('.show-preview').click()

    var request = jasmine.Ajax.requests.mostRecent()
    request.respondWith({
      status: 200,
      contentType: 'text/html',
      responseText: '<h1>preview this</h1>'
    })

    expect(request.url).toEqual('/government/admin/preview')
    expect(request.data()).toEqual({
      alternative_format_provider_id: ['2'],
      'attachment_ids[]': ['276'],
      authenticity_token: ['our-csrf-token'],
      body: ['# preview this'],
      'image_ids[]': ['1', '2']
    })
  })

  it('should show a loading state while the request is loading', function () {
    form.find('.show-preview').click()
    expect(form.find('.preview-controls .loading').is(':visible')).toBeTrue()
    jasmine.Ajax.requests.mostRecent().respondWith({
      status: 200,
      contentType: 'text/html',
      responseText: '<h1>preview this</h1>'
    })
    expect(form.find('.preview-controls .loading').is(':visible')).toBeFalse()
  })

  it('should hide the textarea when the request is complete and populate a preview', function () {
    form.find('.show-preview').click()
    jasmine.Ajax.requests.mostRecent().respondWith({
      status: 200,
      contentType: 'text/html',
      responseText: '<h1>preview this</h1>'
    })
    expect(form.find('textarea').is(':visible')).toBeFalse()
    expect(form.find('#blah_preview').html()).toEqual('<h1>preview this</h1>')
  })

  it('should empty the preview and show the editor again when clicking edit after previewing', function () {
    form.find('.show-preview').click()
    jasmine.Ajax.requests.mostRecent().respondWith({
      status: 200,
      contentType: 'text/html',
      responseText: '<h1>preview this</h1>'
    })
    expect(form.find('#blah_preview').children().length).not.toEqual(0)
    form.find('.show-editor').click()
    expect(form.find('#blah_preview').children().length).toEqual(0)
    expect(form.find('textarea').is(':visible')).toBeTrue()
  })

  it('should alert if the server responds with an error', function () {
    form.find('.show-preview').click()
    spyOn(window, 'alert')

    jasmine.Ajax.requests.mostRecent().respondWith({
      status: 500,
      contentType: 'text/html',
      responseText: 'An error message'
    })

    expect(window.alert).toHaveBeenCalledWith('An error message')
  })
})
