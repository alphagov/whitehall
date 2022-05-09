describe('GOVUK.filterListItems', function () {
  var container

  beforeEach(function () {
    container = $(
      '<div>' +
        '<ol class="js-filter-block">' +
          '<li class="js-filter-item" data-filter-terms="pete">Pete</li>' +
          '<li class="js-filter-item" data-filter-terms="neil">Neil</li>' +
          '<li class="js-filter-item" data-filter-terms="ross">Ross</li>' +
        '</ol>' +
        '<div class="js-filter-list" />' +
      '</div>'
    )
    $(document.body).append(container)
  })

  afterEach(function () {
    container.remove()
  })

  it('should find filter terms', function () {
    GOVUK.filterListItems.init()

    var expected = {
      pete: $('.js-filter-item[data-filter-terms=pete]')[0],
      neil: $('.js-filter-item[data-filter-terms=neil]')[0],
      ross: $('.js-filter-item[data-filter-terms=ross]')[0]
    }
    expect(GOVUK.filterListItems.getFilterTerms()).toEqual(expected)
  })

  it('should select filter items that match search', function () {
    GOVUK.filterListItems.init()
    var expected = [
      $('.js-filter-item[data-filter-terms=pete]').text(),
      $('.js-filter-item[data-filter-terms=neil]').text()
    ]
    var actual = GOVUK.filterListItems.getItems('e').map(function (el) { return el.innerText })
    expect(actual).toEqual(expected)
  })

  it('should hide empty blocks if no items are shown', function () {
    GOVUK.filterListItems.init()
    expect($('.js-filter-block:visible').length).toEqual(1)
    GOVUK.filterListItems.hideEmptyBlocks([])
    expect($('.js-filter-block:visible').length).toEqual(0)
  })

  it('should hide empty blocks if no items are from block are shown', function () {
    GOVUK.filterListItems.init()
    $('.js-filter-item').hide()
    expect($('.js-filter-block:visible').length).toEqual(1)
    GOVUK.filterListItems.hideEmptyBlocks(['elements', 'visible'])
    expect($('.js-filter-block:visible').length).toEqual(0)
  })
})
