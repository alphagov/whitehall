module("remote-search-filter: ", {
  setup: function() {
    $('#qunit-fixture').append(
      '<form class="filter-form">' +
        '<fieldset>' +
          '<input type="text" name="a_text_field" />' +
          '<select name="a_select_field[]">' +
            '<option value="option_1">Option 1</option>' +
            '<option value="option_2">Option 2</option>' +
          '</select>' +
          '<input type="submit"/>' +
        '</fieldset>' +
      '</form>' +
      '<div class="results">' +
        '<div class="loading-message-holder"></div>' +
      '</div>'
    );
  }
});

function mockAjax(responseData) {
  return function(params) {
    params.success(responseData, "success", {});
  }
}

function mockAjaxWithDelayedResponse(responseData, responseDelay) {
  return function(params) {
    setTimeout(function() {
      params.success(responseData, "success", {});
    }, responseDelay);
  }
}

test("updateResults should get results from the given url", function() {
  this.stub(window.history, 'pushState');
  this.stub(window.history, 'replaceState');
  this.stub(jQuery, "ajax");

  new GOVUK.RemoteSearchFilter({search_url: "http://www.example.com/search"}).updateResults();

  ok(jQuery.ajax.calledOnce);
  equal(jQuery.ajax.args[0][0].url, "http://www.example.com/search");
  equal(jQuery.ajax.args[0][0].type, "get");
});

test("updateResults should pass form data, adding in an xhr=true field", function() {
  // xhr=true is required to prevent the browser getting confused between cached XHR and non-XHR requests.

  this.stub(window.history, 'pushState');
  this.stub(window.history, 'replaceState');
  this.stub(jQuery, "ajax", mockAjax("<p>Success!</p>"));

  var filter = new GOVUK.RemoteSearchFilter({form_element: 'form.filter-form'});

  $("input[name='a_text_field']").val('text_value');
  $("select[name='a_select_field[]']").val('option_2');

  filter.updateResults();

  deepEqual(jQuery.ajax.args[0][0].data, [
    {
      "name": "a_text_field",
      "value": "text_value"
    },
    {
      "name": "a_select_field[]",
      "value": "option_2"
    },
    {
      "name": "xhr",
      "value": "true"
    }
  ]);
});

test("getFilterParams ignores blank fields", function() {
  var filter = new GOVUK.RemoteSearchFilter({form_element: 'form.filter-form'});

  $("input[name='a_text_field']").val('');
  $("select[name='a_select_field[]']").val('option_2');

  deepEqual(filter.getFilterParams(), [
    {name: 'a_select_field[]', value: 'option_2'}
  ]);
});

test("updateResults should render response to the given results element", function() {
  this.stub(window.history, 'pushState');
  this.stub(window.history, 'replaceState');

  this.stub(jQuery, "ajax", mockAjax("<p>Success!</p>"));

  new GOVUK.RemoteSearchFilter({results_element: ".results"}).updateResults();

  equal($('.results').text(), "Success!");
});

test("updateResults displays a loading message when waiting for a response", function() {
  stop();
  this.stub(window.history, 'pushState');
  this.stub(window.history, 'replaceState');
  this.stub(jQuery, "ajax", mockAjaxWithDelayedResponse("<p>Success!</p>", 100));

  new GOVUK.RemoteSearchFilter({
    results_element: '.results',
    loading_message_holder: ".loading-message-holder",
    loading_message_text: "Loading results..."
  }).updateResults();

  equal("Loading results...", $('.loading-message-holder').text());

  setTimeout(function() {
    equal('', $('.loading-message-holder').text());
    start();
  }, 150);
});

test("the submit button should be hidden", function() {
  new GOVUK.RemoteSearchFilter({form_element: 'form.filter-form'});
  equal($('input[type=submit]').css('display'), 'none');
});

test("changing a select field should trigger an update immediatly", function() {
  var updateResultsStub = this.stub(GOVUK.RemoteSearchFilter.prototype, "updateResults");

  new GOVUK.RemoteSearchFilter({form_element: 'form.filter-form'});

  $('form select').val('option_2').change();
  ok(updateResultsStub.calledOnce);
});

test("changing a text field should trigger an update after a short delay, without making duplicate requests", function() {
  stop();
  var updateResultsStub = this.stub(GOVUK.RemoteSearchFilter.prototype, "updateResults");

  new GOVUK.RemoteSearchFilter({form_element: 'form.filter-form'});

  var $textField = $('form input[type=text]');
  $textField.val('foo').change();
  $textField.val('food').change();

  setTimeout(function() {
    equal(updateResultsStub.callCount, 1);
    start();
  }, 500);
});

test("individual changes are pushed to the browser history as a new object", function() {
  this.stub(jQuery, "ajax", mockAjax("<p>Success!</p>"));
  this.stub(window.history, 'pushState');
  this.stub(window.history, 'replaceState');

  new GOVUK.RemoteSearchFilter({search_url: "http://www.example.com/search", form_element: 'form.filter-form'})

  $("form select[name='a_select_field[]']").val('option_2').change();

  ok(window.history.pushState.calledOnce);
  deepEqual(window.history.pushState.args[0][0], [{name: 'a_select_field[]', value: 'option_2'}]); // State object
  deepEqual(window.history.pushState.args[0][1], null); // Window title
  deepEqual(window.history.pushState.args[0][2], "http://www.example.com/search?a_select_field%5B%5D=option_2"); // Address bar
});

test("multiple changes in quick succession replace the current history state instead of pushing a new one", function() {
  stop();
  this.stub(jQuery, "ajax", mockAjax("<p>Success!</p>"));
  this.stub(window.history, 'pushState');
  this.stub(window.history, 'replaceState');

  filter = new GOVUK.RemoteSearchFilter({search_url: "http://www.example.com/search", form_element: 'form.filter-form'})
  filter.HISTORY_REPLACE_NOT_PUSH_FOR = 100;

  $("form select[name='a_select_field[]']").val('option_2').change();
  $("form select[name='a_select_field[]']").val('option_1').change();

  equal(1, window.history.pushState.callCount);
  equal(1, window.history.replaceState.callCount);

  // Stubs don't survive in async tests - have to restore and then re-stub.
  window.history.pushState.restore();
  window.history.replaceState.restore();

  window.setTimeout($.proxy(function() {
    this.stub(window.history, 'pushState');
    this.stub(window.history, 'replaceState');
    this.stub(jQuery, "ajax", mockAjax("<p>Success!</p>"));

    $("form select[name='a_select_field[]']").val('option_2').change();

    equal(1, window.history.pushState.callCount);

    window.history.pushState.restore();
    window.history.replaceState.restore();
    jQuery.ajax.restore();
    start();
  }, this), 150);
});

test("the search results are reverted on history popstate", function() {
  var mockEvent = {
    state: [
      {name: 'a_text_field', value: 'some filter text'},
      {name: 'a_select_field[]', value: 'option_2'}
    ]
  };
  var getResultsFromRemoteStub = this.stub(GOVUK.RemoteSearchFilter.prototype, "getResultsFromRemote");
  var filter = new GOVUK.RemoteSearchFilter({search_url: "http://www.example.com/search", form_element: 'form.filter-form'});

  filter.onHistoryPopState(mockEvent);

  ok(getResultsFromRemoteStub.calledOnce);
  deepEqual(getResultsFromRemoteStub.args[0][0], mockEvent.state);

  equal($("input[name='a_text_field']").val(), "some filter text");
  equal($("select[name='a_select_field[]']").val(), "option_2");
});
