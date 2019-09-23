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

    test "returns the lead organisations of the latest edition of a document" do
      published_edition_org = create(:organisation)
      published_edition_org_2 = create(:organisation)
      superseded_edition_org = create(:organisation)
      document = create(:document)
      create(
        :news_article,
        :superseded,
        document: document,
        organisations: [superseded_edition_org],
        news_article_type: NewsArticleType::NewsStory,
      )

      create(
        :news_article,
        :published,
        document: document,
        organisations: [published_edition_org, published_edition_org_2],
        news_article_type: NewsArticleType::NewsStory,
      )

      documents_info_exporter = DocumentsInfoExporter.new(
        [document.id],
      )

      assert_same_elements(
        [published_edition_org.content_id, published_edition_org_2.content_id],
        documents_info_exporter.call.first[:document_information][:lead_organisations],
      )
    end
  end
end
