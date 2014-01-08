(function() {
  "use strict";
  window.GOVUK = window.GOVUK || {}

  var adminEditionShowPage = {
    init: function init(params) {
      this.hideExtraInboundLinks();
    },

    hideExtraInboundLinks: function hideExtraInboundLinks() {
      $('#inbound-links').hideExtraRows({rows: 10});
    }
  }

  window.GOVUK.adminEditionShowPage = adminEditionShowPage;
})();
