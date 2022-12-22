require "test_helper"

module PublishingApi
  module PayloadBuilder
    class PublicDocumentPathTest < ActiveSupport::TestCase
      test "returns political details for the item" do
        dummy_item = Object.new
        Whitehall.url_maker.expects(:public_document_path)
          .with(dummy_item, locale: I18n.locale)
          .returns("/government/pub/doc/path")

        expected_hash = {
          base_path: "/government/pub/doc/path",
          routes: [{ path: "/government/pub/doc/path", type: "exact" }],
        }

        assert_equal PublicDocumentPath.for(dummy_item), expected_hash
      end
    end
  end
end
