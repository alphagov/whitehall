require "test_helper"

class NewsArticlePresenterTest < ActiveSupport::TestCase
  test "should use placeholder image if none had been uploaded" do
    news_article = build(:news_article)
    presenter = NewsArticlePresenter.decorate(news_article)
    assert_match /placeholder.jpg/, presenter.lead_image_path
    assert_equal 'placeholder', presenter.lead_image_alt_text
  end

  test "should use first image with version :s300 if an image is present" do
    image = build(:image)
    news_article = build(:news_article, images: [image])
    presenter = NewsArticlePresenter.decorate(news_article)
    assert_match /s300_minister-of-funk/, presenter.lead_image_path
    assert_equal image.alt_text, presenter.lead_image_alt_text
  end
end
