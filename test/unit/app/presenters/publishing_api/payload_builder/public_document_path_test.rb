require "test_helper"

module PublishingApi
  module PayloadBuilder
    class PublicDocumentPathTest < ActiveSupport::TestCase
      test "returns path for the document" do
        edition = create(:edition, title: "Some news")

        expected_hash = {
          base_path: "/government/generic-editions/some-news",
          routes: [{ path: "/government/generic-editions/some-news", type: "exact" }],
        }

        assert_equal PublicDocumentPath.for(edition), expected_hash
      end
    end
  end
end
