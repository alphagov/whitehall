require 'test_helper'

class WorldLocationNewsArticlePresenterTest < ActionView::TestCase

  setup do
    Draper::ViewContext.current = @controller.view_context
  end

  test "lead_image_path returns the world wide organisation default image" do
    image = create(:default_news_organisation_image_data)
    worldwide_organisation = create(:worldwide_organisation, default_news_image: image)
    world_location_news_article = create(:world_location_news_article, worldwide_organisations: [worldwide_organisation])
    presenter = WorldLocationNewsArticlePresenter.new(world_location_news_article, @view_context)
    assert_match worldwide_organisation.default_news_image.file.url(:s300), presenter.lead_image_path
  end
end
