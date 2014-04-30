(function() {
  "use strict";
  window.GOVUK = window.GOVUK || {};

  /*
   * Track metadata links
   */
  GOVUK.trackMetadataLinks = function (options) {
    $(function() {
      $('.js-track-metadata-links').on('click', 'a', function(e){
        var $link = $(e.target),
            gaParams = ['_setCustomVar', 14, 'metadata_click_track', '', 3],
            $metadataBlock = $link.closest('.js-track-metadata-links'),
            type = $link.closest('dd').data('tracktype'),
            linkPosition = $metadataBlock.find('.'+ type + ' a').index($link) + 1, // zero offset so +1
            position = $metadataBlock.data('trackposition');

        gaParams[3] = [ type, position, linkPosition ].join('|');

        if($link.attr('class') !== 'show-other-content'){
          GOVUK.cookie('ga_nextpage_params', gaParams.join(','));
        }
      });
    });
  };
})();
