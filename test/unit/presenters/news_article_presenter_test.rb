require 'test_helper'

class NewsArticlePresenterTest < ActionView::TestCase

  setup do
    @organisation = create(:organisation, organisation_type: create(:organisation_type))
    @news_article = create(:news_article, organisations: [@organisation])
    @presenter = NewsArticlePresenter.new(@news_article, @view_context)
  end

  test "lead_image_path returns the default image" do
    assert_match 'placeholder', @presenter.lead_image_path
  end

  test "lead_image_path returns the department's default placeholder" do
    @presenter.stubs(:find_asset).returns(true)
    assert_match "organisation_default_news/s300_#{@organisation.slug}.jpg", @presenter.lead_image_path
  end

  test "lead_image_path returns the department default image" do
    image = create(:default_news_organisation_image_data)
    organisation = create(:organisation,
                            organisation_type: create(:organisation_type),
                            default_news_image: image
                          )
    news_article = create(:news_article, organisations: [organisation])
    presenter = NewsArticlePresenter.new(news_article, @view_context)
    assert_match organisation.default_news_image.file.url(:s300), presenter.lead_image_path
  end
end
