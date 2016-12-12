module("virtual tour", {
  setup: function() {
    this.$tour = $('<div class="js-virtual-tour"></div>');
    $('#qunit-fixture').append(this.$tour);

    this.$nav = $('<div class="tour-nav"><a href="#one">one</a><a href="#two">two</a></div>');
    this.$tour.append(this.$nav);

    this.$info = $('<div id="one" data-tour-xml="one.xml" class="tour-info"></div><div id="two" data-tour-xml="two.xml" class="tour-info"></div>');
    this.$tour.append(this.$info);

    GOVUK.virtualTour.$tour = this.$tour;
    GOVUK.virtualTour.$nav = this.$nav;
  },
  teardown: function() {
    GOVUK.virtualTour.tours = [];
  }
});

test('adds tour player element' , function(){
  GOVUK.virtualTour.addTourPlayerWrapper();

  equal(this.$tour.find('#tour-player').length, 1);
});

test('finds all tours on the page' , function(){
  GOVUK.virtualTour.findTours();

  equal(GOVUK.virtualTour.tours.length, 2);
});

test('finds named tour from tours' , function(){
  GOVUK.virtualTour.findTours();

  equal(GOVUK.virtualTour.findTour('one').id, 'one');
  equal(GOVUK.virtualTour.findTour('one').xml, 'one.xml');
});

test('calls for tour switch based on event', function(){
  var event = {
    target: this.$nav.find("a[href='#one']"),
    preventDefault: function(){}
  };
  var mock = sinon.mock(GOVUK.virtualTour);
  mock.expects("loadTour").once().withArgs({ id: "one" });;

  GOVUK.virtualTour.tours = [ {id: "one"}, {id: "two"} ];

  GOVUK.virtualTour.switchTour(event);

  mock.restore();
});

test('loads new tour with tour object', function(){
  var mock = sinon.mock(window);
  mock.expects("embedpano").once().withArgs({ swf: "/government/assets/tour/tour_pano.swf", xml: "/government/assets/tour/two.xml", target: "tour-player"});
  GOVUK.virtualTour.$player = $('<div id="tour-player"></div>');
  this.$tour.prepend(GOVUK.virtualTour.$player);

  equal(this.$tour.find('.js-visible').length, 0);
  GOVUK.virtualTour.loadTour({ xml: 'two.xml', $el: this.$tour.find('#two') });
  equal(this.$tour.find('.js-visible').length, 1);

  mock.restore();
});

test('hides old tour info', function(){
  var mock = sinon.mock(window);
  mock.expects("embedpano").once().withArgs({ swf: "/government/assets/tour/tour_pano.swf", xml: "/government/assets/tour/two.xml", target: "tour-player"});
  GOVUK.virtualTour.$player = $('<div id="tour-player"></div>');
  this.$tour.prepend(GOVUK.virtualTour.$player);

  var one = this.$tour.find('#one');
  one.addClass('js-visible')
  ok(one.hasClass('js-visible'));
  GOVUK.virtualTour.loadTour({ xml: 'two.xml', $el: this.$tour.find('#two') });
  ok(!one.hasClass('js-visible'));

  mock.restore();
});

test('marks the nav as active and unmarks the old nav', function(){
  var mock = sinon.mock(window);
  mock.expects("embedpano").once();
  GOVUK.virtualTour.$player = $('<div id="tour-player"></div>');
  this.$tour.prepend(GOVUK.virtualTour.$player);
  var oneLink = this.$nav.find("a[href='#one']"),
    twoLink = this.$nav.find("a[href='#two']");
  oneLink.addClass('active-tour')

  GOVUK.virtualTour.loadTour({ xml: 'two.xml', $el: this.$tour.find('#two') });
  ok(!oneLink.hasClass('active-tour'));
  ok(twoLink.hasClass('active-tour'));

  mock.restore();
});
