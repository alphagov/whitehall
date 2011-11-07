(function ($) {
  var _markLinkedAnchor = function() {
    $(this).find(window.location.hash).addClass("linked");
  }

  $.fn.extend({
    markLinkedAnchor: _markLinkedAnchor
  });
})(jQuery);
