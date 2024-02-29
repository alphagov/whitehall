require "test_helper"

module PublishingApi
  class GenericEditionPresenterTest < ActiveSupport::TestCase
    include GovukSchemas::AssertMatchers

    def present(edition, update_type: nil)
      edition.auth_bypass_id = "52db85fc-0f30-42a6-afdd-c2b31ecc6a67"
      PublishingApi::GenericEditionPresenter.new(edition, update_type:)
    end

    test "presents an Edition ready for adding to the publishing API" do
      edition = create(
        :news_article,
        title: "The title",
        summary: "The summary",
      )

      public_path = edition.public_path

      expected_hash = {
        base_path: public_path,
        title: "The title",
        description: "The summary",
        schema_name: "placeholder",
        document_type: "press_release",
        locale: "en",
        public_updated_at: edition.updated_at,
        publishing_app: Whitehall::PublishingApp::WHITEHALL,
        rendering_app: Whitehall::RenderingApp::GOVERNMENT_FRONTEND,
        routes: [
          { path: public_path, type: "exact" },
        ],
        redirects: [],
        auth_bypass_ids: %w[52db85fc-0f30-42a6-afdd-c2b31ecc6a67],
        update_type: "major",
        details: {
          tags: {
            browse_pages: [],
          },
        },
      }

      presented_item = present(edition)
      assert_equal expected_hash, presented_item.content
    end

    test 'minor changes are a "minor" update type' do
      edition = create(:news_article, minor_change: true)
      assert_equal "minor", present(edition).update_type
    end

    test "update type can be overridden by passing an update_type option" do
      update_type_override = "republish"
      edition = create(:news_article)
      presented_item = present(edition, update_type: update_type_override)
      assert_equal update_type_override, presented_item.update_type
    end

    test "presents the correct routes for an edition with a translation" do
      news_article = create(
        :news_article,
        translated_into: %i[en cy],
      )

      I18n.with_locale(:en) do
        presented_item = present(news_article)

        assert_equal news_article.base_path, presented_item.content[:base_path]

        assert_equal [
          { path: news_article.base_path, type: "exact" },
        ], presented_item.content[:routes]
      end

      I18n.with_locale(:cy) do
        presented_item = present(news_article)

        assert_equal "#{news_article.base_path}.cy", presented_item.content[:base_path]

        assert_equal [
          { path: "#{news_article.base_path}.cy", type: "exact" },
        ], presented_item.content[:routes]
      end
    end
  end
end
