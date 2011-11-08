module("Sorting options", {
  setup: function() {
    this.container = $('<fieldset></fieldset>');
    var labelOne = $('<label for="element_one">one</label>');
    var labelTwo = $('<label for="element_two">two</label>');
    this.container.append(labelOne);
    this.container.append(labelTwo);
    $('#qunit-fixture').append(this.container);
  }
});

test("should build a list from the contents of the labels", function() {
  this.container.enableSortable();
  var list = this.container.siblings("ul")
  equals("onetwo", list.text()); // I would compare arrays, but Javascript can't do that easily. GAH.
})

test("should hide the input fields", function() {
  this.container.enableSortable();
  ok(!this.container.children("input").is(":visible"));
})