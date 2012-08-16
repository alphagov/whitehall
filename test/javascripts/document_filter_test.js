module("Document filter", {
  setup: function() {
    this.originalHistoryEnabled = History.enabled;
    this.originalHistoryPushState = History.pushState;
    History.pushState = function(state,title,url){
      return true;
    };
    
    this.filterForm = $('<form id="document-filter" action="/foo/bar"><input type="submit" /></form>');
    $('#qunit-fixture').append(this.filterForm);

    this.filterResults = $('<div class="filter-results" />');
    $('#qunit-fixture').append(this.filterResults);
  },
  tearDown: function() {
    History.enabled = this.originalHistoryEnabled;
    History.pushState = this.originalHistoryPushState;
  }
});

test("should make an ajax request on form submission to obtain filtered results", function() {
  this.filterForm.enableDocumentFilter();

  var ajax = this.spy(jQuery, "ajax");
  var server = this.sandbox.useFakeServer();

  this.filterForm.submit();
  server.respond();

  sinon.assert.calledOnce(ajax);
})

test("should send ajax request using url in form action", function() {
  this.filterForm.enableDocumentFilter();

  var ajax = this.spy(jQuery, "ajax");
  var server = this.sandbox.useFakeServer();

  $(this.filterForm).attr("action", "/specialist")

  this.filterForm.submit();
  server.respond();

  var url = jQuery.ajax.getCall(0).args[0];
  equals(url, "/specialist");
})

test("should send filter form parameters in ajax request", function() {
  this.filterForm.enableDocumentFilter();

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
  this.filterForm.enableDocumentFilter();

  var ajax = this.spy(jQuery, "ajax");
  var server = this.sandbox.useFakeServer();
  server.respondWith('{ "results": [ { "id": 1, "type": "document-type", "title": "document-title", "url": "/document-path", "organisations": "organisation-name-1, organisation-name-2", "topics": "topic-name-1, topic-name-2" } ] }')

  this.filterForm.submit();
  server.respond();

  equals($(this.filterResults).find("table tbody tr").length, 1)
})

test("should update browser location on successful ajax response", function() {
  this.filterForm.enableDocumentFilter();

  var historyPushState = this.spy(History, "pushState");
  var ajax = this.spy(jQuery, "ajax");
  var server = this.sandbox.useFakeServer();
  server.respondWith('{ "results": [ { "id": 1, "type": "document-type", "title": "document-title", "url": "/document-path", "organisations": "organisation-name-1, organisation-name-2", "topics": "topic-name-1, topic-name-2" } ] }')

  $(this.filterForm).attr("action", "/specialist")
  $(this.filterForm).append($('<select name="foo"><option value="bar" /></select>'))

  this.filterForm.submit();
  server.respond();

  var data = historyPushState.getCall(0).args[0];
  equals(data, null, "No need to store any data in history");

  var title = historyPushState.getCall(0).args[1];
  equals(title, null, "Setting this to null means title stays the same");

  var path = historyPushState.getCall(0).args[2];
  equals(path, "/specialist?foo=bar", "Bookmarkable URL path");
})

test("should not enable ajax filtering if browser does not support HTML5 History API", function() {
  History.enabled = false;

  this.filterForm.enableDocumentFilter();

  var ajax = this.spy(jQuery, "ajax");
  var server = this.sandbox.useFakeServer();
  
  this.filterForm.attr('action', 'javascript:return false;');
  this.filterForm.submit();
  server.respond();
  
  sinon.assert.callCount(ajax, 0);
})

