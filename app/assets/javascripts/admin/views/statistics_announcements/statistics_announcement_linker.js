(function () {
  'use strict'
  window.GOVUK = window.GOVUK || {}

  window.GOVUK.statisticsAnnouncementLinker = {
    init: function init () {
      var $linker = $('.js-document-announcement-linker')
      var $documentFinder = $('#document-finder')
      var $documentFinderResult = $documentFinder.find('#edition_id')
      var $annoucementForm = $('form.edit_statistics_announcement')
      var $publicationInput = $annoucementForm.find('input#statistics_announcement_publication_id')

      // Link to reveal document finder
      var $revealLink = $('<a href=# class="js-announcement-linker-link"></a>')
      $revealLink.on('click', function () {
        $linker.hide()
        $documentFinder.show()
        $documentFinder.find('input#title').focus()
      })

      // insert the revealLink at the appropriate point with the appropriate
      // text depending on whether it's linking or changing an existing link
      if ($publicationInput.val() === '') {
        $revealLink.text('connect an existing draft')
        $linker.append(' or ').append($revealLink)
      } else {
        $revealLink.text('Change linked document')
        $linker.append('<br />').append($revealLink)
      }

      // add link to cancel document linking
      var $resetLink = $('<a href=# class="js-cancel-announcement-linker-link">cancel</a>')
      $documentFinder.append(' or ').append($resetLink)
      $resetLink.on('click', function () {
        // hide the documentFinder
        $documentFinder.hide()
        $linker.show()
      })

      // listener to assign publication when a result is clicked on in the documentFinder
      $documentFinderResult.change(function () {
        $publicationInput.val($(this).val())
        $annoucementForm.submit()
      })
    }
  }
}())
