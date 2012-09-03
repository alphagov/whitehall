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

    this.atomLink = $('<div class="subscribe"><a class="feed">feed</a></div>');
    $('#qunit-fixture').append(this.atomLink);

    this.ajaxData = {
      "next_page_url": '/next-page-url',
      "prev_page_url": '/prev-page-url',
      "next_page": 2,
      "total_pages": 5,
      "atom_feed_url": '/atom-feed',
      "results": [
        {
          "id": 1,
          "type": "document-type",
          "title": "document-title",
          "url": "/document-path",
          "organisations": "organisation-name-1, organisation-name-2",
          "topics": "topic-name-1, topic-name-2"
        },
        {
          "id": 2,
          "type": "document-type-2",
          "title": "document-title-2",
          "url": "/document-path-2",
          "organisations": "organisation-name-2, organisation-name-3",
          "topics": "topic-name-1, topic-name-2"
        }
      ]
    };
  },
  tearDown: function() {
    History.enabled = this.originalHistoryEnabled;
    History.pushState = this.originalHistoryPushState;
  }
});

test("should create pagination from ajax data", function() {
  var data = this.ajaxData;

  var $pagination = GOVUK.documentFilter.drawPagination(data);
  ok($pagination.find('a[href="/next-page-url"]').length > 0);
  equal($pagination.find('a[href="/next-page-url"] span').text(), '2 of 5');

  delete data.next_page_url;
  var $pagination = GOVUK.documentFilter.drawPagination(data);
  equals($pagination.find('a[href="/next-page-url"]').length, 0);

});

test("should identify important attributes", function(){
  var importantAttributes = ['id', 'title', 'url', 'type'],
      attr;

  for(attr in importantAttributes){
    ok(GOVUK.documentFilter.importantAttribute(attr));
  }
});

test("should create table rows from ajax data", function() {
  var $tbody = GOVUK.documentFilter.drawTableRows(this.ajaxData.results);

  equals($tbody.find('#document-type_1').length, 1, "document row exists");
  equals($tbody.find('a[href="/document-path"]').length, 1, "links to document");
  equals($tbody.find('td:contains("topic-name-1, topic-name-2")').length, 2, "topics are visible");

  equals($tbody.find('#document-type-2_2').length, 1, "document row exists");
  equals($tbody.find('a[href="/document-path-2"]').length, 1, "links to document");
  equals($tbody.find('td:contains("organisation-name-2, organisation-name-3")').length, 1, "organisations are visible");
});

test("should create table from ajax data", function() {
  GOVUK.documentFilter.drawTable(this.ajaxData);

  equals(this.filterResults.find('thead th:contains("Title")').length, 1);
  equals(this.filterResults.find('thead th:contains("Topic")').length, 1);
  equals(this.filterResults.find('thead th:contains("Organisation")').length, 1);

  equals(this.filterResults.find('tbody tr').length, 2);

  equals(this.filterResults.find('#show-more-documents').length, 1);
});

test("should show message when ajax data is empty", function() {
  GOVUK.documentFilter.drawTable({ results: [] });

  equals(this.filterResults.find('table').length, 0);
  equals(this.filterResults.find('.no-results').length, 1);
});

test("should update the atom feed url", function() {
  equals(this.atomLink.find('a[href="/atom-feed"]').length, 0);

  GOVUK.documentFilter.updateAtomFeed(this.ajaxData);

  equals(this.atomLink.find('a[href="/atom-feed"]').length, 1);
});

test("should visually hide the footer", function(){
  $('#qunit-fixture').append('<div id="footer"></div>');

  equals($('#footer.visuallyhidden').length, 0);
  GOVUK.documentFilter.hideFooter();
  equals($('#footer.visuallyhidden').length, 1);
});

test("should visually show the footer", function(){
  $('#qunit-fixture').append('<div id="footer"></div><div id="show-more-documents"><i class="next"><a>next</a></i></div>');

  GOVUK.documentFilter.hideFooter();
  equals($('#footer.visuallyhidden').length, 1);

  GOVUK.documentFilter.showFooter();
  equals($('#footer.visuallyhidden').length, 1);

  $('#show-more-documents').remove();
  GOVUK.documentFilter.showFooter();
  equals($('#footer.visuallyhidden').length, 0);
});

