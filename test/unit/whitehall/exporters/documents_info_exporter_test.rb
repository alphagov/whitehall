require "test_helper"

module Whitehall::Exporters
  class DocumentsInfoExporterTest < ActiveSupport::TestCase
    test "returns all subtype information of a document" do
      org = create(:organisation)
      document = create(:document)
      create(
        :news_article,
        :superseded,
        organisations: [org],
        document: document,
        news_article_type: NewsArticleType::NewsStory,
      )
      create(
        :news_article,
        :published,
        organisations: [org],
        document: document,
        news_article_type: NewsArticleType::PressRelease,
      )

      documents_info_exporter = DocumentsInfoExporter.new(
        [document.id],
      )

      assert_equal(
        %w[news_story press_release],
        documents_info_exporter.call.first[:document_information][:subtypes],
      )
    end


    test "returns all the locales of a document" do
      org = create(:organisation)
      news_story = create(
        :news_article,
        :published,
        :translated, primary_locale: "en", translated_into: %w(ms ar cy),
        organisations: [org],
        news_article_type: NewsArticleType::NewsStory
      )

      documents_info_exporter = DocumentsInfoExporter.new(
        [news_story.document_id],
      )

      assert_same_elements(
        %w[ar cy en ms],
        documents_info_exporter.call.first[:document_information][:locales],
      )
    end
  end
end
