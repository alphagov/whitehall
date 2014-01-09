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

    $(document).on('click', '.large-data-link.loaded h2', function() {
      $(this).nextAll().slideToggle('fast');
    });
  }
};
