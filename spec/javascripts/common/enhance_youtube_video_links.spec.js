describe('jQuery.enhanceYoutubeVideoLinks', function () {
  let container
  beforeEach(function () {
    container = $('<div id="wrap"><p><a></a></p></div>')
    $(document.body).append(container)
    spyOn($.fn, 'player').and.returnValue(true)
  })

  afterEach(function () {
    container.remove()
  })

  it('should replace tiny youtube links', function () {
    container.find('a').attr('href', 'http://youtu.be/tinyVideo')
    container.enhanceYoutubeVideoLinks()

    expect($.fn.player).toHaveBeenCalledWith(
      jasmine.objectContaining({
        media: 'tinyVideo'
      })
    )
  })

  it('should replace short youtube links', function () {
    container.find('a').attr('href', 'http://youtube.com/watch?v=shortVideo')
    container.enhanceYoutubeVideoLinks()

    expect($.fn.player).toHaveBeenCalledWith(
      jasmine.objectContaining({
        media: 'shortVideo'
      })
    )
  })

  it('should replace medium youtube links', function () {
    container
      .find('a')
      .attr('href', 'http://youtube.com/watch?v=mediumVideo&source=twitter')
    container.enhanceYoutubeVideoLinks()

    expect($.fn.player).toHaveBeenCalledWith(
      jasmine.objectContaining({
        media: 'mediumVideo'
      })
    )
  })

  it('should do nothing if no video id is found', function () {
    container.find('a').attr('href', 'http://youtube.com/watch?wrong=parameter')
    container.enhanceYoutubeVideoLinks()

    expect($.fn.player).not.toHaveBeenCalled()
  })
})
