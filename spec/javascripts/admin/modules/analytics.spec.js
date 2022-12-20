describe('GOVUK.analytics', function () {
  'use strict'
  var GOVUK = window.GOVUK

  function addGoogleAnalyticsSpy () {
    if (typeof window.ga === 'undefined') {
      window.ga = function () {}
    }
    spyOn(window, 'ga')
  }

  describe('setCustomDimensionsFromMetaTags', function () {
    var metaTag

    beforeEach(function () {
      metaTag = document.createElement('meta')
      metaTag.setAttribute('name', 'custom-dimension:8')
      metaTag.setAttribute('content', 'Custom dimension 8')
      document.getElementsByTagName('head')[0].appendChild(metaTag)
    })

    afterEach(function () {
      var head = document.getElementsByTagName('head')[0]
      var metaTags = document.querySelectorAll("[name^='custom-dimension']")
      for (var i = 0; i < metaTags.length; i++) {
        head.removeChild(metaTags[i])
      }
    })

    it('calls setDimension with the correct arguments', function () {
      spyOn(GOVUK.analytics, 'setDimension')

      GOVUK.setCustomDimensionsFromMetaTags()

      expect(GOVUK.analytics.setDimension).toHaveBeenCalledWith(
        8,
        'Custom dimension 8'
      )
    })

    it('makes a call to GA to set a custom dimension with the correct dimension and value', function () {
      addGoogleAnalyticsSpy()

      GOVUK.setCustomDimensionsFromMetaTags()

      expect(window.ga.calls.mostRecent().args).toEqual(
        ['set', 'dimension8', 'Custom dimension 8']
      )
    })

    it('can accept additional custom dimensions without overriding old ones', function () {
      addGoogleAnalyticsSpy()
      metaTag = document.createElement('meta')
      metaTag.setAttribute('name', 'custom-dimension:21')
      metaTag.setAttribute('content', 'Additional custom dimension 21')
      document.getElementsByTagName('head')[0].appendChild(metaTag)

      GOVUK.setCustomDimensionsFromMetaTags()

      expect(window.ga.calls.count()).toEqual(2)
      expect(window.ga.calls.argsFor(0)).toEqual(
        ['set', 'dimension8', 'Custom dimension 8']
      )
      expect(window.ga.calls.mostRecent().args).toEqual(
        ['set', 'dimension21', 'Additional custom dimension 21']
      )
    })
  })
})
