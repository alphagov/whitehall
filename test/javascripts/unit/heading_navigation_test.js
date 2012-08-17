module("Heading navigation", {
  setup: function() {
    this.container = $(
      '<section class="contents">' +
        '<h2 id="part-1">Part 1</h2><p>The contents of the first part</p><p>More first part contents</p>' +
        '<h2 id="part-2">Part 2</h2><p>The contents of the second part</p><h3 id="part-2-1">Second part heading</h3><p>More second part contents</p>' +
        '<h2 id="part-3">Part 3</h2><p>The contents of the third part</p><h3 id="part-3-1">Third part heading</h3><p>More third part contents</p><h3 id="part-3-2">Another third part heading</h3><p>Yet more part 3 contents</p>' +
      '</section>')
    $('#qunit-fixture').append(this.container);
  }
});

function buildAndAppendNav(container, heading) {
  var list = $(container).navigationList(heading);
  var div = $('<div></div>');
  div.addClass("navlist");
  div.append(list);
  $('#qunit-fixture').append(div);
}

test("builds a list of links to the ID of each heading", function() {
  buildAndAppendNav(".contents", "h2");
  var links = $(".navlist a").map(function(i, a) { return $(a).attr("href") } );
  // deepEqual(links, ["#part-1", "#part-2", "#part-3"], "WTF WHY DOES THIS NOT WORK");
  equal(links[0], "#part-1");
  equal(links[1], "#part-2");
  equal(links[2], "#part-3");
})

test("uses the heading text as the link text", function() {
  buildAndAppendNav(".contents", "h2");
  var links = $(".navlist a").map(function(i, a) { return $(a).text(); } );
  // deepEqual(links, ["Part 1", "Part 2", "Part 3"], "WTF WHY DOES THIS NOT WORK");
  equal(links[0], "Part 1");
  equal(links[1], "Part 2");
  equal(links[2], "Part 3");
})

test("applies a given class to the generated list", function() {
  var list = $(".contents").navigationList("h2", "custom-list-class");
  ok($(list).hasClass("custom-list-class"));
})
