(function(Modules) {
  "use strict";

  Modules.TrackButtonClick = function() {
    this.start = function(container) {
      var trackClick = function() {
        var category = container.data("track-category"),
            action = container.data("track-action") || "button-pressed",
            label = $(this).is(":input") ? $(this).val() : $(this).text();

        GOVUKAdmin.trackEvent(category, action, { label: label });
      };

      container.on("click", ".btn", trackClick);
    }
  };

})(window.GOVUKAdmin.Modules);
