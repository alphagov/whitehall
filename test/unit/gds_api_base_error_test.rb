require "test_helper"

class GdsApiBaseErrorTest < ActiveSupport::TestCase
  test "removes sentry_context method to avoid grouping unrelated exceptions" do
    assert_not GdsApi::BaseError.new.respond_to?(:sentry_context)
  end
end
