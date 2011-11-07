module("Mark element identified by URL anchor as linked", {
  setup: function() {
    var container = $('<ul id="element_container"></ul>');
    var elementOne = $('<li id="element_1"></li>');
    var elementTwo = $('<li id="element_2"></li>');
    container.append(elementOne);
    container.append(elementTwo);
    $('#qunit-fixture').append(container);
  },
  teardown: function() {
    window.location.hash = undefined;
  }
});

test("should add 'linked' class to element identified by URL anchor", function() {
  window.location.hash = "element_2";
  $("#element_container").markLinkedAnchor();
  ok($("#element_2").hasClass("linked"));
})

test("should not add 'linked' class to element not identified by URL anchor", function() {
  window.location.hash = "element_2";
  $("#element_container").markLinkedAnchor();
  ok(!$("#element_1").hasClass("linked"));
})

test("should not add 'linked' class to any fact check response when no URL anchor is specified", function() {
  window.location.hash = undefined;
  $("#element_container").markLinkedAnchor();
  equal($("#element_container .linked").length, 0);
})

test("should not add 'linked' class to any element when empty URL anchor is specified", function() {
  window.location.hash = "";
  $("#element_container").markLinkedAnchor();
  equal($("#element_container .linked").length, 0);
})

test("should not add 'linked' class to any element when no element is identified by anchor", function() {
  window.location.hash = "non_existent_element";
  $("#element_container").markLinkedAnchor();
  equal($("#element_container .linked").length, 0);
})
