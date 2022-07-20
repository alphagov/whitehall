// Happen as soon as the DOM is loaded and before assets are downloaded
jQuery(function ($) {
  $('.js-hide-other-links').hideOtherLinks()
  $('.js-hide-other-departments').hideOtherLinks({ linkElement: 'span', alwaysVisibleClass: '.lead' })

  $('.govspeak').enhanceYoutubeVideoLinks()

  GOVUK.worldLocationFilter.init()
  GOVUK.hideDepartmentChildren.init()
  GOVUK.filterListItems.init()
  GOVUK.showHide.init()
  GOVUK.feeds.init()
})
// These want images to be loaded before they run so the page height doesn't change.
jQuery(window).load(function () {
  GOVUK.backToContent.init()
})
