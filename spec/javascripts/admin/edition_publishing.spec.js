describe('enableChangeNoteHighlighting', function () {
  var publishingForm, container

  beforeEach(function () {
    publishingForm = $(
      '<form>' +
        '<label for="edition_change_note" />' +
        '<textarea id="edition_change_note" />' +
        '<input type="submit" value="Publish" />' +
      '</form>'
    )

    // use a container element as the JS will insert sibling elements to the form
    container = $('<div>').append(publishingForm)
    $(document.body).append(container)
  })

  afterEach(function () {
    container.remove()
  })

  it('should hide the the form and insert a publish button', function () {
    publishingForm.enableChangeNoteHighlighting()

    expect(publishingForm.is(':hidden')).toBeTrue()
    expect(publishingForm.prev("a.button[href='#edition_publishing']").text()).toEqual('Publish')
  })

  it('should name the new button based on the the input value', function () {
    publishingForm.find('input').val('Force Publish')

    publishingForm.enableChangeNoteHighlighting()

    expect(publishingForm.prev("a.button[href='#edition_publishing']").text()).toEqual('Force Publish')
  })

  describe('when the publish button is clicked', function () {
    beforeEach(function () {
      publishingForm.enableChangeNoteHighlighting()
      publishingForm.prev('a.button').click()
    })

    it('should hide the publishing button', function () {
      expect(publishingForm.prev('a.button').is(':hidden')).toBeTrue()
    })

    it('should wrap the label and textarea in error indicators', function () {
      expect(publishingForm.find('label').parent().hasClass('field_with_errors')).toBeTrue()
      expect(publishingForm.find('textarea').parent().hasClass('field_with_errors')).toBeTrue()
    })

    it('should show the form', function () {
      expect(publishingForm.is(':visible')).toBeTrue()
    })
  })

  describe("when there isn't a change note field", function () {
    beforeEach(function () {
      publishingForm.find('textarea').remove()
    })

    it('should not hide the the form', function () {
      publishingForm.enableChangeNoteHighlighting()

      expect(publishingForm.is(':hidden')).toBeFalse()
    })
  })
})
