describe('jQuery.enableSortable', function () {
  var container, fieldset

  beforeEach(function () {
    fieldset = $(
      '<fieldset>' +
        '<div><label for="input_one">one <input name="input_one" type="text" /></label><label for="other_thing_one">other thing: <input name="other_thing_one" type="text" /></label></div>' +
        '<div><label for="input_two">two <input name="input_two" type="text" /></label><label for="other_thing_two">other thing: <input name="other_thing_two" type="text" /></label></div>' +
      '</fieldset>'
    )
    container = $('<div />').append(fieldset)
    $(document.body).append(container)
  })

  afterEach(function () {
    container.remove()
  })

  it('should build a list from the contents of the labels', function () {
    fieldset.enableSortable()
    var listText = fieldset
      .siblings('ul')
      .children()
      .map(function () { return $(this).text() })
      .get()
    expect(listText).toEqual(['one other thing: ', 'two other thing: '])
  })

  it('should hide the input fields', function () {
    fieldset.enableSortable()
    expect(fieldset.children('input').is(':visible')).toBeFalse()
  })
})
