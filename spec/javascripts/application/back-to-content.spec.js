describe('GOVUK.backToContent', function () {
  var nav

  beforeEach(function () {
    nav = $('<div class="js-back-to-contents"></div>')
    $(document.body).append(nav)
  })

  afterEach(function () {
    nav.remove()
  })

  it('should add fixed class on stick', function () {
    expect(nav.hasClass('visuallyhidden')).toBeFalsy()
    GOVUK.backToContent.hide(nav)
    expect(nav.hasClass('visuallyhidden')).toBeTruthy()
  })

  it('should remove fixed class on release', function () {
    nav.addClass('visuallyhidden')
    GOVUK.backToContent.show(nav)
    expect(nav.hasClass('visuallyhidden')).toBeFalsy()
  })
})
