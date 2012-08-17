module("Showing maps via lat/lng links", {
  setup: function() {
    this.map_link = $('<a class="link_to_map" href="http://maps.example.com?q=12.34,-56.78">map</a>')
    this.container = $('<div id="container"></div>');
    this.container.append(this.map_link);
    $("#qunit-fixture").append(this.container);

    google = {
      maps: {
        MapTypeId: {ROADMAP: 1},
        LatLng: function() {this.is = "defaultLatLng";},
        Map: function() {
          this.is = "defaultMap";
          this.setCenter = function() {};
        },
        Marker: function() {this.is = "defaultMarker";}
      }
    }
  }
});

test("should hide the link", function() {
  $(".link_to_map").replaceWithMap();

 ok(!this.map_link.is(":visible"));
})

test("should center the map using the lat and lng from the link", function() {
  sinon.stub(google.maps, "LatLng", function() { this.is = "fakeLatLng" });

  var stub_map = {setCenter: function() {}};
  sinon.stub(google.maps, "Map", function() {
    return stub_map;
  });
  var map_spy = sinon.spy(stub_map, "setCenter")

  $(".link_to_map").replaceWithMap();

  var call = map_spy.getCall(0);
  equals(call.args[0].is, "fakeLatLng");
})

test("should show a map", function() {
  var map_spy = sinon.spy(google.maps, "Map")

  $(".link_to_map").replaceWithMap();

  var created_map = $(this.container).children(".map_canvas")[0];
  ok(created_map, "map canvas should be on the page");
  equals(map_spy.getCall(0).args[0], created_map);
})

test("should add a marker", function() {
  sinon.stub(google.maps, "LatLng", function() { this.is = "fakeLatLng" });
  sinon.stub(google.maps, "Map", function() { this.is = "fakeMap"; this.setCenter = function() {}; });
  var marker_spy = sinon.spy(google.maps, "Marker");

  $(".link_to_map").replaceWithMap();

  var args = marker_spy.getCall(0).args[0];
  equals(args.map.is, "fakeMap");
  equals(args.position.is, "fakeLatLng");
})


module("Showing maps via postcode links", {
  setup: function() {
    this.map_link = $('<a class="link_to_map" href="http://maps.example.com?q=EC2A%202BE">map</a>')
    this.container = $('<div id="container"></div>');
    this.container.append(this.map_link);
    $("#qunit-fixture").append(this.container);

    google = {
      maps: {
        MapTypeId: {ROADMAP: 1},
        LatLng: function() {this.is = "defaultLatLng";},
        Map: function() {this.is = "defaultMap"; this.setCenter = function() {}},
        Marker: function() {this.is = "defaultMarker";},
        Geocoder: function() {
          this.is = "defaultGeocoder";
          this.geocode = function() {};
        },
        GeocoderStatus: {OK: 1}
      }
    }
  }
});

test("should geocode the decoded query value from the link href", function() {
  var stub_geocoder = {geocode: function() {}}
  sinon.stub(google.maps, "Geocoder", function() {
    return stub_geocoder;
  })
  var geocode_spy = sinon.spy(stub_geocoder, "geocode")

  $(".link_to_map").replaceWithMap();
  equals(geocode_spy.getCall(0).args[0].address, "EC2A 2BE")
})

test("should hide the link", function() {
  var unobtrusiveMap = new UnobtrusiveMap($(".link_to_map")[0])
  unobtrusiveMap.displayMapViaGeocoder([{geometry:{}}], google.maps.GeocoderStatus.OK)

  ok(!this.map_link.is(":visible"));
})

test("should show a map", function() {
  var map_spy = sinon.spy(google.maps, "Map")

  $(".link_to_map").replaceWithMap();

  var created_map = $(this.container).children(".map_canvas")[0];
  ok(created_map, "map canvas should be on the page");
  equals(map_spy.getCall(0).args[0], created_map);
})

test("should center the map using the results of geocoder", function() {
  var stub_map = {setCenter: function() {}};
  sinon.stub(google.maps, "Map", function() {
    return stub_map;
  });
  var map_spy = sinon.spy(stub_map, "setCenter")

  var unobtrusiveMap = new UnobtrusiveMap($(".link_to_map")[0])
  var fakeResult = [{geometry:{location: "fakeLocation"}}];
  unobtrusiveMap.displayMapViaGeocoder(fakeResult, google.maps.GeocoderStatus.OK)

  var call = map_spy.getCall(0);
  equals(call.args[0], "fakeLocation");
})

test("should add a marker", function() {
  var stub_map = {setCenter: function() {}};
  sinon.stub(google.maps, "Map", function() {
    return stub_map;
  });
  var map_spy = sinon.spy(stub_map, "setCenter")

  var unobtrusiveMap = new UnobtrusiveMap($(".link_to_map")[0])
  var fakeResult = [{geometry:{location: "fakeLocation"}}];

  var marker_spy = sinon.spy(google.maps, "Marker");

  unobtrusiveMap.displayMapViaGeocoder(fakeResult, google.maps.GeocoderStatus.OK)

  var args = marker_spy.getCall(0).args[0];
  equals(args.map, stub_map);
  equals(args.position, "fakeLocation");
})

test("should hide the map when geocoding fails", function() {
  var unobtrusiveMap = new UnobtrusiveMap($(".link_to_map")[0])
  unobtrusiveMap.displayMapViaGeocoder(null, google.maps.GeocoderStatus.DEFINITELY_NOT_OK)

  ok(!$(".map_canvas").is(":visible"))
})