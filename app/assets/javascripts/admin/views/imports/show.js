(function() {
  "use strict";
  window.GOVUK = window.GOVUK || {}

  var adminImportsShow = {
    init: function init(params) {
      adminImportsShow.handleLargeImportLogs($('.large-data-set'));
    },

    handleLargeImportLogs: function($largeDataLinks) {
      $largeDataLinks.click(function() {
        var $link = $(this);
        var $parent = $link.parent();

        if (!$parent.hasClass('loaded')) {
          $parent
            .addClass('loaded large-data-link')
            .text('Loading '+$link.text()+'..')
            .load($link.attr('href'));
        }

        return false;
      });

      $('.large-data-link.loaded h2').live('click', function() {
        $(this).nextAll().slideToggle('fast');
      });
    }
  }

  window.GOVUK.adminImportsShow = adminImportsShow;
})();
