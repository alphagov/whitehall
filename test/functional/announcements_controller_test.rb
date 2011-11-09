require "test_helper"

class AnnouncementsControllerTest < ActionController::TestCase
  should_render_a_list_of :news_articles
  should_render_a_list_of :speeches
end