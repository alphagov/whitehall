// jQuery UI comes from the static application
$.fn.sortable = function() {}; // noop

module("Sorting options", {
  setup: function() {
    this.container = $('<fieldset></fieldset>');
    var thingOne = $('<div><label for="input_one">one <input name="input_one" type="text" /></label><label for="other_thing_one">other thing: <input name="other_thing_one" type="text" /></label></div>');
    var thingTwo = $('<div><label for="input_two">two <input name="input_two" type="text" /></label><label for="other_thing_two">other thing: <input name="other_thing_two" type="text" /></label></div>');
    this.container.append(thingOne);
    this.container.append(thingTwo);
    $('#qunit-fixture').append(this.container);
  }
});

test("should build a list from the contents of the labels", function() {
  this.container.enableSortable();
  var list = this.container.siblings("ul")
  equal("one other thing: two other thing: ", list.text()); // I would compare arrays, but Javascript can't do that easily. GAH.
})

test("should hide the input fields", function() {
  this.container.enableSortable();
  ok(!this.container.children("input").is(":visible"));
})