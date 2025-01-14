require "test_helper"

class ContentBlockManager::SignonUserTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  describe ".with_uuids" do
    let(:signon_api_stub) { stub }

    before do
      Services.expects(:signon_api_client).returns(signon_api_stub)
    end

    it "returns an empty array when no UUIDs are provided" do
      signon_api_stub.expects(:get_users).with(uuids: []).returns([])

      result = ContentBlockManager::SignonUser.with_uuids([])

      assert_equal [], result
    end

    it "fetches users for a given list of UUIDs" do
      uuids = [SecureRandom.uuid, SecureRandom.uuid]
      api_response = [
        {
          "uid" => uuids[0],
          "name" => "Someone",
          "email" => "someone@example.com",
        },
        {
          "uid" => uuids[1],
          "name" => "Someone else",
          "email" => "someoneelse@example.com",
          "organisation" => {
            "content_id" => SecureRandom.uuid,
            "name" => "Organisation",
            "slug" => "organisation",
          },
        },
      ]
      signon_api_stub.expects(:get_users).with(uuids:).returns(api_response)

      result = ContentBlockManager::SignonUser.with_uuids(uuids)

      assert_equal result[0].uid, api_response[0]["uid"]
      assert_equal result[0].name, api_response[0]["name"]
      assert_equal result[0].email, api_response[0]["email"]
      assert_nil result[0].organisation

      assert_equal result[1].uid, api_response[1]["uid"]
      assert_equal result[1].name, api_response[1]["name"]
      assert_equal result[1].email, api_response[1]["email"]
      assert_equal result[1].organisation.content_id, api_response[1]["organisation"]["content_id"]
      assert_equal result[1].organisation.name, api_response[1]["organisation"]["name"]
      assert_equal result[1].organisation.slug, api_response[1]["organisation"]["slug"]
    end
  end
end
