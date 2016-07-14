require "test_helper"

module PublishingApi
  module PayloadBuilder
    class PolymorphicPathTest < ActiveSupport::TestCase
      test "returns political details for the item" do
        dummy_item = Object.new
        Whitehall.url_maker.expects(:polymorphic_path)
          .with(dummy_item)
          .returns("/polymorphic/doc/path")

        expected_hash = {
          base_path: "/polymorphic/doc/path",
          routes: [{ path: "/polymorphic/doc/path", type: "exact" }]
        }

        assert_equal PolymorphicPath.for(dummy_item), expected_hash
      end
    end
  end
end
