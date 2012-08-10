(function($) {
  var _trackExternalLinks = function() {
    $(this).find("a[rel='external']").each(function() {
      $(this).click(function(e) {
        try {
          if (!e.metaKey && !e.ctrlKey && window._gat && _gat && _gat._getTrackerByName && _gat._getTrackerByName()._trackEvent) {
            e.preventDefault();
            _gat._getTrackerByName()._trackEvent("Specialist-external-link", this.href);
            setTimeout("document.location = '" + this.href + "'", 100);
          }
        } catch(error) {
          // intentionally left blank
        }
      })
    })
  };

  $.fn.extend({
    trackExternalLinks: _trackExternalLinks
  });
})(jQuery);
