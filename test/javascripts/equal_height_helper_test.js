module("Equal Height Helper", {
  setup: function() {
    this.container1 = $(
      '<section id="container1" class="container">' +
        '<article id="item_1"><h2>This is a large title which will wrap over a few lines</h2></article>' +
        '<article id="item_2"><h2>Small title</h2></article>' + 
        '<article id="item_3"><h2>Small title</h2></article>' +
      '</section>');
    this.container2 = $(
      '<section id="container2" class="container">' +
        '<article id="item_4"><h2>Small title</h2></article>' +
      '</section>');
    $('#qunit-fixture').append(this.container1);
    $('#qunit-fixture').append(this.container2);

    // $("#qunit-fixture").css({
    //   position: 'relative',
    //   top: 'auto',
    //   left: 'auto'
    // });
  }
});

test("should resize supplied elements to equal the element with the largest height", function() {
  // set the width of the container so the largest h2 will wrap
  $("#qunit-fixture").width('200px');

  notEqual(this.container1.find('#item_2 h2').css('min-height'), this.container1.find('#item_1 h2').css('height'), "#item_2 h2 should not be the same size as #item_1 h2");
  ok(this.container1.find('#item_2 h2').height() < this.container1.find('#item_1 h2').height());

  // apply the plugin
  this.container1.equalHeightHelper({selectorsToResize: ['h2'], breakpointSelector: '#qunit-fixture', breakpointWidth: 100});

  var tallest_item = this.container1.find('#item_1 h2');

  equal(this.container1.find('#item_2 h2').css('min-height'), tallest_item.css('height'));
  equal(this.container1.find('#item_2 h2').css('height'), tallest_item.css('height'));

  equal(this.container1.find('#item_3 h2').css('min-height'), tallest_item.css('height'));
  equal(this.container1.find('#item_3 h2').css('height'), tallest_item.css('height'));
});

test("should calculate the largest height separately for each container", function() {
  // set the width of the container so the largest h2 will wrap
  $("#qunit-fixture").width('200px');

  $('#qunit-fixture .container').equalHeightHelper({selectorsToResize: ['h2'], breakpointSelector: '#qunit-fixture', breakpointWidth: 100});

  var tallest_item_in_container1 = this.container1.find('#item_1 h2');

  this.container1.find('h2').each(function() {
    equal($(this).css('min-height'), tallest_item_in_container1.css('height'));
    equal($(this).css('height'), tallest_item_in_container1.css('height'));
  });

  this.container2.find('h2').each(function() {
    ok($(this).css('height') < tallest_item_in_container1.css('height'), "item in container 2 should be smaller than items in container1");
  });
});

test("if the the specified breakpoint element width is below specified breakpoint there should be no min-height restriction", function () {
  $("#qunit-fixture").width('200px');
  // apply the plugin setting the breakpoint to wider than the breakpointSelector element width
  this.container1.equalHeightHelper({selectorsToResize: ['h2'], breakpointSelector: '#qunit-fixture', breakpointWidth: 300});

  equal(this.container1.find('#item_2 h2').css('min-height'), "0px");
  equal(this.container1.find('#item_3 h2').css('min-height'), "0px");
});