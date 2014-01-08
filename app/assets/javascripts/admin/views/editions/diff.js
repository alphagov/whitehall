(function() {
  "use strict";
  window.GOVUK = window.GOVUK || {}

  var adminEditionsDiffPage = {
    init: function init(params) {
      GOVUK.diff('title');
      GOVUK.diff('summary');
      GOVUK.diff('body');
    }
  }

  window.GOVUK.adminEditionsDiffPage = adminEditionsDiffPage;
})();
