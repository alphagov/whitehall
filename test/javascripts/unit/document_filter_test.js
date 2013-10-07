module("Document filter", {
  setup: function() {
    this.originalHistoryEnabled = window.GOVUK.support.history;
    this.originalHistoryPushState = history.pushState;
    history.pushState = function(state,title,url){
      return true;
    };

    this.filterForm = $('<form id="document-filter" action="/foo/bar">' +
      '<input type="submit" />' +
      '<select id="departments" multiple="multiple">' +
      '<option value="all" selected="selected">All</option>' +
      '<option value="dept1">Dept1</option>' +
      '<option value="dept2">Dept2</option>' +
      '</select>' +
      '<input type="radio" id="direction_before">' +
      '<input type="radio" id="direction_after" value="after" checked="checked"> ' +
      '<input type="text" id="keywords" value=""> ' +
      '</form>');
    $('#qunit-fixture').append(this.filterForm);

    this.filterResults = $('<div class="js-filter-results" />');
    $('#qunit-fixture').append(this.filterResults);

    this.feedLinks = $('<div class="feeds"><a class="feed">feed</a> <a class="govdelivery">email</a></div>');
    $('#qunit-fixture').append(this.feedLinks);

    this.resultsCount = $('<div class="filter-results-summary"><h3 class="selections"></h3></div>');
    $('#qunit-fixture').append(this.resultsCount);

    this.selections = this.resultsCount.find('.selections');

    this.ajaxData = {
      "next_page?": true,
      "next_page": 2,
      "next_page_url": '/next-page-url',

      "prev_page_url": '/prev-page-url',
      "more_pages?": true,
      "total_pages": 5,

      "atom_feed_url": '/atom-feed',
      "email_signup_url": '/email-signups',
      "results_any?": true,
      "results": [
        {
          "id": 1,
          "type": "document-type",
          "title": "document-title",
          "url": "/document-path",
          "organisations": "organisation-name-1, organisation-name-2",
          "topics": "topic-name-1, topic-name-2",
          "field_of_operation": "place-of-war"
        },
        {
          "id": 2,
          "type": "document-type-2",
          "title": "document-title-2",
          "url": "/document-path-2",
          "organisations": "organisation-name-2, organisation-name-3",
          "publication_series": "series-1"
        }
      ]
    };
  },
  tearDown: function() {
    window.GOVUK.support.history = this.originalHistoryEnabled;
    history.pushState = this.originalHistoryPushState;
  }
});

test("should render mustache template from ajax data", function() {
  var stub = sinon.stub($.fn, "mustache");
  stub.returns(true);

  GOVUK.documentFilter.renderTable(this.ajaxData);

  equal(stub.getCall(0).args[1], this.ajaxData);
  stub.restore();
});

test("should show message when ajax data is empty", function() {
  GOVUK.documentFilter.renderTable({ 'results_any?': false });

  equals(this.filterResults.find('js-document-list').length, 0);
  equals(this.filterResults.find('.no-results').length, 1);
});

test("should update the atom feed url", function() {
  equals(this.feedLinks.find('a[href="/atom-feed"]').length, 0);

  GOVUK.documentFilter.updateAtomFeed(this.ajaxData);

  equals(this.feedLinks.find('a[href="/atom-feed"]').length, 1);
});

test("should update the email signup url", function() {
  equals(this.feedLinks.find('a[href="/email-signups"]').length, 0);

  GOVUK.documentFilter.updateEmailSignup(this.ajaxData);

  equals(this.feedLinks.find('a[href="/email-signups"]').length, 1);
});

test("should make an ajax request on form submission to obtain filtered results", function() {
  this.filterForm.enableDocumentFilter();

  var ajax = this.spy(jQuery, "ajax");
  var server = this.sandbox.useFakeServer();

  this.filterForm.submit();
  server.respond();

  sinon.assert.calledOnce(ajax);
});

