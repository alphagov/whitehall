(function() {
  "use strict";
  window.GOVUK = window.GOVUK || {};

  function DocumentShareLinks(options) {
    this.$el = $(options.el);
    this.$el.find('.facebook').click($.proxy(function() {
      this.submitEvent('facebook');
    }, this));
    this.$el.find('.twitter').click($.proxy(function() {
      this.submitEvent('twitter');
    }, this));
  }

  DocumentShareLinks.prototype.submitEvent = function(network) {
    if (window._gaq) {
      // opt_target is set to location.pathname to clean up query strings, etc.
      window._gaq.push(['_trackSocial', network, 'share', location.pathname]);
    }
  };

  GOVUK.DocumentShareLinks = DocumentShareLinks;
}());
