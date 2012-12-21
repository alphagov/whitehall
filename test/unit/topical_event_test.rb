require 'test_helper'

class TopicalEventTestTest < ActiveSupport::TestCase
  test "a new news article is not featured" do
    topical_event = create(:topical_event)
    news_article = build(:news_article)
    refute topical_event.featured?(news_article)
  end

  test "a featured news article is featured" do
    topical_event = create(:topical_event)
    news_article = create(:published_news_article)
    image = create(:classification_featuring_image_data)
    topical_event.feature(edition_id: news_article.id, alt_text: "A thing", image: image)
    featuring = topical_event.featuring_of(news_article)
    assert featuring
    assert_equal 1, featuring.ordering
    assert topical_event.featured?(news_article)
  end
end