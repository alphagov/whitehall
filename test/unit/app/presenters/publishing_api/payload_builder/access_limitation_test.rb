require "test_helper"

module PublishingApi
  module PayloadBuilder
    class AccessLimitationTest < ActiveSupport::TestCase
      def build_item(overrides = {})
        defaults = {
          access_limited?: true,
          publicly_visible?: false,
          access_limiting_individuals?: false,
        }
        stub(defaults.merge(overrides))
      end

      def access_limited_result(item)
        AccessLimitation.for(item)[:access_limited]
      end

      test "returns organisation content ids for organisation access limiting" do
        organisation = create(:organisation)

        item = build_item(
          organisations: [organisation],
          access_limiting_individuals?: false,
        )

        assert_equal(
          { organisations: [organisation.content_id] },
          access_limited_result(item),
        )
      end

      test "returns user uids for individual access limiting" do
        user = create(:user, email: "user@example.com")

        item = build_item(
          access_limiting_individuals?: true,
          access_limiting_individuals: stub(pluck: [user.email]),
        )

        assert_equal(
          { users: [user.uid] },
          access_limited_result(item),
        )
      end

      test "returns empty hash when named users resolve to no UIDs" do
        item = build_item(
          access_limiting_individuals?: true,
          access_limiting_individuals: stub(pluck: ["unknown@example.com"]),
        )

        assert_equal({}, AccessLimitation.for(item))
      end

      test "returns empty hash if not access limited" do
        item = build_item(access_limited?: false)

        assert_equal({}, AccessLimitation.for(item))
      end

      test "returns empty hash if publicly visible" do
        item = build_item(publicly_visible?: true)

        assert_equal({}, AccessLimitation.for(item))
      end

      test "returns empty hash if publicly visible and not access limited" do
        item = build_item(
          access_limited?: false,
          publicly_visible?: true,
        )

        assert_equal({}, AccessLimitation.for(item))
      end
    end
  end
end
