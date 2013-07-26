module("Stick at top when scrolling", {
  setup: function(){
    this.$nav = $('<div class="stick-at-top-when-scrolling"></div>');

    $('#qunit-fixture').append(this.$nav);
  }
});

test('should add fixed class on stick', function(){
  ok(!this.$nav.hasClass('content-fixed'));
  GOVUK.stickAtTopWhenScrolling.stick(this.$nav);
  ok(this.$nav.hasClass('content-fixed'));
});

test('should remove fixed class on release', function(){
  this.$nav.addClass('content-fixed');
  GOVUK.stickAtTopWhenScrolling.release(this.$nav);
  ok(!this.$nav.hasClass('content-fixed'));
});

test('should insert shim when sticking content', function(){
  equal($('.shim').length, 0);
  GOVUK.stickAtTopWhenScrolling.stick(this.$nav);
  equal($('.shim').length, 1);
});

test('should insert shim with minimum height', function(){
  GOVUK.stickAtTopWhenScrolling.stick(this.$nav);
  equal($('.shim').height(), 1);
});

