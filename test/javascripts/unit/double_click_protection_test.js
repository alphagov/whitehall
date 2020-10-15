module('Double click protection', {
  setup: function () {
    this.$form = $('<form action="/go" method="POST"><input type="submit" name="input_name" value="Save" /></form>')

    $('#qunit-fixture').append(this.$form)

    GOVUK.doubleClickProtection()
  }
})

test('clicking submit input disables the button', function () {
  var $submitTag = this.$form.find('input[type=submit]')
  ok(!$submitTag.prop('disabled'))

  this.$form.on('submit', function (e) {
    e.preventDefault()
    ok($submitTag.prop('disabled'))
  })

  $submitTag.click()
})

test('clicking submit input creates a hidden input with the same name and value', function () {
  var $submitTag = this.$form.find('input[type=submit]')

  this.$form.on('submit', function (e) {
    e.preventDefault()
    ok($('form input[type=hidden][name=input_name][value=Save]').length > 0)
  })

  $submitTag.click()
})
