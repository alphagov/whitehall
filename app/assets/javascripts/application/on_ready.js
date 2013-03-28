jQuery(function($) {
  $('.js-hide-other-links').hideOtherLinks();

  $('.govspeak').enhanceYoutubeVideoLinks();

  $('.detailed-guides-show').trackExternalLinks();

  GOVUK.stickAtTopWhenScrolling.init();
  GOVUK.backToContent.init();

  $('.js-toggle-change-notes').toggler();
  $('.js-toggle-accessibility-warning').toggler({header: ".toggler", content: ".help-block"})
  $('.js-toggle-org-list').toggler({actLikeLightbox: true})

  $(".js-document-filter").enableDocumentFilter();

  $('.js-hide-extra-logos .organisations-icon-list').hideExtraRows({
    appendToParent: true,
    showWrapper: $('<li/>')
  });
  $('.js-hide-extra-contacts').hideExtraRows({ rows: 2 });
  $('.js-hide-extra-social-media').hideExtraRows({ rows: 5 });

  GOVUK.hideDepartmentChildren.init();
  GOVUK.filterListItems.init();
  GOVUK.joiningMessage.init();
  GOVUK.showHide.init();
  GOVUK.emailSignup.init();
});
