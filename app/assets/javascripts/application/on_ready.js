jQuery(function($) {
  $("#notes_to_editors").addToggleLink(".notes_to_editors");
  $("#featured-news-articles, #featured-consultations").featuredSectionCarousel();
  $("abbr.time_ago").timeago();
});