require "test_helper"
require "content_publisher/featured_document_migrator"

module ContentPublisher
  class FeaturedDocumentMigratorTest < ActiveSupport::TestCase
    test "updates feature with offsite url" do
      edition = create(:published_news_article)
      feature = create(:feature, document: edition.document, feature_list:)
      edition.document.update!(locked: true)

      ContentPublisher::FeaturedDocumentMigrator.new(edition.document).call
      feature.reload

      assert_nil feature.document_id
      assert_equal "https://www.test.gov.uk/government/news/news-title", feature.offsite_link.url
      assert_equal edition.public_timestamp, feature.offsite_link.date
    end

    test "uses the latest edition if document is not published" do
      edition = create(:news_article)
      feature = create(:feature, document: edition.document, feature_list:)
      edition.document.update!(locked: true)

      ContentPublisher::FeaturedDocumentMigrator.new(edition.document).call
      feature.reload

      assert_nil feature.document_id
      assert_equal "https://www.test.gov.uk/government/news/news-title", feature.offsite_link.url
      assert_equal edition.updated_at, feature.offsite_link.date
    end

    test "sets the correct link type for press_release" do
      edition = create(:published_news_article)
      feature = create(:feature, document: edition.document, feature_list:)
      edition.document.update!(locked: true)

      ContentPublisher::FeaturedDocumentMigrator.new(edition.document).call
      feature.reload

      assert_nil feature.document_id
      assert_equal "content_publisher_press_release", feature.offsite_link.link_type
    end

    test "sets the correct link type for news_story" do
      edition = create(:published_news_story)
      feature = create(:feature, document: edition.document, feature_list:)
      edition.document.update!(locked: true)

      ContentPublisher::FeaturedDocumentMigrator.new(edition.document).call
      feature.reload

      assert_nil feature.document_id
      assert_equal "content_publisher_news_story", feature.offsite_link.link_type
    end

    def feature_list
      create(:feature_list, locale: "en")
    end
  end
end
