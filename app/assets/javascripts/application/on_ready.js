// Happen as soon as the DOM is loaded and before assets are downloaded
jQuery(function($) {
  $('.js-hide-other-links').hideOtherLinks();
  $('.js-hide-other-departments').hideOtherLinks({ linkElement: 'span', alwaysVisibleClass: '.lead' });

  $('.govspeak').enhanceYoutubeVideoLinks();

  GOVUK.stickAtTopWhenScrolling.init();

  $('.js-toggle-change-notes').toggler({actLikeLightbox: true});
  $('.js-toggle-footer-change-notes').toggler();

  $('.js-toggle-accessibility-warning').toggler({header: ".toggler", content: ".help-block"})

  $(".js-document-filter").enableDocumentFilter();

  $('.js-hide-extra-social-media').hideExtraRows({ rows: 5 });
  $('.js-hide-extra-metadata').hideExtraRows({ rows: 2, appendToParent: true });

  $('.see-all-updates').click(function(e) {
    GOVUK.stickAtTopWhenScrolling.stick($('.js-stick-at-top-when-scrolling'));
    $('#history .overlay').removeClass('visuallyhidden');
  });

  GOVUK.hideDepartmentChildren.init();
  GOVUK.filterListItems.init();
  GOVUK.showHide.init();
  GOVUK.virtualTour.init();
  GOVUK.feeds.init();

});
// These want images to be loaded before they run so the page height doesn't change.
jQuery(window).load(function(){
  GOVUK.backToContent.init();
});
