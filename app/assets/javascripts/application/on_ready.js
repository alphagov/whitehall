jQuery(function($) {
  $("#notes_to_editors").addToggleLink(".notes_to_editors");
  $("#featured-news-articles").featuredSectionCarousel();
  $("abbr.time_ago").timeago();
  $('section.featured_items').featuredSection({selectorsToResize: ['h2', 'p.summary']});
});