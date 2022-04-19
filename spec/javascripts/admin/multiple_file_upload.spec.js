describe('jquery.enableMultipleFileUploads', function () {
  var fieldset

  beforeEach(function () {
    fieldset = $(
      '<fieldset id="image_fields" class="images multiple_file_uploads">' +
        '<div class="file_upload well">' +
          '<div class="form-group">' +
            '<label for="edition_images_attributes_0_image_data_attributes_file">File</label>' +
            '<input id="edition_images_attributes_0_image_data_attributes_file" name="edition[images_attributes][0][image_data_attributes][file]" type="file" class="js-upload-image-input" />' +
            '<input id="edition_images_attributes_0_image_data_attributes_file_cache" name="edition[images_attributes][0][image_data_attributes][file_cache]" type="hidden" />' +
          '</div>' +
          '<div class="form-group">' +
            '<label for="edition_images_attributes_0_alt_text">Alt text</label>' +
            '<input id="edition_images_attributes_0_alt_text" name="edition[images_attributes][0][alt_text]" type="text" />' +
          '</div>' +
          '<div class="form-group">' +
            '<label for="edition_images_attributes_0_caption">Caption</label>' +
            '<textarea id="edition_images_attributes_0_caption" name="edition[images_attributes][0][caption]"></textarea>' +
          '</div>' +
        '</div>' +
      '</fieldset>'
    )

    $(document.body).append(fieldset)
  })

  afterEach(function () {
    fieldset.remove()
  })

  it('should add a new file input when a file is selected', function () {
    fieldset.enableMultipleFileUploads()
    fieldset.find('input[type=file]').click()
    expect(fieldset.children('.file_upload').length).toEqual(2)
  })

  it("shouldn't add extra file inputs if the same one is selected twice", function () {
    fieldset.enableMultipleFileUploads()
    var item = fieldset.find('input[type=file]')
    item.click().click()
    expect(fieldset.children('.file_upload').length).toEqual(2)
  })

  it('should continue adding new inputs as new files are selected', function () {
    fieldset.enableMultipleFileUploads()
    for (var i = 0; i < 10; i++) {
      fieldset.find('input[type=file]:last').click()
    }

    expect(fieldset.children('.file_upload').length).toEqual(11)
  })

  it('should increment the names of new inputs added', function () {
    fieldset.enableMultipleFileUploads()

    var elements = [
      'input[type=file][name="edition[images_attributes][1][image_data_attributes][file]"]',
      'input[type=hidden][name="edition[images_attributes][1][image_data_attributes][file_cache]"]',
      'input[type=text][name="edition[images_attributes][1][alt_text]"]',
      'textarea[name="edition[images_attributes][1][caption]"]'
    ]
    expect($(elements.join(',')).length).toEqual(0)

    fieldset.find('input[type=file]').click()

    expect($(elements.join(',')).length).toEqual(elements.length)
  })

  it('should reset values set on fields', function () {
    fieldset.enableMultipleFileUploads()

    fieldset.find('[name="edition[images_attributes][0][image_data_attributes][file_cache]"]').val('not-blank')
    fieldset.find('[name="edition[images_attributes][0][alt_text]"]').val('not-blank')
    fieldset.find('[name="edition[images_attributes][0][caption]"]').val('not-blank')

    fieldset.find('input[type=file]').click()

    expect(fieldset.find('[name="edition[images_attributes][1][image_data_attributes][file_cache]"]').val()).toEqual('')
    expect(fieldset.find('[name="edition[images_attributes][1][alt_text]"]').val()).toEqual('')
    expect(fieldset.find('[name="edition[images_attributes][1][caption]"]').val()).toEqual('')
  })

  it('should reset an already uploaded warning', function () {
    fieldset.enableMultipleFileUploads()

    var alreadyUploaded = $('<span class="already_uploaded">some-file.pdf already uploaded</span>')
    $('input[type=file]').after(alreadyUploaded)

    fieldset.find('input[type=file]').click()

    expect(fieldset.find('.already_uploaded').length).toEqual(2)
    expect(fieldset.find('.already_uploaded:last').text()).toEqual('')
  })

  describe('uploading files after a file field validation error', function () {
    beforeEach(function () {
      fieldset.remove()
      fieldset = $(
        '<fieldset id="image_fields" class="images multiple_file_uploads">' +
          '<div class="file_upload well">' +
            '<div class="field_with_errors">' +
              '<label for="edition_images_attributes_0_image_data_attributes_file">File</label>' +
            '</div>' +
            '<div class="field_with_errors">' +
              '<input id="edition_images_attributes_0_image_data_attributes_file" name="edition[images_attributes][0][image_data_attributes][file]" type="file" class="js-upload-image-input" />' +
            '</div>' +
            '<input id="edition_images_attributes_0_image_data_attributes_file_cache" name="edition[images_attributes][0][image_data_attributes][file_cache]" type="hidden" />' +
        '</div>' +
      '</fieldset>'
      )

      $(document.body).append(fieldset)
    })

    it('should still allow creating additional file uploads', function () {
      fieldset.enableMultipleFileUploads()
      fieldset.find('input[type=file]').click()
      expect(fieldset.children('.file_upload').length).toEqual(2)
    })

    it("doesn't copy error wrappers", function () {
      fieldset.enableMultipleFileUploads()
      fieldset.find('input[type=file]').click()

      var labelParent = $('label[for=edition_images_attributes_1_image_data_attributes_file]').parent()
      var inputParent = $('input[name="edition[images_attributes][1][image_data_attributes][file]"]').parent()

      expect(labelParent.hasClass('field_with_errors')).toBeFalse()
      expect(inputParent.hasClass('field_with_errors')).toBeFalse()
    })
  })
})
