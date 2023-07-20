require "test_helper"

module PublishingApi
  module PayloadBuilder
    class PolymorphicPathTest < ActiveSupport::TestCase
      test "returns routes for the item" do
        dummy_item = create(:news_article)

        expected_hash = {
          base_path: "/government/news/news-title",
          routes: [{ path: "/government/news/news-title", type: "exact" }],
        }

        assert_equal PolymorphicPath.for(dummy_item), expected_hash
      end
    end
  end
end
