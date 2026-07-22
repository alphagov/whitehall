require "test_helper"

module PublishingApi
  module PayloadBuilder
    class AccessLimitationTest < ActiveSupport::TestCase
      def build_item(overrides = {})
        defaults = {
          access_limited?: true,
          publicly_visible?: false,
        }
        stub(defaults.merge(overrides))
      end

      def access_limited_result(item)
        AccessLimitation.for(item)[:access_limited]
      end

      test "returns organisation content ids for organisation access limiting, when flags are off" do
        @feature_flags.switch!(:access_limiting_organisations_ui, false)
        organisation = create(:organisation)

        item = build_item(
          access_limiting_organisations?: true,
          access_limiting_individuals?: false,
          organisations: [organisation],
        )

        assert_equal(
          { organisations: [organisation.content_id] },
          access_limited_result(item),
        )
      end

      test "falls back to organisation content ids for a legacy organisation-limited edition when only the individuals flag is on" do
        @feature_flags.switch!(:access_limiting_organisations_ui, false)
        @feature_flags.switch!(:access_limiting_individuals_ui, true)
        organisation = create(:organisation)

        item = build_item(
          access_limiting_organisations?: true,
          access_limiting_individuals?: false,
          organisations: [organisation],
        )

        assert_equal(
          { organisations: [organisation.content_id] },
          access_limited_result(item),
        )
      end

      test "it returns access limiting organisations if access limiting is set to 'organisations', when feature flag is on" do
        @feature_flags.switch!(:access_limiting_organisations_ui, true)
        organisation = create(:organisation)
        item = build_item(
          access_limiting_organisations?: true,
          access_limiting_organisations: [organisation],
        )

        assert_equal(
          { organisations: [organisation.content_id] },
          access_limited_result(item),
        )
      end

      test "it returns an empty hash if access limiting is set to 'none', when feature flag is on" do
        @feature_flags.switch!(:access_limiting_organisations_ui, true)

        item = build_item(
          access_limited?: false,
          access_limiting_organisations?: false,
        )

        assert_equal({}, AccessLimitation.for(item))
      end

      test "returns user uids for individual access limiting, when flag is on" do
        @feature_flags.switch!(:access_limiting_individuals_ui, true)

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

      test "returns empty hash when named users resolve to no UIDs, when flag is on" do
        @feature_flags.switch!(:access_limiting_individuals_ui, true)

        item = build_item(
          access_limiting_individuals?: true,
          access_limiting_individuals: stub(pluck: ["unknown@example.com"]),
        )

        assert_equal({}, access_limited_result(item))
      end

      test "returns empty hash if not access limited" do
        item = build_item(access_limited?: false, publicly_visible?: false)

        assert_equal({}, AccessLimitation.for(item))
      end

      test "returns empty hash if publicly visible" do
        item = build_item(publicly_visible?: true)

        assert_equal({}, AccessLimitation.for(item))
      end

      test "returns empty hash if publicly visible and not access limited" do
        item = build_item(access_limited?: false, publicly_visible?: true)

        assert_equal({}, AccessLimitation.for(item))
      end
    end
  end
end
