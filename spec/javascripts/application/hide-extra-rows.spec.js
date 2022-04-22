describe('jQuery.hideExtraRows', function () {
  var container, list

  beforeEach(function () {
    var listString = "<ul id='will-wrap' style='width: 400px;'>"
    var i = 0
    while (i < 10) {
      var styles = 'float: left; width: 100px;'
      listString += '<li id="item-' + i + '" style="' + styles + '">Text here</li>'
      i++
    }
    listString += '</ul>'

    list = $(listString)

    // the script adds sibling elements to the list so we need a parent element
    // to remove them all
    container = $('<div />').append(list)
    $(document.body).append(container)
  })

  afterEach(function () {
    container.remove()
  })

  it('should add elements past the first line into a js-hidden element', function () {
    list.hideExtraRows()
    expect($('.js-hidden', list).children().length).toEqual(6)
  })

  it('should move elements past the second line into a js-hidden element', function () {
    list.hideExtraRows({ rows: 2 })
    expect($('.js-hidden', list).children().length).toEqual(2)
  })

  it('should add a toggle button after the parent of the passed in elements', function () {
    list.hideExtraRows()
    expect(list.siblings('.show-other-content').length).toEqual(1)
  })

  it('should remove hidden classes when clicking the show button', function () {
    list.hideExtraRows()
    $('.show-other-content').click()
    expect($('.js-hidden', list).length).toEqual(0)
  })

  it('should be able to wrap show button', function () {
    list.hideExtraRows({ showWrapper: $('<div id="hide-stuff" />') })
    expect($('#hide-stuff > .show-other-content').length).toEqual(1)
  })

  it('should be able to append hide button to parent', function () {
    list.hideExtraRows({ showWrapper: $('<li />'), appendToParent: true })
    expect($('> li > .show-other-content', list).length).toEqual(1)
  })

  it('should clean up button after clicking', function () {
    list.hideExtraRows()
    $('.show-other-content').click()
    expect($('.show-other-content').length).toEqual(0)
  })

  it('should clear up optional parent container after clicking', function () {
    list.hideExtraRows({ showWrapper: $('<div id="hide-stuff" />') })
    $('.show-other-content').click()
    expect($('#hide-stuff').length).toEqual(0)
  })
})
