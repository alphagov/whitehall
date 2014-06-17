(function() {
  "use strict";
  window.GOVUK = window.GOVUK || {};

  window.GOVUK.brokenLinksReport = {
    init: function init() {
      setInterval(this.refreshBrokenLinksReport, 2000);
    },

    refreshBrokenLinksReport: function refreshBrokenLinksReport() {
      $('a.js-broken-links-refresh').click();
    }
  };
}());
