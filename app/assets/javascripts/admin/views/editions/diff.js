(function() {
  "use strict";
  window.GOVUK = window.GOVUK || {}

  var adminEditionsDiff = {
    init: function init(params) {
      GOVUK.diff('title');
      GOVUK.diff('summary');
      GOVUK.diff('body');
    }
  }

  window.GOVUK.adminEditionsDiff = adminEditionsDiff;
})();
