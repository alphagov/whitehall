describe('GOVUK.analyticsGa4.analyticsModules.Ga4SearchResultsSetup', function () {
  const container = document.createElement('div')
  container.id = 'container'
  document.body.appendChild(container)

  describe('if search outside tabs component', function () {
    it('start Ga4EcommerceTracker', function () {
      container.innerHTML = `
        <div data-ga4-ecommerce></div>
      `

      const mockGa4EcommerceTrackerInit = spyOn(
        window.GOVUK.analyticsGa4.Ga4EcommerceTracker,
        'init'
      )

      window.GOVUK.analyticsGa4.analyticsModules.Ga4SearchResultsSetup.init(
        true
      )

      expect(mockGa4EcommerceTrackerInit).toHaveBeenCalled()
    })
  })

  describe('if search within tabs component', function () {
    const sections = [
      `<section id="not-search"></section>`,
      `<section id="search"><div data-ga4-ecommerce></div></section>`
    ]

    beforeEach(function () {
      container.innerHTML = `
        <div data-module="govuk-tabs">
        </div>
      `
    })

    describe('does start Ga4EcommerceTracker', function () {
      it('when search in first tab and hash empty', function () {
        container.querySelector('div').innerHTML = Array.from(sections)
          .reverse()
          .join('')

        const mockGa4EcommerceTrackerInit = spyOn(
          window.GOVUK.analyticsGa4.Ga4EcommerceTracker,
          'init'
        )

        window.GOVUK.analyticsGa4.analyticsModules.Ga4SearchResultsSetup.init(
          true
        )

        expect(mockGa4EcommerceTrackerInit).toHaveBeenCalled()
      })

      it('when hash equal to id of tab section on init', function () {
        container.querySelector('div').innerHTML = sections.join('')

        const mockGa4EcommerceTrackerInit = spyOn(
          window.GOVUK.analyticsGa4.Ga4EcommerceTracker,
          'init'
        )

        window.location = '#search'

        window.GOVUK.analyticsGa4.analyticsModules.Ga4SearchResultsSetup.init(
          true
        )

        expect(mockGa4EcommerceTrackerInit).toHaveBeenCalled()
      })

      it('when hash equal to id of tab section after init', function () {
        container.querySelector('div').innerHTML = sections.join('')

        const mockGa4EcommerceTrackerInit = spyOn(
          window.GOVUK.analyticsGa4.Ga4EcommerceTracker,
          'init'
        )

        window.GOVUK.analyticsGa4.analyticsModules.Ga4SearchResultsSetup.init()

        window.location = '#search'

        // this event would fire in browser on hash change
        // when the tab component changes the URL on
        // changing a tab
        window.dispatchEvent(new Event('hashchange'))

        expect(mockGa4EcommerceTrackerInit).toHaveBeenCalled()
      })
    })

    describe('does not start Ga4EcommerceTracker', function () {
      it('when search not in first tab and hash empty', function () {
        container.querySelector('div').innerHTML = sections.join('')

        const mockGa4EcommerceTrackerInit = spyOn(
          window.GOVUK.analyticsGa4.Ga4EcommerceTracker,
          'init'
        )

        window.GOVUK.analyticsGa4.analyticsModules.Ga4SearchResultsSetup.init(
          true
        )

        expect(mockGa4EcommerceTrackerInit).not.toHaveBeenCalled()
      })

      it(`when search in first tab and hash not id of first tab`, function () {
        window.location = '#not-search'

        container.querySelector('div').innerHTML = Array.from(sections)
          .reverse()
          .join('')

        const mockGa4EcommerceTrackerInit = spyOn(
          window.GOVUK.analyticsGa4.Ga4EcommerceTracker,
          'init'
        )

        window.GOVUK.analyticsGa4.analyticsModules.Ga4SearchResultsSetup.init(
          true
        )

        expect(mockGa4EcommerceTrackerInit).not.toHaveBeenCalled()
      })
    })

    afterEach(function () {
      window.location = '#'
    })
  })

  afterAll(function () {
    container.remove()
  })
})
