module("hide-other-things: hides all but first element in collection", {
  setup: function() {
    this.$list = $(
        '<dl>'
      +   '<dt>The Four Main Animals</dt>'
      +   '<dd class="js-hide-other-links">'
      +     '<a href="http://en.wikipedia.org/wiki/dog">Dog</a>, '
      +     '<a href="http://en.wikipedia.org/wiki/cat">Cat</a>, '
      +     '<a href="http://en.wikipedia.org/wiki/cow">Cow</a> and '
      +     '<a href="http://en.wikipedia.org/wiki/pig">Pig</a>.'
      +   '</dd>'
      + '</dl>');
    $('#qunit-fixture').append(this.$list);
  }
});

test("should group elements into other-content span", function () {
  $('.js-hide-other-links').hideOtherLinks();
  console.log($('.other-content').length);
  ok($('.other-content').length > 0 && $('.other-content').children().length == 3);
});

test("should create a link to show hidden content", function () {
  $('.js-hide-other-links').hideOtherLinks();
  ok($('.show-other-content').length > 0);
});

test("created link should show hidden content", function () {
  $('.js-hide-other-links').hideOtherLinks();
  ok(!$('.other-content').is(":visible"));
  $('.show-other-content').click();
  ok($('.other-content').is(":visible"));
});

test("created link should have correct count", function() {
  $('.js-hide-other-links').hideOtherLinks();
  var otherCount = $('.other-content').find('a').length;
  var linkCount = $('.show-other-content').text().match(/\d+/).pop();
  ok(linkCount == otherCount);
});

test("check fullstop is preserved", function() {
  $('.js-hide-other-links').hideOtherLinks();
  ok($('.js-hide-other-links').text().substr(-1) == ".");
});

test("check element has correct aria value", function() {
  $('.js-hide-other-links').hideOtherLinks();
  ok($('.js-hide-other-links').attr('aria-live') == polite);
});

