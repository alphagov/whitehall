function UnobtrusiveMap(map_link) {
  var _this = this;

  var map_url = map_link.href;
  var match = map_url.match(/(-?\d+\.\d+),(-?\d+\.\d+)/);
  var myOptions = {
    zoom: 15,
    mapTypeId: google.maps.MapTypeId.ROADMAP
  };

  _this.map_canvas = jQuery('<div class="map_canvas"></div>');
  jQuery(map_link).after(_this.map_canvas);

  _this.map = new google.maps.Map(_this.map_canvas[0], myOptions);

  _this.addMarkerAndCenterMap = function(location) {
    _this.map.setCenter(location);
    new google.maps.Marker({
      map: _this.map,
      position: location
    });
    jQuery(map_link).hide();
  };

  _this.displayMapViaGeocoder = function(results, status) {
    if (status == google.maps.GeocoderStatus.OK) {
      _this.addMarkerAndCenterMap(results[0].geometry.location);
    } else {
      _this.map_canvas.hide();
    }
  };

  if(match) {
    var lat = match[1];
    var lng = match[2];
    var latlng = new google.maps.LatLng(lat, lng);
    _this.addMarkerAndCenterMap(latlng);
  } else {
    match = map_url.match(/q=(.*)/);
    var postcode = decodeURIComponent(match[1]);
    var geocoder = new google.maps.Geocoder();
    geocoder.geocode({'address': postcode}, _this.displayMapViaGeocoder);
  }
}

(function($) {
  $.fn.extend({
    replaceWithMap: function() {
      $(this).each(function() {
        new UnobtrusiveMap(this);
      });
    }
  })
})(jQuery);

jQuery(function($) {
  $("a.link_to_map").replaceWithMap();
})