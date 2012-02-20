jQuery(function($) {
  $("#notes_to_editors").addToggleLink(".notes_to_editors");
  $("#featured-news-articles").featuredSectionCarousel();
  $("abbr.time_ago").timeago();
  $('section.featured_items').equalHeightHelper({selectorsToResize: ['h2 a', 'p.summary', 'div.image_summary']});
  $('section.article_group').equalHeightHelper({selectorsToResize: ['article']});
  $('.change_notes').policyUpdateNotes({link:'.link-to-change-notes'});
  $('#global-nav').navHelper({
    breakpoints: [
      { width: 540, label: 'All sections', exclude: '.home, .current' },
      { width: 850, label: 'More sections', exclude: '.home, .current, .primary' }
    ]
  });
});