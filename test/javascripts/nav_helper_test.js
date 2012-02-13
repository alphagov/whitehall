module("Navigation Helper", {
  setup: function() {
    this.container = $('<nav class="global_nav"></nav>');

    for (var i=0; i <= 6; i++) {
      this.container.append($('<a href="#" class="nav_link">Nav ' + i + '</a>'));
    };

    $('#qunit-fixture').append(this.container);

    // $("#qunit-fixture").css({
    //   position: 'relative',
    //   top: 'auto',
    //   left: 'auto'
    // });

    $("#qunit-fixture").width('320px');
  }
});

test("should add section navigation element", function() {
  $('.global_nav').navHelper();
  equal(1, $('nav.global_nav a.section_toggle').length);
});

test("should hide all other navigation elements upon start", function () {
  $('.global_nav').navHelper({ breakpointSelector: "#qunit-fixture" });
  ok($('nav.global_nav a.nav_link').is(':hidden'));
});

test("clicking on the section link should toggle the rest of the navigation elements", function () {
  $('.global_nav').navHelper({ breakpointSelector: "#qunit-fixture" });
  ok($('nav.global_nav a.nav_link').is(':hidden'));
  $('nav.global_nav a.section_toggle').click();
  ok($('nav.global_nav a.nav_link').is(':visible'));
  $('nav.global_nav a.section_toggle').click();
  ok($('nav.global_nav a.nav_link').is(':hidden'));
});

test("if enclosing width is greater than breakpoint it should not initialise", function () {
  $("#qunit-fixture").width('1024px');
  $('.global_nav').navHelper({ breakpointSelector: "#qunit-fixture" });
  ok($('nav.global_nav a.nav_link').is(':visible'));
  ok($('nav.global_nav a.section_toggle').is(':hidden'));
});

test("should take label for the collapsed navigation", function () {
  $('.global_nav').navHelper({ breakpointSelector: "#qunit-fixture", collapsedLabel: 'Some Label' });
  equals('Some Label', $('nav.global_nav a.section_toggle').text());
});
