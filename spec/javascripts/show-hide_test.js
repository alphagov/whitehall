module('show-hide: toggles a named element', {
  setup: function () {
    this.$link = $('<a href="#my-target-element" class="js-showhide">Show</a>')
    $('#qunit-fixture').append(this.$link)

    this.$element = $('<div id="my-target-element">element</div>')
    $('#qunit-fixture').append(this.$element)
  }
})

test('should hide element on init', function () {
  ok(!this.$element.hasClass('js-hidden'), 'is visible')
  GOVUK.showHide.init()
  ok(this.$element.hasClass('js-hidden'), 'is hidden')
})

test('should show element', function () {
  GOVUK.showHide.init()
  GOVUK.showHide.hideStuff()
  ok(this.$element.hasClass('js-hidden'), 'is hidden')
  GOVUK.showHide.showStuff()
  ok(!this.$element.hasClass('js-hidden'), 'is visible')
})

test('should hide element', function () {
  GOVUK.showHide.init()
  GOVUK.showHide.showStuff()
  ok(!this.$element.hasClass('js-hidden'), 'is visible')
  GOVUK.showHide.hideStuff()
  ok(this.$element.hasClass('js-hidden'), 'is hidden')
})

test('should update the toggle on show', function () {
  GOVUK.showHide.init()
  GOVUK.showHide.showStuff()
  ok(!this.$link.hasClass('closed'))
  equal(this.$link.text(), 'Hide')
})

test('should update the toggle on hide', function () {
  GOVUK.showHide.init()
  GOVUK.showHide.hideStuff()
  ok(this.$link.hasClass('closed'))
  equal(this.$link.text(), 'Show')
})

test('should toggle visibily', function () {
  GOVUK.showHide.init()
  GOVUK.showHide.hideStuff()

  GOVUK.showHide.toggle({ preventDefault: function () {} })
  ok(!this.$link.hasClass('closed'), 'is open')
  equal(this.$link.text(), 'Hide')

  GOVUK.showHide.toggle({ preventDefault: function () {} })
  ok(this.$link.hasClass('closed'), 'is closed')
  equal(this.$link.text(), 'Show')
})

test('should toggle visibility on click', function () {
  GOVUK.showHide.init()

  GOVUK.showHide.hideStuff()

  this.$link.trigger('click')
  ok(!this.$link.hasClass('closed'), 'is open')
  equal(this.$link.text(), 'Hide')

  this.$link.trigger('click')
  ok(this.$link.hasClass('closed'), 'is closed')
  equal(this.$link.text(), 'Show')
})
