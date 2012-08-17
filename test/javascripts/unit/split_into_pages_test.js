module("Split into pages", {
  setup: function() {
    this.container1 = $(
      '<section class="contents-to-be-paged">' +
        '<h2>Page 1</h2><p>The contents of the first page</p><p>More first page contents</p>' +
        '<h2>Page 2</h2><p>The contents of the second page</p><h3>Second page heading</h3><p>More second page contents</p>' +
        '<h2>Page 3</h2><p>The contents of the third page</p><h3>Third page heading</h3><p>More third page contents</p><h3>Another third page heading</h3><p>Yet more page 3 contents</p>' +
      '</section>');
    $('#qunit-fixture').append(this.container1);
  }
});

test("should split contents of container into pages using specified delimiter element", function() {
  $(".contents-to-be-paged").splitIntoPages("h2");
  equal($(".contents-to-be-paged .page").length, 3);
})

test("should include all contents from each page in the new page elements", function() {
  $(".contents-to-be-paged").splitIntoPages("h2");
  equal($(".contents-to-be-paged .page:nth-child(1) h2").text(), "Page 1");
  equal($(".contents-to-be-paged .page:nth-child(1) p").length, 2);
  equal($(".contents-to-be-paged .page:nth-child(2) p").length, 2);
  equal($(".contents-to-be-paged .page:nth-child(3) p").length, 3);
})

test("should include any subheadings within the page", function() {
  $(".contents-to-be-paged").splitIntoPages("h2");
  equal($(".contents-to-be-paged .page:nth-child(2) h3").length, 1);
  equal($(".contents-to-be-paged .page:nth-child(3) h3").length, 2);
})

test("should include in the first page any content before the first delimiter element", function() {
  $('#qunit-fixture').html('<section class="contents-to-be-paged">' +
    '<p class="preamble">Preamble content to be included in the first page</p>' +
    '<h2>Page 1</h2><p>The contents of the first page</p><p>More first page contents</p>' +
    '<h2>Page 2</h2><p>The contents of the second page</p><h3>Second page heading</h3><p>More second page contents</p>' +
  '</section>');

  $(".contents-to-be-paged").splitIntoPages("h2");
  equal($(".contents-to-be-paged .page:first-child .preamble").length, 1);
})
