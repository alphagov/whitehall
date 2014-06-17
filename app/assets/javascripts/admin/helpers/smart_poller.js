(function() {
  "use strict";
  window.GOVUK = window.GOVUK || {};

  window.GOVUK.smartPoller = function(wait, poller) {
    var max_wait = 10000000;

    ( function startPoller() {
        setTimeout(function() {
          poller.call(this, startPoller)
        }, wait);

      if ( wait < max_wait ) {
        wait = wait * 1.5
      };
    })();
  }
}());