test("should send ajax request using json form of url in form action", function() {
  this.filterForm.enableDocumentFilter();

  var ajax = this.spy(jQuery, "ajax");
  var server = this.sandbox.useFakeServer();

  $(this.filterForm).attr("action", "/specialist");

  this.filterForm.submit();
  server.respond();

  var url = jQuery.ajax.getCall(0).args[0];
  equals(url, "/specialist.json");
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

test("should render results based on successful ajax response", function() {
  this.filterForm.enableDocumentFilter();

  var server = this.sandbox.useFakeServer();
  server.respondWith(JSON.stringify(this.ajaxData));

  this.filterForm.submit();
  server.respond();

  equals(this.filterResults.find(".document-row").length, 2);
  equals(this.filterResults.find(".document-row .document-series").text(), 'series-1');
  equals(this.filterResults.find(".document-row .topics").text(), 'topic-name-1, topic-name-2');
  equals(this.filterResults.find(".document-row .field-of-operation").text(), 'place-of-war');
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

test("should apply hide class to feed on ajax call", function() {
  var removeClass = this.spy(GOVUK.documentFilter, 'updateFeeds');
  this.filterForm.enableDocumentFilter();

  var server = this.sandbox.useFakeServer();
  server.respondWith(JSON.stringify(this.ajaxData));

  this.filterForm.submit();
  ok(this.feedLinks.is('.js-hidden'));
  server.respond();
  ok(! this.feedLinks.is('.js-hidden'));
});

test("currentPageState should include the current results", function() {
  this.filterForm.enableDocumentFilter();
  var resultsContent = '<p>Test content</p>';
  this.filterResults.html(resultsContent);
  equals(GOVUK.documentFilter.currentPageState().html, resultsContent);
});

test("currentPageState should include the state of any select boxes", function() {
  this.filterForm.enableDocumentFilter();
  deepEqual(GOVUK.documentFilter.currentPageState().selected, [{id: "departments", value: ["all"], title: ["All"]}]);
});

test("currentPageState should include the state of any radio buttons", function() {
  this.filterForm.enableDocumentFilter();
  deepEqual(GOVUK.documentFilter.currentPageState().checked, [{ id: "direction_after", value: 'after' }]);
});

test("currentPageState should include the state of any text inputs", function() {
  this.filterForm.enableDocumentFilter();
  var searchText = "my example search";
  this.filterForm.find('#keywords').val(searchText)
  deepEqual(GOVUK.documentFilter.currentPageState().text, [{id: "keywords", value: searchText}]);
});

test("onPopState should restore the state as specified in the event", function() {
  this.filterForm.enableDocumentFilter();
  var event = {
    state: {
      html: "<p>Old content</p>",
      selected: [{id: "departments", value: ["dept1"]}],
      text: [{id: "keywords", value: ["some search"]}],
      checked: ["direction_before"]
    }
  };
  GOVUK.documentFilter.onPopState(event);
  equals(this.filterResults.html(), event.state.html, 'filter results updated to previous value');
  deepEqual(this.filterForm.find('#departments').val(), ["dept1"], 'old department selected');
  equals(this.filterForm.find('#keywords').val(), "some search", 'filter results updated to previous value');
  ok(this.filterForm.find('#direction_before:checked'), "date 'before' radio checked");
});

test("should record initial page state in browser history", function() {
  var oldPageState = window.GOVUK.documentFilter.currentPageState;
  window.GOVUK.documentFilter.currentPageState = function() { return "INITIALSTATE"; }

  var historyReplaceState = this.spy(history, "replaceState");
  this.filterForm.enableDocumentFilter();

  var data = historyReplaceState.getCall(0).args[0];
  equals(data, "INITIALSTATE", "Initial state is stored in history data");

  window.GOVUK.documentFilter.currentPageState = oldPageState;
});

test("should update browser location on successful ajax response", function() {
  this.filterForm.enableDocumentFilter();

  var oldPageState = window.GOVUK.documentFilter.currentPageState;
  window.GOVUK.documentFilter.currentPageState = function() { return "CURRENTSTATE"; }

  var historyPushState = this.spy(history, "pushState");
  var server = this.sandbox.useFakeServer();
  server.respondWith(JSON.stringify(this.ajaxData));

  $(this.filterForm).attr("action", "/specialist");
  $(this.filterForm).append($('<select name="foo"><option value="bar" /></select>'));

  this.filterForm.submit();
  server.respond();

  var data = historyPushState.getCall(0).args[0];
  equals(data, "CURRENTSTATE", "Current state is stored in history data");

  var title = historyPushState.getCall(0).args[1];
  equals(title, null, "Setting this to null means title stays the same");

  var path = historyPushState.getCall(0).args[2];
  equals(path, "/specialist?foo=bar", "Bookmarkable URL path");

  window.GOVUK.documentFilter.currentPageState = oldPageState;
});

test("should store new table html on successful ajax response", function() {
  this.filterForm.enableDocumentFilter();

  var historyPushState = this.spy(history, "pushState");
  var server = this.sandbox.useFakeServer();
  server.respondWith(JSON.stringify(this.ajaxData));

  this.filterForm.submit();
  server.respond();

  var data = historyPushState.getCall(0).args[0];
  ok(!!data.html.match('document-title'), "Current state is stored in history data");
});

test("should not enable ajax filtering if browser does not support HTML5 History API", function() {
  var oldHistory = window.GOVUK.support.history;
  window.GOVUK.support.history = function() {return false;}

  this.filterForm.enableDocumentFilter();

  var ajax = this.spy(jQuery, "ajax");
  var server = this.sandbox.useFakeServer();

  this.filterForm.attr('action', 'javascript:void(0)');
  this.filterForm.submit();
  server.respond();

  sinon.assert.callCount(ajax, 0);
  window.GOVUK.support.history = oldHistory;
});

test("should create live count value", function(){
  window.GOVUK.documentFilter.$form = this.filterForm;

  var data = { total_count: 1337 };

  window.GOVUK.documentFilter.liveResultSummary(data);
  ok(this.resultsCount.text().indexOf('1337 results') > -1, 'should display 1337 results');
});

test("should update selections to match filters", function(){
  window.GOVUK.documentFilter.$form = this.filterForm;

  var data = { total_count: 1337 },
      formStatus = {
        selected: [
          {
            title: ['my-title'],
            id: 'topics',
            value: ['my-value']
          }
        ],
        text: [
          {
            title: ['form-date'],
            id: 'from_date',
            value: ['from-date']
          },
          {
            title: ['to-date'],
            id: 'to_date',
            value: ['to-date']
          }
        ]
      };

  var stub = sinon.stub(GOVUK.documentFilter, "currentPageState");
  stub.returns(formStatus);

  window.GOVUK.documentFilter.liveResultSummary(data, formStatus);

  ok(this.selections.find('.topics-selections strong').text().indexOf('my-title') > -1);
  equals(this.selections.find('.topics-selections strong a').attr('data-val'), 'my-value');
  equals(this.selections.text().match(/from from-date/).length, 1, 'not from my-date');
  equals(this.selections.text().match(/to to-date/).length, 1, 'not to my-date');
  stub.restore();
});

test("should request removal from document filters", function(){
  this.selections.append('<a href="#" data-field="topics" data-val="something">hello</a>');

  var stub = sinon.stub(GOVUK.documentFilter, "removeFilters");

  this.filterForm.enableDocumentFilter();

  this.selections.find('a').click();

  if(stub.getCall(0)){
    equal(stub.getCall(0).args[0], 'topics')
    equal(stub.getCall(0).args[1], 'something')
  } else {
    ok(stub.getCall(0), "stub not called");
  }
  stub.restore();
});

test("should remove selection from apropriate filter", function(){
  this.filterForm.find('option[value="dept1"]').attr('selected', 'selected');

  equal(this.filterForm.find('select option[value="dept1"]:selected').length, 1, 'selected to start');
  GOVUK.documentFilter.removeFilters('departments', 'dept1');
  equal(this.filterForm.find('select option[value="dept1"]:selected').length, 0, 'selection removed');
});

test("should select first item in filter if no item would be selected", function(){
  this.filterForm.find('option').removeAttr('selected');
  this.filterForm.find('option[value="dept1"]').attr('selected', 'selected');

  equal(this.filterForm.find('select option:selected').length, 1);
  GOVUK.documentFilter.removeFilters('departments', 'dept1');
  equal(this.filterForm.find('select option:first-child:selected').length, 1);
});
