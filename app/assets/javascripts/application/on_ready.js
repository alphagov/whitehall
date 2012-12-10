jQuery(function($) {
  $("abbr.time_ago").timeago();

  $('.js-hide-other-links').hideOtherLinks();

  $('.document.body').enhanceYoutubeVideoLinks();

  $('.detailed-guides-show').trackExternalLinks();

  GOVUK.stickAtTopWhenScrolling.init();
  GOVUK.backToContent.init();

  $('.js-toggle-change-notes').toggler();
  $('.js-toggle-accessibility-warning').toggler({header: ".toggler", content: ".help-block"})
  $('.js-toggle-nav').toggler({header: ".toggler", content: ".content", showArrow: false, actLikeLightbox: true})

  $(".js-document-filter").enableDocumentFilter();

  $('.js-hide-extra-logos .organisations-icon-list').hideExtraRows({
    appendToParent: true,
    showWrapper: $('<li class="show-other-content" />')
  });
  $('.js-hide-extra-rows').hideExtraRows();
  $('.js-hide-extra-rows-2').hideExtraRows({ rows: 2 });
  $('.js-hide-extra-rows-3').hideExtraRows({ rows: 3 });

  GOVUK.hideDepartmentChildren.init();
  GOVUK.filterListItems.init();
  GOVUK.joiningMessage.init();
  GOVUK.showHide.init();
});
