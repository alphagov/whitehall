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
  this.stub(jQuery, "ajax");

  new GOVUK.RemoteSearchFilter({search_url: "http://www.example.com/search"}).updateResults();

  ok(jQuery.ajax.calledOnce);
  equal(jQuery.ajax.args[0][0].url, "http://www.example.com/search");
  equal(jQuery.ajax.args[0][0].type, "get");
});

test("updateResults should pass serialized form data", function() {
  this.stub(jQuery, "ajax", mockAjax("<p>Success!</p>"));

  var filter = new GOVUK.RemoteSearchFilter({form_element: 'form.filter-form'});

  $("input[name='a_text_field']").val('text_value');
  $("input[name='a_select_field[]']").val('option_2');

  filter.updateResults();

  equal(jQuery.ajax.args[0][0].data, "a_text_field=text_value&a_select_field%5B%5D=option_1")
});

test("updateResults should render response to the given results element", function() {
  this.stub(jQuery, "ajax", mockAjax("<p>Success!</p>"));

  new GOVUK.RemoteSearchFilter({results_element: ".results"}).updateResults();

  equal($('.results').text(), "Success!");
});

test("updateResults displays a loading message when waiting for a response", function() {
  stop();
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
