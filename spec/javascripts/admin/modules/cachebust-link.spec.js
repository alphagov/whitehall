describe('GOVUK.Modules.CachebustLink', function () {
  let link, module

  beforeEach(function () {
    jasmine.clock().install()
    jasmine.clock().mockDate(new Date(1_700_000_000_000))

    link = document.createElement('a')
    link.setAttribute('data-module', 'CachebustLink')
    link.href =
      'https://draft-origin.test.gov.uk/government/publications/foo?cachebust=1&locale=en'

    module = new GOVUK.Modules.CachebustLink(link)
    module.init()
  })

  afterEach(function () {
    jasmine.clock().uninstall()
  })

  it('rewrites the cachebust query param to the current unix-epoch on pointerdown', function () {
    link.dispatchEvent(new Event('pointerdown'))

    const url = new URL(link.href)
    expect(url.searchParams.get('cachebust')).toEqual('1700000000')
  })

  it('rewrites the cachebust query param to the current unix-epoch on focus', function () {
    link.dispatchEvent(new Event('focus'))

    const url = new URL(link.href)
    expect(url.searchParams.get('cachebust')).toEqual('1700000000')
  })

  it('preserves other query params when refreshing the cachebust', function () {
    link.dispatchEvent(new Event('pointerdown'))

    const url = new URL(link.href)
    expect(url.searchParams.get('locale')).toEqual('en')
  })

  it('preserves the path and host when refreshing the cachebust', function () {
    link.dispatchEvent(new Event('pointerdown'))

    const url = new URL(link.href)
    expect(url.host).toEqual('draft-origin.test.gov.uk')
    expect(url.pathname).toEqual('/government/publications/foo')
  })

  it('reflects the latest current time on each interaction', function () {
    link.dispatchEvent(new Event('focus'))
    jasmine.clock().tick(60_000)
    link.dispatchEvent(new Event('pointerdown'))

    const url = new URL(link.href)
    expect(url.searchParams.get('cachebust')).toEqual('1700000060')
  })

  it('leaves the href untouched when there is no cachebust query param', function () {
    const liveLink = document.createElement('a')
    liveLink.href = 'https://www.test.gov.uk/government/publications/foo'
    const originalHref = liveLink.href

    new GOVUK.Modules.CachebustLink(liveLink).init()
    liveLink.dispatchEvent(new Event('pointerdown'))
    liveLink.dispatchEvent(new Event('focus'))

    expect(liveLink.href).toEqual(originalHref)
  })
})
