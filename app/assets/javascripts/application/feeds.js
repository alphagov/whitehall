(function() {
  "use strict";
  window.GOVUK = window.GOVUK || {};

  window.GOVUK.feeds = {
    init: function() {
      $('.js-feed').on('click', window.GOVUK.feeds.toggle);
    },
    toggle: function(e) {
      e.preventDefault();
      var panel = $(e.target).siblings('.js-feed-panel');
      panel.toggle();
      panel.find('input').select();
    }
  };
}());

