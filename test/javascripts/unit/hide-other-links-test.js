module("hide-other-things: hides all but first element in collection", {
  setup: function() {
    this.$list = $(
        '<dl>'
      +   '<dt>The Four Main Animals</dt>'
      +   '<dd class="animals js-hide-other-links">'
      +     '<a class="force" href="http://en.wikipedia.org/wiki/dog">Dog</a>, '
      +     '<a class="force" href="http://en.wikipedia.org/wiki/cat">Cat</a>, '
      +     '<a href="http://en.wikipedia.org/wiki/cow">Cow</a> and '
      +     '<a href="http://en.wikipedia.org/wiki/pig">Pig</a>.'
      +   '</dd>'
      +   '<dt>The Four Main Colours</dt>'
      +   '<dd class="colours js-hide-other-links">'
      +     '<span><a href="http://en.wikipedia.org/wiki/red">Red</a></span>, '
      +     '<span><a href="http://en.wikipedia.org/wiki/green">Green</a></span>, '
      +     '<span><a href="http://en.wikipedia.org/wiki/blue">Blue</a></span> and '
      +     '<span><a href="http://en.wikipedia.org/wiki/yello">Yellow</a></span>.'
      +   '</dd>'
      +   '<dt>The Two Main Four Main Things</dt>'
      +   '<dd class="main-things js-hide-other-links">'
      +     '<span><a href="http://en.wikipedia.org/wiki/animals">Animals</a></span>, '
      +     '<span><a href="http://en.wikipedia.org/wiki/colours">Colours</a></span>, '
      +   '</dd>'
      + '</dl>');
    $('#qunit-fixture').append(this.$list);
  }
});

test("should group elements into other-content span", function () {
  $('.js-hide-other-links').hideOtherLinks();
  ok($('.animals .other-content').length > 0 && $('.animals .other-content').children().length == 3);
});

test("should create a link to show hidden content", function () {
  $('.js-hide-other-links').hideOtherLinks();
  ok($('.animals .show-other-content').length > 0);
});

test("created link should show hidden content", function () {
  $('.js-hide-other-links').hideOtherLinks();
  ok(!$('.animals .other-content').is(":visible"));
  $('.show-other-content').click();
  ok($('.animals .other-content').is(":visible"));
});

test("created link should have correct count", function() {
  $('.js-hide-other-links').hideOtherLinks();
  var otherCount = $('.animals .other-content').find('a').length;
  var linkCount = $('.animals .show-other-content').text().match(/\d+/).pop();
  ok(linkCount == otherCount);
});

test("check fullstop is preserved", function() {
  $('.js-hide-other-links').hideOtherLinks();
  ok($('.animals.js-hide-other-links').text().substr(-1) == ".");
});

test("check element has correct aria value", function() {
  $('.js-hide-other-links').hideOtherLinks();
  ok($('.animals.js-hide-other-links').attr('aria-live') == "polite");
});

test("check different elements can be used as wrapper", function() {
  $('.js-hide-other-links').hideOtherLinks({ linkElement: 'span' });
  ok($('.colours .other-content').length > 0 && $('.colours .other-content').children().length == 3);
});

test("check class can be used to force elements to be visible", function() {
  $('.js-hide-other-links').hideOtherLinks({ alwaysVisibleClass: '.force' });
  ok($('.animals .other-content').length > 0 && $('.animals .other-content').children().length == 2);
});

test("when there are only two things, they are not hidden", function() {
  $('.js-hide-other-links').hideOtherLinks();
  ok($('.main-things .other-content').length === 0);
});

