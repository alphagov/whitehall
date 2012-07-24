/*jslint indent: 2, white: true, sloppy: true */
/*global $, test, equal, notEqual */
module("Show extra topic links", {
  setup: function() {
    this.container1 = $(
      '<div class="meta-topic">' +
        '<p class="topics">Part of <a href="">Topic A</a>, <a href="">Topic B</a> and <a href="">Topic C</a>.</p>' +
        '</div>');
    $('#qunit-fixture').append(this.container1);
  }
});

test("should hide additional links", function() {
  $('.meta-topic .topics').hideOtherLinks();
  equal($('.meta-topic .topics a:visible').length, 2);
});

test("should open on click", function() {
  $('.meta-topic .topics').hideOtherLinks();
  $('.meta-topic .show-other-content').click();
  equal($('.meta-topic .topics a:visible').length, 3);
  equal($('.meta-topic .topics a:visible:eq(0)').text(), 'Topic A');
  equal($('.meta-topic .topics a:visible:eq(1)').text(), 'Topic B');
  equal($('.meta-topic .topics a:visible:eq(2)').text(), 'Topic C');
});

test("removes open link on click", function() {
  $('.meta-topic .topics').hideOtherLinks();
  $('.meta-topic .show-other-content').click();
  equal($('.meta-topic .topics .show-other-content').length, 0);
});

test("should preserve first link", function() {
  $('.meta-topic .topics').hideOtherLinks();
  equal($('.meta-topic .topics a:visible:first').text(), 'Topic A');
  notEqual($('.meta-topic .topics a:visible:eq(1)').text(), 'Topic B');
  equal($('.meta-topic .topics a:visible:eq(1)').text(), '+ others');
});
