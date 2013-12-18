(function() {
  "use strict";
  window.GOVUK = window.GOVUK || {};

  window.GOVUK.preview = {
    init: function init() {
      $('.document .body').enhanceYoutubeVideoLinks();
    }
  };
}());
