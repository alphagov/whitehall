(function () {
  'use strict'
  window.GOVUK = window.GOVUK || {}

  window.GOVUK.smartPoller = function (wait, polledFunction) {
    var maxWait = 10000000

    function startPoller () {
      setTimeout(function () {
        polledFunction(startPoller)
      }, wait)

      if (wait < maxWait) {
        wait = wait * 1.5
      };
    }

    startPoller()
  }
}())
