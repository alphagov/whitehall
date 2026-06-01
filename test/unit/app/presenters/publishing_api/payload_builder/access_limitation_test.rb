require "test_helper"

module PublishingApi
  module PayloadBuilder
    class AccessLimitationTest < ActiveSupport::TestCase
      def build_item(overrides = {})
        defaults = {
          access_limited?: true,
          publicly_visible?: false,
          named_users?: false,
        }

        stub(defaults.merge(overrides))
      end

      def stub_signon(uid:)
        response = uid ? { "uid" => uid } : nil

        Services.stubs(:signon_api_client).returns(
          stub(user_by_email: response),
        )
      end

      def access_limited_result(item)
        AccessLimitation.for(item)[:access_limited]
      end

      test "returns access limitation data for the item" do
        organisation = create(:organisation)

        item = build_item(
          organisations: [organisation],
          organisations?: true,
        )

        assert_equal(
          { organisations: [organisation.content_id] },
          access_limited_result(item),
        )
      end

      test "returns only organisations when access limited by organisation" do
        org1 = create(:organisation)
        org2 = create(:organisation)

        item = build_item(
          organisations: [org1, org2],
          organisations?: true,
        )

        result = access_limited_result(item)

        assert_equal(
          [org1.content_id, org2.content_id].sort,
          result[:organisations].sort,
        )

        assert_nil result[:users]
      end

      test "returns user uids for named users" do
        item = build_item(
          named_users?: true,
          edition_user_accesses: stub(pluck: ["user@example.com"]),
        )

        stub_signon(uid: "uid-1")

        assert_equal(
          { users: %w[uid-1] },
          access_limited_result(item),
        )
      end

      test "returns empty hash when named users resolve to no UIDs" do
        item = build_item(
          named_users?: true,
          edition_user_accesses: stub(pluck: ["unknown@example.com"]),
        )

        stub_signon(uid: nil)

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
