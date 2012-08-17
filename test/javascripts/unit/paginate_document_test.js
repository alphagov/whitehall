module("Paginating documents", {
  setup: function() {
    this.firstPageId = 'awesome-page';
    this.secondPageId = 'another-awesome-page';
    var navigation = $('<div class="contextual-info"><div id="document_sections"></div></div>');
    $('#document_sections', navigation).append('<a id="link-to-'+this.firstPageId+'" href="#'+this.firstPageId+'">Awesome page</a>');
    $('#document_sections', navigation).append('<a id="link-to-'+this.secondPageId+'" href="#'+this.secondPageId+'">Another awesome page</a>');
    var container = $('<div class="js-paginate-document document"><div class="govspeak"></div></div>');
    $('.govspeak', container).append('<h2 id="'+this.firstPageId+'">Awesome page</h2>');
    $('.govspeak', container).append('<h2 id="'+this.secondPageId+'">Another awesome page</h2>');
    $('#qunit-fixture').append(navigation);
    $('#qunit-fixture').append(container);

    GOVUK.paginateDocument()
  },

  teardown: function() {
    // Ensure we set the hash back to an empty string
    window.location.hash = '';
  }
});

asyncTest("should add the 'active' class to the first page in the navigation", function() {
  expect(2);

  // Simulate the user clicking the link to the first page
  var firstPageId = this.firstPageId;
  window.location.hash = firstPageId;

  // Give the hashchange callback enough time to be fired
  setTimeout(function() {
    var linkToFirstPage = $('#link-to-' + firstPageId);
    ok(linkToFirstPage.hasClass('active'), "The link to the first page should be active");
    equal($('a.active').length, 1, "Only one tab should be active");
    start();
  }, 500);
});

asyncTest("should add the 'active' class to the second page in the navigation", function() {
  expect(2);

  // Simulate the user clicking the link to the second page
  var secondPageId = this.secondPageId;
  window.location.hash = secondPageId;

  // Give the hashchange callback enough time to be fired
  setTimeout(function() {
    var linkToSecondPage = $('#link-to-' + secondPageId);
    ok(linkToSecondPage.hasClass('active'), "The link to the second page should be active");
    equal($('a.active').length, 1, "Only one tab should be active");
    start();
  }, 500);
});