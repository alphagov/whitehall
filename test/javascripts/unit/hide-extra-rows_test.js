/*globals module, test, $, ok, equal */
/*jslint
 white: true,
 sloppy: true,
 vars: true,
 plusplus: true
*/
module("hide-extra-rows.js: Hide lines past the first", {
  setup: function(){
    var elementString = "<ul id='will-wrap' style='width: 400px;'>",
        i = 0;
    while (i < 10) {
      var styles = "float: left; width: 100px;";
      elementString += '<li id="item-' + i + '" style="' + styles + '">Text here</li>';
      i++;
    }
    elementString += '</ul>';

    this.$element = $(elementString);
    $('#qunit-fixture').append(this.$element);
  }
});

test("Should add elements past the first line into a js-hidden element", function() {
  var result = this.$element.hideExtraRows();
  equal($('.js-hidden', this.$element).children().length, 6);
});

test("Should move elements past the second line into a js-hidden element", function() {
  var result = this.$element.hideExtraRows({ rows: 2 });
  equal($('.js-hidden', this.$element).children().length, 2);
});

test("Should add a toggle button after the parent of the passed in elements", function() {
  var result = this.$element.hideExtraRows();
  equal(this.$element.siblings('.show-other-content').length, 1);
});

test("Clicking the show button should remove hidden classes", function() {
  var result = this.$element.hideExtraRows();
  $('.show-other-content').click();
  equal($('.js-hidden', this.$element).length, 0);
});

test("Should be able to wrap show button", function() {
  var result = this.$element.hideExtraRows({showWrapper: $('<div id="hide-stuff" />')});
  equal($('#hide-stuff > .show-other-content').length, 1);
});

test("Should be able to append hide button to parent", function() {
  var result = this.$element.hideExtraRows({showWrapper: $('<li />'), appendToParent: true});
  equal($('> li > .show-other-content', this.$element).length, 1);
});

test("Should clean up button after clicking", function() {
  var result = this.$element.hideExtraRows();
  $('.show-other-content').click();
  equal($('.show-other-content').length, 0);
});

test("Should clear up optional parent container after clicking", function() {
  var result = this.$element.hideExtraRows({showWrapper: $('<div id="hide-stuff" />')});
  $('.show-other-content').click();
    equal($('#hide-stuff').length, 0);
});
