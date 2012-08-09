module("Document filter", {
  setup: function() {
    this.filterForm = $('<form id="document-filter" action="/foo/bar"><input type="submit" /></form>');
    $('#qunit-fixture').append(this.filterForm);

    this.filterResults = $('<div class="filter-results" />');
    $('#qunit-fixture').append(this.filterResults);

    this.filterForm.enableDocumentFilter();
  }
});

test("should make an ajax request on form submission to obtain filtered results", function() {
  var ajax = this.spy(jQuery, "ajax");
  var server = this.sandbox.useFakeServer();

  this.filterForm.submit();
  server.respond();

  sinon.assert.calledOnce(ajax);
})

test("should send ajax request using url in form action", function() {
  var ajax = this.spy(jQuery, "ajax");
  var server = this.sandbox.useFakeServer();

  $(this.filterForm).attr("action", "/specialist")

  this.filterForm.submit();
  server.respond();

  var url = jQuery.ajax.getCall(0).args[0];
  equals(url, "/specialist");
})

test("should send filter form parameters in ajax request", function() {
  var ajax = this.spy(jQuery, "ajax");
  var server = this.sandbox.useFakeServer();

  $(this.filterForm).append($('<select name="foo"><option value="bar" /></select>'))

  this.filterForm.submit();
  server.respond();

  var settings = jQuery.ajax.getCall(0).args[1];
  equals(settings["data"][0]["name"], "foo");
  equals(settings["data"][0]["value"], "bar");
})

test("should generate table of results baed on successful ajax response", function() {
  var ajax = this.spy(jQuery, "ajax");
  var server = this.sandbox.useFakeServer();
  server.respondWith('{ "results": [ { "id": 1, "type": "document-type", "title": "document-title", "url": "/document-path", "organisations": "organisation-name-1, organisation-name-2", "topics": "topic-name-1, topic-name-2" } ] }')

  this.filterForm.submit();
  server.respond();

  equals($(this.filterResults).find("table tbody tr").length, 1)
})

