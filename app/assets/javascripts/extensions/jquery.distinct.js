(function($) {
  $.extend({
    distinct: function(array) {
      var result = [];
      $.each(array, function(i,v){
        if ($.inArray(v, result) == -1) result.push(v);
      });
      return result;
    }
  });
})(jQuery);
