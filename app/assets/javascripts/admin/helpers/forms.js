(function() {
  "use strict";
  window.GOVUK = window.GOVUK || {};

  window.GOVUK.formsHelper = {
    init: function init() {
      this.initChznSelects();
    },

    initChznSelects: function initChznSelects() {
      $(".chzn-select").chosen({allow_single_deselect: true, search_contains: true, disable_search_threshold: 10, width: '100%'});
      $(".chzn-select-no-search").chosen({allow_single_deselect: true, disable_search: true, width: '100%'});

      if(typeof window.ieVersion === 'undefined'){
        $(".chzn-select-non-ie").addClass('chzn-select').chosen({allow_single_deselect: true, search_contains: true});
      }
    }
  };
}());

