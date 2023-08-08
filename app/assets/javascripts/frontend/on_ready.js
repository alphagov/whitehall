// Happen as soon as the DOM is loaded and before assets are downloaded
jQuery(function ($) {
  $('.govspeak').enhanceYoutubeVideoLinks()

  GOVUK.hideDepartmentChildren.init()
  GOVUK.showHide.init()
})
// These want images to be loaded before they run so the page height doesn't change.
jQuery(window).on('load', function () {
  GOVUK.backToContent.init()
})
