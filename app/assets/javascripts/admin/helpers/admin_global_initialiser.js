(function() {
  "use strict";
  window.GOVUK = window.GOVUK || {};

  window.GOVUK.adminGlobalInitialiser = {
    init: function init() {
      GOVUK.init(GOVUK.ieHandler);
      GOVUK.init(GOVUK.formsHelper);
      GOVUK.init(GOVUK.navBarHelper);
      GOVUK.init(GOVUK.tabs);
    }
  };
}());
