require "test_helper"

class WorldLocationNewsArticleTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess

  should_allow_image_attachments
  should_have_first_image_pulled_out
  should_protect_against_xss_and_content_attacks_on :title, :body, :summary, :change_note

  test "should not be able to relate to other editions" do
    world_article = build(:world_location_news_article)
    refute world_article.can_be_related_to_policies?
  end

  test "should not be able to associate with organisations" do
    world_article = build(:world_location_news_article)
    refute world_article.can_be_related_to_organisations?
  end

  test 'search_format_types tags the news article as a world-location-news-article and announcement' do
    world_article = build(:world_location_news_article)
    assert world_article.search_format_types.include?('world-location-news-article')
    assert world_article.search_format_types.include?('announcement')
  end

  test "should be translatable" do
    world_article = build(:world_location_news_article)
    assert world_article.translatable?
  end
end
