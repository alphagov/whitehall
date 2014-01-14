(function() {
  "use strict";
  window.GOVUK = window.GOVUK || {};

  window.GOVUK.adminPreview = {
    init: function init() {
      $('.document .body').enhanceYoutubeVideoLinks();
    }
  };
}());
