describe('GOVUKAdmin.Modules.TrackLinkClick', function () {
  var link, trackLinkClick

  beforeEach(function () {
    link = $('<a href="/blah" data-module="track-link-click" data-track-category="track-category" data-track-action="track-action" data-track-label="track-label">blahhh</a>')
    $(document.body).append(link)

    trackLinkClick = new GOVUKAdmin.Modules.TrackLinkClick()
  })

  afterEach(function () {
    link.remove()
  })

  it('should send a tracking event when link is clicked', function () {
    spyOn(GOVUKAdmin, 'trackEvent')

    trackLinkClick.start(link)
    link.click()

    expect(GOVUKAdmin.trackEvent).toHaveBeenCalledWith('track-category', 'track-action', { label: 'track-label' })
  })
})
