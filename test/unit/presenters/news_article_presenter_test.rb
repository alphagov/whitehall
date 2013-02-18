require 'test_helper'

class NewsArticlePresenterTest < PresenterTestCase

  setup do
    organisation = build(:organisation, slug: "slug", organisation_type: build(:organisation_type))
    @news_article = build(:news_article, organisations: [organisation])
    # TODO: perhaps rethink edition factory, so this apparent duplication
    # isn't neccessary
    @news_article.stubs(:organisations).returns([organisation])
    @presenter = NewsArticlePresenter.decorate(@news_article)
  end

  test "lead_image_path returns the default image" do
    assert_match 'placeholder', @presenter.lead_image_path
  end

  test "lead_image_path returns the department's default placeholder" do
    @presenter.stubs(:find_asset).returns(true)
    assert_match 'slug', @presenter.lead_image_path
  end
end
