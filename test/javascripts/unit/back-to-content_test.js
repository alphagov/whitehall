module("Back to contents", {
  setup: function(){
    this.$nav = $('<div class="js-back-to-contents"></div>');

    $('#qunit-fixture').append(this.$nav);
  }
});

test('should add fixed class on stick', function(){
  ok(!this.$nav.hasClass('visuallyhidden'));
  GOVUK.backToContent.hide(this.$nav);
  ok(this.$nav.hasClass('visuallyhidden'));
});

test('should remove fixed class on release', function(){
  this.$nav.addClass('visuallyhidden');
  GOVUK.backToContent.show(this.$nav);
  ok(!this.$nav.hasClass('visuallyhidden'));
});


