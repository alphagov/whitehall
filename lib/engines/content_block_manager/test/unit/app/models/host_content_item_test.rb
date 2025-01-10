require "test_helper"

class ContentBlockManager::HostContentItemTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  describe ".for_document" do
    let(:described_class) { ContentBlockManager::HostContentItem }

    let(:target_content_id) { SecureRandom.uuid }

    let(:host_content_id) { SecureRandom.uuid }

    let(:last_edited_by_editor_id) { SecureRandom.uuid }

    let(:rollup) { build(:rollup) }

    let(:response_body) do
      {
        "content_id" => SecureRandom.uuid,
        "total" => 111,
        "total_pages" => 12,
        "rollup" => rollup.to_h,
        "results" => [
          {
            "title" => "foo",
            "base_path" => "/foo",
            "document_type" => "something",
            "publishing_app" => "publisher",
            "last_edited_by_editor_id" => last_edited_by_editor_id,
            "last_edited_at" => "2023-01-01T08:00:00.000Z",
            "unique_pageviews" => 123,
            "instances" => 1,
            "host_content_id" => host_content_id,
            "primary_publishing_organisation" => {
              "content_id" => SecureRandom.uuid,
              "title" => "bar",
              "base_path" => "/bar",
            },
          },
        ],
      }
    end

    let(:editor) { build(:host_content_item_editor, uid: last_edited_by_editor_id) }

    let(:fake_api_response) do
      GdsApi::Response.new(
        stub("http_response", code: 200, body: response_body.to_json),
      )
    end
    let(:publishing_api_mock) { stub("GdsApi::PublishingApi") }
    let(:document) { mock("content_block_document", content_id: target_content_id) }

    before do
      Services.expects(:publishing_api).returns(publishing_api_mock)
      ContentBlockManager::HostContentItem::Editor.stubs(:with_uuids).returns([editor])
    end

    it "calls the Publishing API for the content which embeds the target" do
      publishing_api_mock.expects(:get_host_content_for_content_id)
                         .with(target_content_id, { order: described_class::DEFAULT_ORDER })
                         .returns(fake_api_response)

      described_class.for_document(document)
    end

    it "supports pagination" do
      publishing_api_mock.expects(:get_host_content_for_content_id)
                         .with(target_content_id, { page: 1, order: described_class::DEFAULT_ORDER })
                         .returns(fake_api_response)

      described_class.for_document(document, page: 1)
    end

    it "supports sorting" do
      publishing_api_mock.expects(:get_host_content_for_content_id)
                         .with(target_content_id, { order: "-abc" })
                         .returns(fake_api_response)

      described_class.for_document(document, order: "-abc")
    end

    it "calls the editor finder with the correct argument" do
      publishing_api_mock.expects(:get_host_content_for_content_id).returns(fake_api_response)
      ContentBlockManager::HostContentItem::Editor.expects(:with_uuids).with([last_edited_by_editor_id]).returns([editor])

      described_class.for_document(document)
    end

    it "returns items" do
      publishing_api_mock.expects(:get_host_content_for_content_id).returns(fake_api_response)

      result = described_class.for_document(document)

      expected_publishing_organisation = {
        "content_id" => response_body["results"][0]["primary_publishing_organisation"]["content_id"],
        "title" => response_body["results"][0]["primary_publishing_organisation"]["title"],
        "base_path" => response_body["results"][0]["primary_publishing_organisation"]["base_path"],
      }

      assert_equal result.total, response_body["total"]
      assert_equal result.total_pages, response_body["total_pages"]

      assert_equal result.rollup.views, rollup.views
      assert_equal result.rollup.locations, rollup.locations
      assert_equal result.rollup.instances, rollup.instances
      assert_equal result.rollup.organisations, rollup.organisations

      assert_equal result[0].title, response_body["results"][0]["title"]
      assert_equal result[0].base_path, response_body["results"][0]["base_path"]
      assert_equal result[0].document_type, response_body["results"][0]["document_type"]
      assert_equal result[0].publishing_app, response_body["results"][0]["publishing_app"]
      assert_equal result[0].last_edited_by_editor, editor
      assert_equal result[0].last_edited_at, Time.zone.parse(response_body["results"][0]["last_edited_at"])
      assert_equal result[0].unique_pageviews, response_body["results"][0]["unique_pageviews"]
      assert_equal result[0].instances, response_body["results"][0]["instances"]
      assert_equal result[0].host_content_id, response_body["results"][0]["host_content_id"]

      assert_equal result[0].publishing_organisation, expected_publishing_organisation
    end

    describe "when last_edited_by_editor_id is nil" do
      let(:last_edited_by_editor_id) { nil }

      it "returns nil for last_edited_by_editor" do
        publishing_api_mock.expects(:get_host_content_for_content_id).returns(fake_api_response)

        ContentBlockManager::HostContentItem::Editor.expects(:with_uuids).never

        result = described_class.for_document(document)

        assert_equal result[0].last_edited_by_editor, nil
      end
    end

    it "returns an error if the content that embeds the target can't be loaded" do
      publishing_api_mock.expects(:get_host_content_for_content_id).raises(
        GdsApi::HTTPErrorResponse.new(
          500,
          "An internal error message",
          "error" => { "message" => "Some backend error" },
        ),
      )

      assert_raises(GdsApi::HTTPErrorResponse) do
        described_class.for_document(document)
      end
    end
  end

  describe "#last_edited_at" do
    it "translates to a TimeWithZone object" do
      last_edited_at = 4.days.ago
      host_content_item = build(:host_content_item, last_edited_at: last_edited_at.to_s)

      assert host_content_item.last_edited_at.is_a?(ActiveSupport::TimeWithZone)
      assert_equal host_content_item.last_edited_at, last_edited_at
    end
  end
end
