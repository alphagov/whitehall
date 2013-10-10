(function () {
  "use strict"
  var root = this,
      $ = root.jQuery;
  if(typeof root.GOVUK === 'undefined') { root.GOVUK = {}; }

  var showHide = {

    init: function() {
      showHide.$toggle = $('.js-showhide');
      if (showHide.$toggle.length > 0) {
        showHide.$target = $(showHide.$toggle[0].hash);

        showHide.$toggle.on('click', showHide.toggle);

        if (showHide.$toggle.is(':visible')) {
          // if toggle is visible
          showHide.hideStuff(); // hide stuff on init
        }
      }
    },
    toggle: function(e) {
      e.preventDefault();
      if (!showHide.$target.hasClass('js-hidden')) {
        showHide.hideStuff();
      } else {
        showHide.showStuff();
      }
      return false;
    },
    showStuff: function() {
      showHide.$target.removeClass('js-hidden');
      showHide.$toggle.removeClass('closed')
        .text(showHide.$toggle.text().replace('Show', 'Hide'));
    },
    hideStuff: function() {
      showHide.$target.addClass('js-hidden');
      showHide.$toggle.addClass('closed')
        .text(showHide.$toggle.text().replace('Hide', 'Show'));
    }
  };
  root.GOVUK.showHide = showHide;
}).call(this);
