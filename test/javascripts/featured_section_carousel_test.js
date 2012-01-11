module("Featured news section", {
  setup: function() {
    this.container = $('<section class="featured_items"></section>');
    this.container.append($('<article id="news_1"></article>'));
    this.container.append($('<article id="news_2"></article>'));
    this.container.append($('<article id="news_3"></article>'));

    $(this.container).css({
      width: '200px',
      height: '100px',
      border: '1px solid #000',
      position: 'relative'
    });

    $(this.container).find('article').css({
      width: '100%',
      height: '120px',
      opacity: '0.5'
    });

    $('#qunit-fixture').append(this.container);

    // uncomment if you want to see the animations happen

    // $(this.container).find('#news_1').css({background: "red"});
    // $(this.container).find('#news_2').css({background: "blue"});
    // $(this.container).find('#news_3').css({background: "yellow"});

    // $("#qunit-fixture").css({
    //   position: 'relative',
    //   top: 'auto',
    //   left: 'auto'
    // });

    // turn jquery animations off
    $.fx.off = true;

    // sinon overrides setTimeout so we need
    // to turn that off to do async tests etc
    // and let the behaviour in this plugin
    // run as it should ..
    sinon.config.useFakeTimers = false;
  }
});

test("should add carousel-enabled class to container", function() {
  this.container.featuredSectionCarousel();
  ok($(this.container).hasClass('carousel-enabled'));
})

test("should create navigation for the featured items", function () {
  this.container.featuredSectionCarousel();

  ok($(this.container).find('.carousel-nav'));
  ok($(this.container).find('.carousel-nav a[href=#news_1]'));
  ok($(this.container).find('.carousel-nav a[href=#news_2]'));
  ok($(this.container).find('.carousel-nav a[href=#news_3]'));
});

test("should highlight navigation element denoting the currently shown featured item", function () {
  this.container.featuredSectionCarousel();
  ok($(this.container).find('.carousel-nav a[href=#news_1]').hasClass('selected'));
});

test("should cycle through each article automatically", 9, function () {
  stop();

  this.container.featuredSectionCarousel({
    delay: 500
  });

  // // useful to show the nav in the fixture.
  // $(this.container).find('.carousel-nav').css({
  //   position: 'absolute',
  //   top: 0,
  //   right: 0
  // });

  var item_holder = $(this.container).find('.carousel-items');
  var nav = $(this.container).find('.carousel-nav');

  equals(item_holder.position().top, item_holder.find('#news_1').position().top, "should be showing news 1");
  equals(nav.find('a.selected').length, 1, "should only have single selected nav element");
  ok(nav.find('a[href=#news_1]').hasClass('selected'), "news 1 should be selected nav element");

  setTimeout(function () {
    equals(item_holder.position().top, -item_holder.find('#news_2').position().top, "should be showing news 2");
    equals(nav.find('a.selected').length, 1, "should only have single selected nav element");
    ok(nav.find('a[href=#news_2]').hasClass('selected'), "news 3 should be selected nav element");

    setTimeout(function () {
      equals(item_holder.position().top, -item_holder.find('#news_3').position().top, "should be showing news 3");
      equals(nav.find('a.selected').length, 1, "should only have single selected nav element");
      ok(nav.find('a[href=#news_3]').hasClass('selected'), "news 3 should be selected nav element");

    }, 500);
  }, 500);

  setTimeout(function () {
    start();
  }, 2000);
});

test("should pause transitions upon hovering over container", function () {
  stop();

  this.container.featuredSectionCarousel({
    delay: 500
  });

  var item_holder = $(this.container).find('.carousel-items');
  var nav = $(this.container).find('.carousel-nav');

  setTimeout(function () {
    equals(item_holder.position().top, -item_holder.find('#news_2').position().top, "should be showing news 2");

    // hover over the wrapper element
    item_holder.trigger('mouseenter');

    equals(nav.find('a.selected').length, 1, "should only have single selected nav element");
    ok(nav.find('a[href=#news_2]').hasClass('selected'), "news 2 should be selected nav element");

    setTimeout(function () {
      equals(item_holder.position().top, -item_holder.find('#news_2').position().top, "should still be showing news 2");
      equals(nav.find('a.selected').length, 1, "should only have single selected nav element");
      ok(nav.find('a[href=#news_2]').hasClass('selected'), "news 2 should be selected nav element");

    }, 500);
  }, 500);

  setTimeout(function () {
    start();
  }, 2000);
});

test("should be able to view an item by clicking on the relevant nav link", function () {
  // stop();

  this.container.featuredSectionCarousel({
    delay: 500
  });

  var item_holder = $(this.container).find('.carousel-items');
  var nav = $(this.container).find('.carousel-nav');

  // hover over the wrapper element
  item_holder.trigger('mouseenter');

  equals(item_holder.position().top, -item_holder.find('#news_1').position().top, "should be showing news 1");
  equals(nav.find('a.selected').length, 1, "should only have single selected nav element");
  ok(nav.find('a[href=#news_1]').hasClass('selected'), "news 1 should be selected nav element");

  // click nav el for news article 3
  nav.find('a[href=#news_3]').click();

  equals(item_holder.position().top, -item_holder.find('#news_3').position().top, "should now be showing news 3");
  equals(nav.find('a.selected').length, 1, "should only have single selected nav element");
  ok(nav.find('a[href=#news_3]').hasClass('selected'), "news 3 should be selected nav element");
});