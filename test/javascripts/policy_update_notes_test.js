module("Policy update notes", {
  setup: function() {
    $('#qunit-fixture').append($('<span class="updated_at">updated 6 days ago</span>'));
    $('#qunit-fixture').append($('<div class="changes"></div>'));
    $.fx.off = true;
  }
});

function init_plugin(options) {
  var settings = $.extend({link: 'span.updated_at'}, options);
  $('.changes').policyUpdateNotes(settings);
}

test("Should be hidden on load", function () {
  init_plugin();
  ok($('.changes').is(':hidden'));
});

test("Should take a link selector and wrap a link around the selector", function () {
  init_plugin();
  equals($('a span.updated_at').length, 1);
});

test("Should not wrap link selector element if it is already an anchor", function () {
  $('#qunit-fixture').append($('<a class="an_anchor"></a>'));
  init_plugin({link: 'a.an_anchor'});
  equals($('a a.an_anchor').length, 0);
});

test("Should make the on click event of the selected link toggle the changes div", function () {
  init_plugin();
  ok($('.changes').is(':hidden'));
  $('span.updated_at').parent().click();
  ok($('.changes').is(':visible'));
  $('span.updated_at').parent().click();
  ok($('.changes').is(':hidden'));
});

test("Passing an anchor in the link selector should override on click event and toggle the changes div", function () {
  $('#qunit-fixture').append($('<a class="an_anchor"></a>'));
  init_plugin({link: 'a.an_anchor'});
  ok($('.changes').is(':hidden'));
  $('a.an_anchor').click();
  ok($('.changes').is(':visible'));
});

test("If policy change notes aren't present on the page then the link shouldn't be attached", function () {
  $('.element-that-wont-exist').policyUpdateNotes({link: 'span.updated_at'});
  equals($('a span.updated_at').length, 0);
});
