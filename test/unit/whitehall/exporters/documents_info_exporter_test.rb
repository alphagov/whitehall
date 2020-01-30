require "test_helper"

module Whitehall::Exporters
  class DocumentsInfoExporterTest < ActiveSupport::TestCase
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
