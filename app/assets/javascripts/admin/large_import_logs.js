GOVUK.largeImportLogs = {
  init: function($largeDataLinks) {
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
};
