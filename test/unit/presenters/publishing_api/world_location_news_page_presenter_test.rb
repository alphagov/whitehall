require 'test_helper'

class PublishingApi::WorldLocationNewsPagePresenterTest < ActiveSupport::TestCase
  def present(model_instance)
    PublishingApi::WorldLocationNewsPagePresenter.new(model_instance, {})
  end

  def world_location
    @world_location ||= create(:world_location, name: "Aardistan", "title": "Aardistan and the Uk")
  end

  test 'presents an item for publishing api' do
    expected = {
      title: "Aardistan and the Uk",
      locale: "en",
      publishing_app: "whitehall",
      redirects: [],
      description: "Updates, news and events from the UK government in Aardistan",
      details: {},
      document_type: "placeholder_world_location_news_page",
      public_updated_at: world_location.updated_at,
      rendering_app: "whitehall-frontend",
      schema_name: "placeholder",
      base_path: "/world/aardistan/news",
      routes: [{ path:  "/world/aardistan/news", type: "exact" }],
      analytics_identifier: "WL1",
      update_type: "major",
    }

    assert_equal expected, present(world_location).content
  end

  test 'presents an item for rummager' do
    expected = {
      content_id: "id-123",
      link: "/world/aardistan/news",
      format: "world_location_news_page",
      title: "Aardistan and the Uk",
      description: "Updates, news and events from the UK government in Aardistan",
      indexable_content: "Updates, news and events from the UK government in Aardistan"
    }

    assert_equal expected, present(world_location).content_for_rummager("id-123")
  end

  test 'it builds localised base paths correctly' do
    I18n.with_locale(:fr) do
      presented_item = present(world_location)
      base_path = presented_item.content[:base_path]

      assert_equal "/world/aardistan/news.fr", base_path
    end
  end
end
