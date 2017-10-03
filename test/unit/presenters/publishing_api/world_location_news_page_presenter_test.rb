require 'test_helper'

class PublishingApi::WorldLocationNewsPagePresenterTest < ActiveSupport::TestCase
  def present(model_instance)
    PublishingApi::WorldLocationNewsPagePresenter.new(model_instance, {})
  end

  def world_location
    @world_location ||= create(:world_location, name: "Aardistan", "title": "Aardistan and the Uk")
  end

  test 'presents an item for rummager' do
    expected_hash = {
      content_id: "a_guid",
      link: "/world/aardistan/news",
      format: "world_location_news_page",
      title: "Aardistan and the Uk",
      description: "Updates, news and events from the UK government in Aardistan",
      indexable_content: "Updates, news and events from the UK government in Aardistan"
    }

    Services.publishing_api.stubs(:lookup_content_ids).returns({})

    PublishingApi::WorldLocationNewsPagePresenter.any_instance.stubs(:content_id).returns("a_guid")

    presented_item = present(world_location)

    assert_equal expected_hash, presented_item.content_for_rummager
  end

  test 'with an item not yet in the publishing api, it presents a World Location News Page ready for publishing api' do
    expected_hash = {
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

    Services.publishing_api.stubs(:lookup_content_ids).returns({})

    PublishingApi::WorldLocationNewsPagePresenter.any_instance.stubs(:content_id).returns("a_new_guid")

    presented_item = present(world_location)

    assert_equal expected_hash, presented_item.content
    assert_equal "a_new_guid", presented_item.content_id
  end

  test 'with an item already in the publishing api, it presents a World Location News Page ready for publishing api' do
    expected_hash = {
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
      routes: [{ path: "/world/aardistan/news", type: "exact" }],
      analytics_identifier: "WL1",
      update_type: "major",
    }

    Services.publishing_api.stubs(:lookup_content_ids).returns("/world/aardistan/news" => "aguid")

    presented_item = present(world_location)

    assert_equal expected_hash, presented_item.content
    assert_equal "aguid", presented_item.content_id
  end

  test 'it only presents news pages in English' do
    I18n.with_locale(:fr) do
      presented_item = present(world_location)

      base_path = presented_item.content[:base_path]
      locale = presented_item.content[:locale]

      assert_equal "/world/aardistan/news", base_path
      assert_equal "en", locale
    end
  end
end
