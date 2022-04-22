describe('GOVUK.showHide', function () {
  var container, link, element

  beforeEach(function () {
    link = $('<a href="#my-target-element" class="js-showhide">Show</a>')
    element = $('<div id="my-target-element">element</div>')

    container = $('<div />').append(link, element)

    $(document.body).append(container)
  })

  afterEach(function () {
    container.remove()
  })

  it('should hide element on init', function () {
    expect(element.hasClass('js-hidden')).toBeFalse()
    GOVUK.showHide.init()
    expect(element.hasClass('js-hidden')).toBeTrue()
  })

  it('should allow programatically showing', function () {
    GOVUK.showHide.init()
    GOVUK.showHide.showStuff()
    expect(element.hasClass('js-hidden')).toBeFalse()
    expect(link.hasClass('closed')).toBeFalse()
    expect(link.text()).toEqual('Hide')
  })

  it('should allow programatically hiding', function () {
    GOVUK.showHide.init()
    GOVUK.showHide.hideStuff()
    expect(element.hasClass('js-hidden')).toBeTrue()
    expect(link.hasClass('closed')).toBeTrue()
    expect(link.text()).toEqual('Show')
  })

  it('should toggle visibily programmatically', function () {
    GOVUK.showHide.init()
    GOVUK.showHide.toggle({ preventDefault: function () {} })
    expect(element.hasClass('js-hidden')).toBeFalse()
    GOVUK.showHide.toggle({ preventDefault: function () {} })
    expect(element.hasClass('js-hidden')).toBeTrue()
  })

  it('should toggle visibility on click', function () {
    GOVUK.showHide.init()
    link.trigger('click')
    expect(element.hasClass('js-hidden')).toBeFalse()
    link.trigger('click')
    expect(element.hasClass('js-hidden')).toBeTrue()
  })
})
