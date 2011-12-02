module("Adding a toggle link to an element", {
  setup: function() {
    container = $('<section id="container"></section>');
    var heading = $('<h1>Content heading</h1>');
    content = $('<div class="content">my content</div>');
    container.append(heading);
    container.append(content);
    $('#qunit-fixture').append(container);
    container.addToggleLink(".content");
  }
});

test("should hide the content", function() {
  ok(!$(content).is(":visible"));
});

test("should add a 'show' link within the heading of the container", function() {
  var toggleLink = $('h1 a.toggle', container);
  equal("show", $(toggleLink).text());
  ok($(toggleLink).is(":visible"));
});

test("should show the content when the link is clicked", function() {
  var toggleLink = $('h1 a.toggle', container);
  toggleLink.click();
  ok($(content).is(":visible"));
});

test("should change the link text when the link is clicked", function() {
  var toggleLink = $('h1 a.toggle', container);
  toggleLink.click();
  equal("hide", $(toggleLink).text());
});

test("should hide the content when the link is clicked twice", function() {
  var toggleLink = $('h1 a.toggle', container);
  toggleLink.click();
  toggleLink.click();
  ok(!$(content).is(":visible"));
});