test("should make an ajax request on form submission to obtain filtered results", function() {
  this.filterForm.enableDocumentFilter();

  var ajax = this.spy(jQuery, "ajax");
  var server = this.sandbox.useFakeServer();

  this.filterForm.submit();
  server.respond();

  sinon.assert.calledOnce(ajax);
});

test("should make an ajax request to load more results inline", function() {
  this.filterForm.enableDocumentFilter();
  this.filterResults.append(GOVUK.documentFilter.drawPagination(this.ajaxData));

  var ajax = this.spy(jQuery, "ajax");
  var server = this.sandbox.useFakeServer();

  GOVUK.documentFilter.loadMoreInline();
  server.respond();

  sinon.assert.calledOnce(ajax);
});

test("should send ajax request using url in form action", function() {
  this.filterForm.enableDocumentFilter();

  var ajax = this.spy(jQuery, "ajax");
  var server = this.sandbox.useFakeServer();

  $(this.filterForm).attr("action", "/specialist");

  this.filterForm.submit();
  server.respond();

  var url = jQuery.ajax.getCall(0).args[0];
  equals(url, "/specialist");
});

test("should send filter form parameters in ajax request", function() {
  this.filterForm.enableDocumentFilter();

  var ajax = this.spy(jQuery, "ajax");
  var server = this.sandbox.useFakeServer();

  $(this.filterForm).append($('<select name="foo"><option value="bar" /></select>'));

  this.filterForm.submit();
  server.respond();

  var settings = jQuery.ajax.getCall(0).args[1];
  equals(settings["data"][0]["name"], "foo");
  equals(settings["data"][0]["value"], "bar");
});

test("should generate table of results baed on successful ajax response", function() {
  this.filterForm.enableDocumentFilter();

  var server = this.sandbox.useFakeServer();
  server.respondWith(JSON.stringify(this.ajaxData));

  this.filterForm.submit();
  server.respond();

  equals(this.filterResults.find("table tbody tr").length, 2);
});

test("should add extra results to table results", function() {
  this.filterForm.enableDocumentFilter();

  var server = this.sandbox.useFakeServer();
  server.respondWith(JSON.stringify(this.ajaxData));

  this.filterForm.submit();
  server.respond();

  equals(this.filterResults.find("table tbody tr").length, 2);

  GOVUK.documentFilter.loadMoreInline();
  server.respond();

  equals(this.filterResults.find("table tbody tr").length, 4);
});

test("should fire analytics on successful ajax response", function() {
  this.filterForm.enableDocumentFilter();
  window._gaq = [];

  var analytics = this.spy(_gaq, "push");
  var server = this.sandbox.useFakeServer();
  server.respondWith(JSON.stringify(this.ajaxData));

  this.filterForm.submit();
  server.respond();

  sinon.assert.callCount(analytics, 1);
});

test("should update browser location on successful ajax response", function() {
  this.filterForm.enableDocumentFilter();

  var historyPushState = this.spy(History, "pushState");
  var server = this.sandbox.useFakeServer();
  server.respondWith(JSON.stringify(this.ajaxData));

  $(this.filterForm).attr("action", "/specialist");
  $(this.filterForm).append($('<select name="foo"><option value="bar" /></select>'));

  this.filterForm.submit();
  server.respond();

  var data = historyPushState.getCall(0).args[0];
  equals(data, null, "No need to store any data in history");

  var title = historyPushState.getCall(0).args[1];
  equals(title, null, "Setting this to null means title stays the same");

  var path = historyPushState.getCall(0).args[2];
  equals(path, "/specialist?foo=bar", "Bookmarkable URL path");
});

test("should not enable ajax filtering if browser does not support HTML5 History API", function() {
  History.enabled = false;

  this.filterForm.enableDocumentFilter();

  var ajax = this.spy(jQuery, "ajax");
  var server = this.sandbox.useFakeServer();

  this.filterForm.attr('action', 'javascript:void(0)');
  this.filterForm.submit();
  server.respond();

  sinon.assert.callCount(ajax, 0);
});

