module('Toggler', {
  setup: function () {
    $('#qunit-fixture').append('<div class="changes"><h1>updated 6 days ago</h1><div class="overlay"></div></div>')
    $.fx.off = true
  }
})

function initPlugin (options) {
  options = $.extend({ header: 'h1', content: '.overlay' }, options)
  $('.changes').toggler(options)
}

test('Should be hidden on load', function () {
  initPlugin()
  ok($('.overlay').hasClass('visuallyhidden'))
})

test('Should make the on click event of the header toggle the overlay element', function () {
  initPlugin()
  ok($('.overlay').hasClass('visuallyhidden'))
  $('.changes h1').click()
  ok($('.overlay').hasClass('visuallyhidden'))
  $('.changes h1').click()
  ok($('.overlay').hasClass('visuallyhidden'))
})
