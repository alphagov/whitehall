require "test_helper"

class ConfigurableDocumentTypes::Conversions::NewsArticleTest < ActiveSupport::TestCase
  class PublishingApiMock
    attr_accessor :patched_links_for

    def initialize
      @patched_links_for = []
    end

    def patch_links(edition)
      @patched_links_for << {
        type: edition.configurable_document_type,
        edition_organisations: edition.edition_organisations,
      }
    end
  end

  test "converting news story to world news story patches Publishing API links for the old configurable document type with edition organisations cleared" do
    old_type = ConfigurableDocumentType.new({ "key" => "news_story" })
    new_type = ConfigurableDocumentType.new({ "key" => "world_news_story" })
    edition = build(:standard_edition, :with_organisations, configurable_document_type: old_type.key, document: build(:document))
    publishing_api_mock = PublishingApiMock.new
    conversion = ConfigurableDocumentTypes::Conversions::NewsArticle.new(old_type, new_type, publishing_api_mock)

    conversion.convert(edition)

    patched_linksets = publishing_api_mock.patched_links_for
    assert_equal 1, patched_linksets.size
    assert_equal old_type.key, patched_linksets.first[:type]
    assert_empty patched_linksets.first[:edition_organisations]
  end
end