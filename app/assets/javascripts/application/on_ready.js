jQuery(function($) {
  $("#notes_to_editors").addToggleLink(".notes_to_editors");
  $("#featured-news-articles").featuredSectionCarousel();
  $("abbr.time_ago").timeago();
  $('section.featured_items').equalHeightHelper({selectorsToResize: ['h2 a', 'p.summary', 'div.image_summary']});
  $('section.article_group').equalHeightHelper({selectorsToResize: ['article']});
  $('.change_notes').policyUpdateNotes({link:'.metadata'});
});