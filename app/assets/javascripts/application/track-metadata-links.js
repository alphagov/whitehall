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
            type = $link.attr('class'),
            position = $metadataBlock.data('trackposition'),
            linkPosition, $linkParent, linkType;

        if(position === 'top'){
          linkPosition = $link.index() +1; // zero offset so +1
        } else {
          $linkParent = $link.closest('dd');
          linkType = $linkParent.attr('class');
          linkPosition = $metadataBlock.find('dd.'+linkType).index($linkParent) +1;
        }

        gaParams[3] = [ type, position, linkPosition ].join('|');

        if($link.attr('class') !== 'show-other-content'){
          GOVUK.cookie('ga_nextpage_params', gaParams.join(','));
        }
      });
    });
  };
})();
