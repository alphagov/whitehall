function UnobtrusiveMap(map_link) {
  var map_url = map_link.href;
  var match = map_url.match(/(-?\d+\.\d+),(-?\d+\.\d+)/);
  var myOptions = {
    zoom: 15,
    mapTypeId: google.maps.MapTypeId.ROADMAP
  };

  this.map_canvas = jQuery('<div class="map_canvas"></div>');
  jQuery(map_link).after(this.map_canvas);

  var self = this;

  this.displayMapViaGeocoder = function(results, status) {
    if (status == google.maps.GeocoderStatus.OK) {
      map.setCenter(results[0].geometry.location);
      new google.maps.Marker({
        map: map,
        position: results[0].geometry.location
      });
      jQuery(map_link).hide();
    } else {
      self.map_canvas.hide();
    }
  };

  if(match) {
    var lat = match[1];
    var lng = match[2];
    var latlng = new google.maps.LatLng(lat, lng);
    myOptions.center = latlng;
    var map = new google.maps.Map(this.map_canvas[0], myOptions);
    var marker = new google.maps.Marker({
        map: map,
        position: latlng
    });
    jQuery(map_link).hide();
  } else {
    match = map_url.match(/q=(.*)/);
    var postcode = decodeURIComponent(match[1]);
    var map = new google.maps.Map(this.map_canvas[0], myOptions);
    var geocoder = new google.maps.Geocoder();
    geocoder.geocode({'address': postcode}, this.displayMapViaGeocoder);
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