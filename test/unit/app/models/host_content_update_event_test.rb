require "test_helper"

class HostContentUpdateEventTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  let(:document) { create(:document) }
  let(:user) { create(:user) }

  describe ".all_for_date_window" do
    it "returns all HostContentUpdateJobs" do
      from = Time.zone.now - 2.months
      to = Time.zone.now - 1.month

      Services.publishing_api.expects(:get_events_for_content_id).with(
        document.content_id, {
          action: "HostContentUpdateJob",
          from:,
          to:,
        }
      ).returns(
        [
          {
            "id" => 1593,
            "action" => "HostContentUpdateJob",
            "created_at" => "2024-01-01T00:00:00.000Z",
            "updated_at" => "2024-01-01T00:00:00.000Z",
            "request_id" => SecureRandom.uuid,
            "content_id" => document.content_id,
            "payload" => {
              "title" => "Host content updated by content block update",
              "locale" => "en",
              "content_id" => document.content_id,
              "source_block" => {
                "title" => "An exciting piece of content",
                "content_id" => "ef224ae6-7a81-4c59-830b-e9884fe57ec8",
                "updated_by_user_uid" => user.uid,
              },
            },
          },
          {
            "id" => 1593,
            "action" => "HostContentUpdateJob",
            "user_uid" => SecureRandom.uuid,
            "created_at" => "2023-12-01T00:00:00.000Z",
            "updated_at" => "2023-12-01T00:00:00.000Z",
            "request_id" => SecureRandom.uuid,
            "content_id" => document.content_id,
            "payload" => {
              "title" => "Host content updated by content block update",
              "locale" => "en",
              "content_id" => document.content_id,
              "source_block" => {
                "title" => "Another exciting piece of content",
                "content_id" => "5c5520ce-6677-4a76-bd6e-4515f46a804e",
                "updated_by_user_uid" => nil,
              },
            },
          },
        ],
      )

      result = HostContentUpdateEvent.all_for_date_window(document:, from:, to:)

      assert_equal result.count, 2

      assert_equal result.first.author, user
      assert_equal result.first.created_at, Time.zone.parse("2024-01-01T00:00:00.000Z")
      assert_equal result.first.content_id, "ef224ae6-7a81-4c59-830b-e9884fe57ec8"
      assert_equal result.first.content_title, "An exciting piece of content"

      assert_nil result.second.author
      assert_equal result.second.created_at, Time.zone.parse("2023-12-01T00:00:00.000Z")
      assert_equal result.second.content_id, "5c5520ce-6677-4a76-bd6e-4515f46a804e"
      assert_equal result.second.content_title, "Another exciting piece of content"
    end
  end
end
