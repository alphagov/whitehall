describe('jQuery.toggler', function () {
  var changes

  beforeEach(function () {
    changes = $('<div class="changes"><h1>updated 6 days ago</h1><div class="overlay"></div></div>')
    $(document.body).append(changes)
  })

  afterEach(function () {
    changes.remove()
  })

  it('should be hidden on initialise', function () {
    $('.changes').toggler({ header: 'h1', content: '.overlay' })
    expect($('.overlay').hasClass('visuallyhidden')).toBeTrue()
  })

  it('should make the on click event of the header toggle the overlay element', function () {
    $('.changes').toggler({ header: 'h1', content: '.overlay' })
    expect($('.overlay').hasClass('visuallyhidden')).toBeTrue()
    $('.changes h1').click()
    expect($('.overlay').hasClass('visuallyhidden')).toBeTrue()
    $('.changes h1').click()
    expect($('.overlay').hasClass('visuallyhidden')).toBeTrue()
  })
})
