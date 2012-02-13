module("Navigation Helper", {
  setup: function() {
    this.container = $('<div class="wrapper"><nav class="global_nav"></nav></div>');

    for (var i=0; i <= 6; i++) {
      this.container.find('nav').append($('<a href="#" id="nav_'+i+'">Nav ' + i + '</a>'));
    };

    $('#qunit-fixture').append(this.container);

    // $("#qunit-fixture").css({
    //   position: 'relative',
    //   top: 'auto',
    //   left: 'auto',
    //   background: 'red'
    // });

    $("#qunit-fixture .wrapper").width('320px');

    sinon.config.useFakeTimers = false;
  }
});

function initNavHelper(options) {

  var settings = $.extend({
    sectionToggleClass : 'section_toggle',
    breakpointSelector : '#qunit-fixture .wrapper',
    breakpoints: [
      { width: 320, label: 'All sections', exclude: '' },
      { width: 768, label: 'More sections', exclude: '#nav_2, #nav_3' }
    ]
  }, options);

  $('.global_nav').navHelper(settings);
}

test("should add section navigation element", function() {
  initNavHelper();
  equal(1, $('nav.global_nav a.section_toggle').length);
});

test("should hide all other navigation elements if below breakpoint upon start", function () {
  initNavHelper();
  ok($('nav.global_nav a.nav_link').is(':hidden'));
});

test("clicking on the section link should toggle the rest of the navigation elements", function () {
  initNavHelper();
  ok($('nav.global_nav a.nav_link').is(':hidden'));
  $('nav.global_nav a.section_toggle').click();
  ok($('nav.global_nav a.nav_link').is(':visible'));
  $('nav.global_nav a.section_toggle').click();
  ok($('nav.global_nav a.nav_link').is(':hidden'));
});

test("if enclosing width is greater than largest breakpoint it should not initialise", function () {
  $("#qunit-fixture .wrapper").width('800px');
  initNavHelper();
  ok($('nav.global_nav a.nav_link').is(':visible'));
  ok($('nav.global_nav a.section_toggle').is(':hidden'));
});

test("should display corrent items and sections label at largest breakpoint", function () {
  $("#qunit-fixture .wrapper").width('768px');
  initNavHelper();
  $('nav.global_nav a.nav_link').not('#nav_2, #nav_3').each(function () {
    ok($(this).is(':hidden'));
  });
  ok($('nav.global_nav #nav_2').is(':visible'));
  ok($('nav.global_nav #nav_3').is(':visible'));

  ok($('nav.global_nav a.section_toggle').is(':visible'));
  equal($('nav.global_nav a.section_toggle').text(), 'More sections');
});

test("should display corrent items and sections label at smallest breakpoint", function () {
  $("#qunit-fixture .wrapper").width('320px');
  initNavHelper();
  ok($('nav.global_nav a.nav_link').is(':hidden'));
  $('nav.global_nav a.nav_link').not('#nav_1').each(function () {
    ok($(this).is(':hidden'));
  });
  ok($('nav.global_nav a.section_toggle').is(':visible'));
  equal($('nav.global_nav a.section_toggle').text(), 'All sections');
});

test("should display corrent items upon resize", function () {
  stop();

  $("#qunit-fixture .wrapper").width('800px');
  initNavHelper();
  ok($('nav.global_nav a.section_toggle').is(':hidden'), 'Section toggle should be hidden');

  setTimeout(function () {
    $("#qunit-fixture .wrapper").width('768px');
    $("#qunit-fixture .wrapper").trigger('resize');

    ok($('nav.global_nav a.nav_link').is(':hidden'));
    ok($('nav.global_nav a.section_toggle').is(':visible'));
    equal($('nav.global_nav a.section_toggle').text(), 'More sections');

    setTimeout(function () {
      $("#qunit-fixture .wrapper").width('320px');
      $("#qunit-fixture .wrapper").trigger('resize');

      ok($('nav.global_nav a.nav_link').is(':hidden'));
      ok($('nav.global_nav a.section_toggle').is(':visible'));
      equal($('nav.global_nav a.section_toggle').text(), 'All sections');

      start();
    }, 500);
  }, 500);
});

test("should take selector of anchor tags which shouldn't be hidden when collapsed", function () {
  $("#qunit-fixture .wrapper").width('320px');
  $('.global_nav').append($('<a href="#" class="home">Home</a>'));
  initNavHelper({ breakpoints: [{ width: 320, label: 'All sections', exclude: '.home' }] });
  ok($('nav.global_nav a.nav_link').is(':hidden'));
  ok($('nav.global_nav a.home').is(':visible'));
});

test("should append section toggle link to the navigation block", function () {
  initNavHelper();
  equal($('nav.global_nav a:last')[0], $('nav.global_nav a.section_toggle')[0]);
});

test("should re-show items in the 'exclude' list if they have had been hidden at other screen sizes", function () {
  $("#qunit-fixture .wrapper").width('320px');
  initNavHelper();
  ok($('nav.global_nav #nav_2').is(':hidden'));
  ok($('nav.global_nav #nav_3').is(':hidden'));

  $("#qunit-fixture .wrapper").width('768px');
  $("#qunit-fixture .wrapper").trigger('resize');
  ok($('nav.global_nav #nav_2').is(':visible'));
  ok($('nav.global_nav #nav_3').is(':visible'));
});
