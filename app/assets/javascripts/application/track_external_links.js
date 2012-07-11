(function($) {
  var _trackExternalLinks = function() {
    $(this).find("a[rel='external']").each(function() {
      $(this).click(function(e) {
        if (!e.metaKey && !e.ctrlKey) {
          e.preventDefault();
          _gat._getTrackerByName()._trackEvent(this.href, "Outbound Links");
          setTimeout("document.location = '" + this.href + "'", 100);
        }
      })
    })
  };

  $.fn.extend({
    trackExternalLinks: _trackExternalLinks
  });
})(jQuery);