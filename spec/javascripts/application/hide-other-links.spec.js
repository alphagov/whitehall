describe('jQuery.hideOtherLinks', function () {
  var list

  beforeEach(function () {
    list = $(
      '<dl>' +
        '<dt>The Four Main Animals</dt>' +
        '<dd class="animals js-hide-other-links">' +
          '<a class="force" href="http://en.wikipedia.org/wiki/dog">Dog</a>, ' +
          '<a class="force" href="http://en.wikipedia.org/wiki/cat">Cat</a>, ' +
          '<a href="http://en.wikipedia.org/wiki/cow">Cow</a> and ' +
          '<a href="http://en.wikipedia.org/wiki/pig">Pig</a>.' +
        '</dd>' +
        '<dt>The Four Main Colours</dt>' +
        '<dd class="colours js-hide-other-links">' +
          '<span><a href="http://en.wikipedia.org/wiki/red">Red</a></span>, ' +
          '<span><a href="http://en.wikipedia.org/wiki/green">Green</a></span>, ' +
          '<span><a href="http://en.wikipedia.org/wiki/blue">Blue</a></span> and ' +
          '<span><a href="http://en.wikipedia.org/wiki/yello">Yellow</a></span>.' +
        '</dd>' +
        '<dt>The Two Main Four Main Things</dt>' +
        '<dd class="main-things js-hide-other-links">' +
          '<a href="http://en.wikipedia.org/wiki/animals">Animals</a>, ' +
          '<a href="http://en.wikipedia.org/wiki/colours">Colours</a>, ' +
        '</dd>' +
        '<dt>The Two Main Really Long Words</dt>' +
        '<dd class="long-words js-hide-other-links">' +
          '<a href="http://en.wikipedia.org/wiki/Lopado­temacho­selacho­galeo­kranio­leipsano­drim­hypo­trimmato­silphio­parao­melito­katakechy­meno­kichl­epi­kossypho­phatto­perister­alektryon­opte­kephallio­kigklo­peleio­lagoio­siraio­baphe­tragano­pterygon">Lopado­temacho­selacho­galeo­kranio­leipsano­drim­hypo­trimmato­silphio­parao­melito­katakechy­meno­kichl­epi­kossypho­phatto­perister­alektryon­opte­kephallio­kigklo­peleio­lagoio­siraio­baphe­tragano­pterygon</a>, ' +
          '<a href="http://en.wikipedia.org/wiki/Pneumonoultramicroscopicsilicovolcanoconiosis">Pneumonoultramicroscopicsilicovolcanoconiosis</a>, ' +
        '</dd>' +
      '</dl>'
    )
    $(document.body).append(list)
  })

  afterEach(function () {
    list.remove()
  })

  it('should group elements into other-content span', function () {
    $('.js-hide-other-links').hideOtherLinks()
    expect($('.animals .other-content').children().length).toEqual(3)
  })

  it('should create a link to show hidden content', function () {
    $('.js-hide-other-links').hideOtherLinks()
    expect($('.animals .show-other-content').length).toEqual(1)
  })

  it('should show hidden content when the other-content link is clicked', function () {
    $('.js-hide-other-links').hideOtherLinks()
    expect($('.animals .other-content').is(':visible')).toBeFalse()
    $('.show-other-content').click()
    expect($('.animals .other-content').is(':visible')).toBeTrue()
  })

  it('should have correct count in the link', function () {
    $('.js-hide-other-links').hideOtherLinks()
    var otherCount = $('.animals .other-content').find('a').length
    var linkCount = $('.animals .show-other-content').text().match(/\d+/).pop()
    expect(parseInt(linkCount, 10)).toEqual(otherCount)
  })

  it('should preserve a full stop', function () {
    $('.js-hide-other-links').hideOtherLinks()
    expect($('.animals.js-hide-other-links').text().substr(-1)).toEqual('.')
  })

  it('should set the correct aria value', function () {
    $('.js-hide-other-links').hideOtherLinks()
    expect($('.animals.js-hide-other-links').attr('aria-live')).toEqual('polite')
  })

  it('should allow different elements to be used as wrapper', function () {
    $('.js-hide-other-links').hideOtherLinks({ linkElement: 'span' })
    expect($('.colours .other-content').children().length).toEqual(3)
  })

  it('should allow a force class to keep an element visibile', function () {
    $('.js-hide-other-links').hideOtherLinks({ alwaysVisibleClass: '.force' })
    expect($('.animals .other-content').children().length).toEqual(2)
  })

  it("shouldn't hide items if there are only 2 links and they are short", function () {
    $('.js-hide-other-links').hideOtherLinks()
    expect($('.main-things .other-content').length).toEqual(0)
  })

  it('should hide items when there are only 2 links but they are very long', function () {
    $('.js-hide-other-links').hideOtherLinks()
    expect($('.long-words .other-content').children().length).toEqual(1)
  })

  it('should accept showCount to specify amount of links to show', function () {
    $('.js-hide-other-links').hideOtherLinks({ showCount: 3 })
    expect($('.animals').children('a:not(.show-other-content)').length).toEqual(3)
    expect($('.animals .other-content').children().length).toEqual(1)
  })

  it('when showCount is 0, it hides everything', function () {
    $('.js-hide-other-links').hideOtherLinks({ showCount: 0 })
    expect($('.animals').children('a:not(.show-other-content)').length).toEqual(0)
    expect($('.animals .other-content').children().length).toEqual(4)
  })
})
