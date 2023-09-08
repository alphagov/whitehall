describe('GOVUK.Modules.AppAnalytics', function () {
  let appAnalytics

  function addGoogleAnalyticsSpy() {
    if (typeof window.ga === 'undefined') {
      window.ga = function () {}
    }
    spyOn(window, 'ga')
  }

  beforeEach(function () {
    const div = document.createElement('div')

    const metaTag = document.createElement('meta')
    metaTag.setAttribute('name', 'custom-dimension:8')
    metaTag.setAttribute('content', 'Custom dimension 8')
    document.getElementsByTagName('head')[0].appendChild(metaTag)

    appAnalytics = new GOVUK.Modules.AppAnalytics(div)
  })

  afterEach(function () {
    const head = document.getElementsByTagName('head')[0]
    const metaTags = document.querySelectorAll("[name^='custom-dimension']")
    for (let i = 0; i < metaTags.length; i++) {
      head.removeChild(metaTags[i])
    }
  })

  it('should send initial page view', function () {
    spyOn(GOVUK.analytics, 'trackPageview')

    appAnalytics.init()

    expect(GOVUK.analytics.trackPageview).toHaveBeenCalledWith()
  })

  it('should initialise external link tracking analytics', function () {
    spyOn(GOVUK.analyticsPlugins, 'externalLinkTracker')

    appAnalytics.init()

    expect(GOVUK.analyticsPlugins.externalLinkTracker).toHaveBeenCalled()
  })

  it('calls setDimension with the correct arguments', function () {
    spyOn(GOVUK.analytics, 'setDimension')

    appAnalytics.init()

    expect(GOVUK.analytics.setDimension).toHaveBeenCalledWith(
      8,
      'Custom dimension 8'
    )
  })

  it('makes a call to GA to set a custom dimension with the correct dimension and value', function () {
    addGoogleAnalyticsSpy()

    appAnalytics.setCustomDimensionsFromMetaTags()

    expect(window.ga.calls.mostRecent().args).toEqual([
      'set',
      'dimension8',
      'Custom dimension 8'
    ])
  })

  it('can accept additional custom dimensions without overriding old ones', function () {
    addGoogleAnalyticsSpy()

    const metaTag = document.createElement('meta')
    metaTag.setAttribute('name', 'custom-dimension:21')
    metaTag.setAttribute('content', 'Additional custom dimension 21')
    document.getElementsByTagName('head')[0].appendChild(metaTag)

    appAnalytics.setCustomDimensionsFromMetaTags()

    expect(window.ga.calls.count()).toEqual(2)
    expect(window.ga.calls.argsFor(0)).toEqual([
      'set',
      'dimension8',
      'Custom dimension 8'
    ])
    expect(window.ga.calls.mostRecent().args).toEqual([
      'set',
      'dimension21',
      'Additional custom dimension 21'
    ])
  })
})
