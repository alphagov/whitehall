(function(Modules) {
  "use strict";

  Modules.TrackSelectClick = function() {
    function trackClick(event) {
      var $el = $(event.target);
      var action = $el.data('track-action');

      if (!action) {
        var selectBoxSelector = '#' + event.target.id;
        action = getTextOptions(selectBoxSelector, $el.val());

        if ($el.attr("multiple")) {
          action = getMultipleSelectValues(selectBoxSelector);
        }
      }

      var dataCategory = $el.data('track-category'),
          dataAction = action,
          dataLabel = $el.data('track-label');

      if (GOVUKAdmin.trackEvent) {
        GOVUKAdmin.trackEvent(dataCategory, dataAction, { label: dataLabel });
      }
    };

    function getMultipleSelectValues(selectBoxSelector) {
      var selectedOptionValues = $(selectBoxSelector).val();
      var selectedOptionTextValues = [];

      if (selectedOptionValues) {
        selectedOptionTextValues = selectedOptionValues.map(function(item) {
          return getTextOptions(selectBoxSelector, item);
        });
      }

      return selectedOptionTextValues.toString();
    };

    function getTextOptions(selectBoxSelector, value) {
      return $(selectBoxSelector + ' option[value="' + value + '"]').text();
    };

    this.start = function(element) {
      element.on('change', trackClick);
    };
  };
})(window.GOVUKAdmin.Modules);
