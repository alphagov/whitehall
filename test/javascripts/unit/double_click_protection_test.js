module("Double click protection", {
  setup: function(){
    this.$form = $('<form action="/go" method="POST"><input type="submit" name="input_name" value="Save" /></form>');

    $('#qunit-fixture').append(this.$form);
  }
});

test('clicking submit input disables the button', function() {
  GOVUK.doubleClickProtection();

  var $submit_tag = this.$form.find('input[type=submit]');
  ok(!$submit_tag.prop('disabled'));

  $submit_tag.on('click', function (e) {
    e.preventDefault();
    ok($submit_tag.prop('disabled'));
  });

  $submit_tag.click();
});

test('clicking submit input creates a hidden input with the same name and value', function() {
  GOVUK.doubleClickProtection();

  var $submit_tag = this.$form.find('input[type=submit]');

  $submit_tag.on('click', function (e) {
    e.preventDefault();
    equal($.find('form input[type=hidden][name=input_name][value=Save]').length, 1);
  });

  $submit_tag.click();
});
