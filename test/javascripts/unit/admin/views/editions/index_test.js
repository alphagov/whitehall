module("adminEditionsIndex", {
  setup: function(){
    $('#qunit-fixture').append('\
      <form class="editions-filter js-editions-filter-form" action="/government/admin/editions" method="get">\
        <div id="title_filter" class="filter-grouping">\
          <label for="search_title">Title or slug</label>\
          <div class="btn-enter-wrapper">\
            <input type="search" value="hello world" placeholder="Search title" name="title" id="search_title">\
            <input type="submit" value="enter" name="commit" class="btn-enter js-btn-enter js-hidden">\
          </div>\
        </div>\
        <div id="state_filter" class="filter-grouping">\
          <label for="state">State</label>\
          <select name="state" id="state" class="chzn-select-no-search" style="display: none;">\
            <option selected="selected" value="active">All states</option>\
            <option value="draft">Draft</option>\
            <option value="published">Published</option>\
          </select>\
        </div>\
      </form>\
      \
      <div id="search_results"></div>\
    ');
  }
});

test("It gets using serialized form as data", function(){
  var subject = new GOVUK.AdminEditionsIndex({
    filter_form: $('#qunit-fixture .editions-filter'),
    search_results: $('#qunit-fixture #search_results')
  });
  var spy = this.stub(jQuery, 'ajax');

  subject.updateResults(true);

  ok(spy.calledOnce);
  ok(spy.getCall(0).args[0].url == '/government/admin/editions');
  ok(spy.getCall(0).args[0].method == 'get');
  ok(spy.getCall(0).args[0].data == 'title=hello+world&state=active');
});

test("It renders response to #search_results", function() {
  var subject = new GOVUK.AdminEditionsIndex({
    filter_form: $('#qunit-fixture .editions-filter'),
    search_results: $('#qunit-fixture #search_results')
  });
  var spy = this.stub(jQuery, 'ajax');

  subject.updateResults(true);

  spy.getCall(0).args[0].success('<div id="exactly_what_you_wanted"></div>');
  ok($('#qunit-fixture #search_results').find('#exactly_what_you_wanted').length > 0);
});

test("It gets results when a form select changes", function(){
  var spy = this.stub(GOVUK.AdminEditionsIndex.prototype, 'updateResultsWithNoRepeatProtection');
  var subject = new GOVUK.AdminEditionsIndex({
    filter_form: $('#qunit-fixture .editions-filter'),
    search_results: $('#qunit-fixture #search_results')
  });

  $('#qunit-fixture #state').change();

  ok(spy.calledOnce);
});

test("It shows an enter button when a text input is changed, and then updates results when that's clicked", function() {
  var spy = this.stub(GOVUK.AdminEditionsIndex.prototype, 'updateResultsWithNoRepeatProtection');
  var subject = new GOVUK.AdminEditionsIndex({
    filter_form: $('#qunit-fixture .editions-filter'),
    search_results: $('#qunit-fixture #search_results')
  });

  //CSS would hide the button.
  $('.btn-enter').hide();

  $('#search_title').change();
  ok($('.btn-enter').css('display') != 'none');
  $('.btn-enter').click();
  ok($('.btn-enter').css('display') == 'none');
  ok(spy.calledOnce);
});

