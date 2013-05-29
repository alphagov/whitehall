module("create-new", {
  setup: function() {
    $('#qunit-fixture').append('<div class="js-create-new"><strong>toggle</strong><span class="dropdown-menu">menu</span></div>');
  }
});

test("should toggle visiblilty", function () {
  var $dropdown = $('.dropdown-menu');
  GOVUK.createNew.init();
  ok($dropdown.is(':visible'));
  GOVUK.createNew.toggle();
  ok(!$dropdown.is(':visible'));
  GOVUK.createNew.toggle();
  ok($dropdown.is(':visible'));
});

