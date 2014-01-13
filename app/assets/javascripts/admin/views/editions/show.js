(function() {
  "use strict";
  window.GOVUK = window.GOVUK || {}

  var adminEditionShow = {
    init: function init(params) {
      this.hideExtraInboundLinks();
    },

    hideExtraInboundLinks: function hideExtraInboundLinks() {
      $('#inbound-links').hideExtraRows({rows: 10});
    }
  }

  window.GOVUK.adminEditionShow = adminEditionShow;
})();
