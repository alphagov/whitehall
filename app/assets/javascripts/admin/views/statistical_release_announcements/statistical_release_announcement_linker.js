(function() {
  "use strict";
  window.GOVUK = window.GOVUK || {};

  window.GOVUK.statisticalReleaseAnnouncementLinker = {
    init: function init() {
      var $linker = $('.js-document-announcement-linker'),
          $documentFinder = $('#document-finder'),
          $documentFinderResult = $documentFinder.find('#edition_id'),
          $annoucementForm = $('form.edit_statistical_release_announcement');

      // add link to reveal document finder
      var $revealLink = $('<a href=# class="announcement-linker-link">Link to an existing draft document</a>');
      $linker.append(' or ').append($revealLink);

      $revealLink.on('click', function () {
        $linker.hide();
        $documentFinder.show();
      });

      // add link to cancel and reset back to the default locale
      var $resetLink = $('<a href=# class="cancel-announcement-linker-link">cancel</a>');
      $documentFinder.append(' or ').append($resetLink);
      $resetLink.on('click', function () {
        // hide the documentFinder
        $documentFinder.hide();
        $linker.show();
      });

      // listener to assign publication when a result is clicked on in the documentFinder
      $documentFinderResult.change(function() {
        $annoucementForm.find('input#statistical_release_announcement_publication_id').val($(this).val());
        $annoucementForm.submit();
      });
    }
  };
}());
