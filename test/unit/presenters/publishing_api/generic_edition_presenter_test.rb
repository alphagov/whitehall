require 'test_helper'

module PublishingApi
  class GenericEditionPresenterTest < ActiveSupport::TestCase
    include GovukContentSchemaTestHelpers::TestUnit

    def present(edition, options = {})
      PublishingApi::GenericEditionPresenter.new(edition, options)
    end

    test 'presents an Edition ready for adding to the publishing API' do
      edition = create(
        :news_article,
        title: 'The title',
        summary: 'The summary',
        primary_specialist_sector_tag: 'oil-and-gas/taxation',
        secondary_specialist_sector_tags: ['oil-and-gas/licensing']
      )

      public_path = Whitehall.url_maker.public_document_path(edition)

      expected_hash = {
        base_path: public_path,
        title: 'The title',
        description: 'The summary',
        schema_name: 'placeholder_news_article',
        document_type: 'press_release',
        locale: 'en',
        public_updated_at: edition.updated_at,
        publishing_app: 'whitehall',
        rendering_app: 'government-frontend',
        routes: [
          { path: public_path, type: 'exact' }
        ],
        redirects: [],
        update_type: "major",
        details: {
          tags: {
            browse_pages: [],
            policies: [],
            topics: ['oil-and-gas/taxation', 'oil-and-gas/licensing']
          }
        },
      }

      presented_item = present(edition)
      assert_equal expected_hash, presented_item.content
      assert_valid_against_schema(presented_item.content, 'placeholder')
    end

    test 'links hash includes topics and parent if set' do
      news_article = create(:news_article)
      create(:specialist_sector, topic_content_id: "content_id_1", edition: news_article, primary: true)
      create(:specialist_sector, topic_content_id: "content_id_2", edition: news_article, primary: false)

      links = present(news_article).links

      assert_equal links[:topics], %w(content_id_1 content_id_2)
      assert_equal links[:parent], %w(content_id_1)
    end

    test 'minor changes are a "minor" update type' do
      edition = create(:news_article, minor_change: true)
      assert_equal 'minor', present(edition).update_type
    end

    test 'update type can be overridden by passing an update_type option' do
      update_type_override = 'republish'
      edition = create(:news_article)
      presented_item = present(edition, update_type: update_type_override)
      assert_equal update_type_override, presented_item.update_type
    end
  end
end
