require "test_helper"

module PublishingApi
  module PayloadBuilder
    class RoutesTest < ActiveSupport::TestCase
      test "returns a routes payload without additional routes" do
        base_path = "some/base/path"

        assert_equal({ routes: [{ path: base_path, type: "exact" }] }, Routes.for(base_path))
      end

      test "returns a routes payload with additional routes" do
        base_path = "some/base/path"
        additional_routes = %w[atom rss]
        expected_routes = [
          { path: base_path, type: "exact" },
          { path: "#{base_path}.atom", type: "exact" },
          { path: "#{base_path}.rss", type: "exact" },
        ]

        assert_equal({ routes: expected_routes }, Routes.for(base_path, additional_routes:))
      end
    end
  end
end
