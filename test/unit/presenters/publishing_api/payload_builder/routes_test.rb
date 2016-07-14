require "test_helper"

module PublishingApi
  module PayloadBuilder
    class RoutesTest < ActiveSupport::TestCase
      test "returns a routes payload in the correct form" do
        base_path = "some/base/path"

        assert_equal({ routes: [{ path: base_path, type: "exact" }] }, Routes.for(base_path))
      end
    end
  end
end
