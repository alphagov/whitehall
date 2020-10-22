module('Filter List Itmes', {
  setup: function () {
    this.$list = $('<ol class="js-filter-block">' +
                  '<li class="js-filter-item" data-filter-terms="pete">Pete</li>' +
                  '<li class="js-filter-item" data-filter-terms="neil">Neil</li>' +
                  '<li class="js-filter-item" data-filter-terms="ross">Ross</li>' +
                  '</ol>')
    $('#qunit-fixture').append(this.$list)

    this.$filterList = $('<div class="js-filter-list"></div>')
    $('#qunit-fixture').append(this.$filterList)
  }
})

test('should find filter terms', function () {
  GOVUK.filterListItems.init()
  var expected = {
    pete: $('.js-filter-item[data-filter-terms=pete]')[0],
    neil: $('.js-filter-item[data-filter-terms=neil]')[0],
    ross: $('.js-filter-item[data-filter-terms=ross]')[0]
  }
  deepEqual(GOVUK.filterListItems.getFilterTerms(), expected)
})
test('should select filter items that match search', function () {
  GOVUK.filterListItems.init()
  var expected = [
    $('.js-filter-item[data-filter-terms=pete]').text(),
    $('.js-filter-item[data-filter-terms=neil]').text()
  ]
  var actual = GOVUK.filterListItems.getItems('e').map(function (el) { return el.innerText })
  deepEqual(actual, expected)
})
test('should hide empty blocks if no items are shown', function () {
  GOVUK.filterListItems.init()
  equal($('.js-filter-block:visible').length, 1)
  GOVUK.filterListItems.hideEmptyBlocks([])
  equal($('.js-filter-block:visible').length, 0)
})
test('should hide empty blocks if no items are from block are shown', function () {
  GOVUK.filterListItems.init()
  $('.js-filter-item').hide()
  equal($('.js-filter-block:visible').length, 1)
  GOVUK.filterListItems.hideEmptyBlocks(['elements', 'visible'])
  equal($('.js-filter-block:visible').length, 0)
})
