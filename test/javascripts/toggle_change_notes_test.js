module("Toggle change notes", {
  setup: function() {
    $('#qunit-fixture').append('<div class="changes"><h1>updated 6 days ago</h1><div class="overlay"></div></div>');
    $.fx.off = true;
  }
});

function init_plugin(options) {
  options = $.extend({ header: 'h1', content: '.overlay' }, options);
  $('.changes').toggleChangeNotes(options);
}

test("Should be hidden on load", function () {
  init_plugin();
  ok($('.overlay').is(':hidden'));
});

test("Should take a header selector and wrap a link around the contents", function () {
  init_plugin();
  equals($('.changes h1 a').length, 1);
});

test("Should make the on click event of the header link toggle the overlay element", function () {
  init_plugin();
  ok($('.overlay').is(':hidden'));
  $('.changes h1 a').click();
  ok($('.overlay').is(':visible'));
  $('.changes h1 a').click();
  ok($('.overlay').is(':hidden'));
});

test("If change notes aren't present on the page then the link shouldn't be attached", function () {
  $('.element-that-wont-exist').toggleChangeNotes();
  equals($('.changes h1 a').length, 0);
});
