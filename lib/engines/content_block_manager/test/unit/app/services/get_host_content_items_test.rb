require "test_helper"

class ContentBlockManager::GetHostContentItemsTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  let(:described_class) { ContentBlockManager::GetHostContentItems }

  let(:target_content_id) { SecureRandom.uuid }

  let(:host_content_id) { SecureRandom.uuid }

  let(:response_body) do
    {
      "content_id" => SecureRandom.uuid,
      "total" => 111,
      "total_pages" => 12,
      "results" => [
        {
          "title" => "foo",
          "base_path" => "/foo",
          "document_type" => "something",
          "publishing_app" => "publisher",
          "last_edited_by_editor_id" => SecureRandom.uuid,
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

  setup do
    stub_publishing_api_has_embedded_content(content_id: target_content_id, total: 111, total_pages: 12, results: response_body["results"], order: ContentBlockManager::GetHostContentItems::DEFAULT_ORDER)
  end

  describe "#items" do
    let(:fake_api_response) do
      GdsApi::Response.new(
        stub("http_response", code: 200, body: response_body.to_json),
      )
    end
    let(:publishing_api_mock) { Minitest::Mock.new }

    it "calls the Publishing API for the content which embeds the target" do
      publishing_api_mock.expect :get_content_by_embedded_document, fake_api_response, [target_content_id, { order: ContentBlockManager::GetHostContentItems::DEFAULT_ORDER }]

      Services.stub :publishing_api, publishing_api_mock do
        document = mock("content_block_document", content_id: target_content_id)

        described_class.by_embedded_document(
          content_block_document: document,
        )

        publishing_api_mock.verify
      end
    end

    it "supports pagination" do
      publishing_api_mock.expect :get_content_by_embedded_document, fake_api_response, [target_content_id, { page: 1, order: ContentBlockManager::GetHostContentItems::DEFAULT_ORDER }]

      Services.stub :publishing_api, publishing_api_mock do
        document = mock("content_block_document", content_id: target_content_id)

        described_class.by_embedded_document(
          content_block_document: document,
          page: 1,
        )

        publishing_api_mock.verify
      end
    end

    it "supports sorting" do
      publishing_api_mock.expect :get_content_by_embedded_document, fake_api_response, [target_content_id, { order: "-abc" }]

      Services.stub :publishing_api, publishing_api_mock do
        document = mock("content_block_document", content_id: target_content_id)

        described_class.by_embedded_document(
          content_block_document: document,
          order: "-abc",
        )

        publishing_api_mock.verify
      end
    end

    it "returns GetHostContentItems" do
      document = mock("content_block_document", content_id: target_content_id)

      result = described_class.by_embedded_document(content_block_document: document)

      expected_publishing_organisation = {
        "content_id" => response_body["results"][0]["primary_publishing_organisation"]["content_id"],
        "title" => response_body["results"][0]["primary_publishing_organisation"]["title"],
        "base_path" => response_body["results"][0]["primary_publishing_organisation"]["base_path"],
      }

      assert_equal result.total, response_body["total"]
      assert_equal result.total_pages, response_body["total_pages"]

      assert_equal result[0].title, response_body["results"][0]["title"]
      assert_equal result[0].base_path, response_body["results"][0]["base_path"]
      assert_equal result[0].document_type, response_body["results"][0]["document_type"]
      assert_equal result[0].publishing_app, response_body["results"][0]["publishing_app"]
      assert_equal result[0].last_edited_by_editor_id, response_body["results"][0]["last_edited_by_editor_id"]
      assert_equal result[0].last_edited_at, Time.zone.parse(response_body["results"][0]["last_edited_at"])
      assert_equal result[0].unique_pageviews, response_body["results"][0]["unique_pageviews"]
      assert_equal result[0].instances, response_body["results"][0]["instances"]
      assert_equal result[0].host_content_id, response_body["results"][0]["host_content_id"]

      assert_equal result[0].publishing_organisation, expected_publishing_organisation
    end

    it "returns an error if the content that embeds the target can't be loaded" do
      exception = GdsApi::HTTPErrorResponse.new(
        500,
        "An internal error message",
        "error" => { "message" => "Some backend error" },
      )
      raises_exception = ->(*_args) { raise exception }

      Services.publishing_api.stub :get_content_by_embedded_document, raises_exception do
        document = mock("content_block_document", content_id: target_content_id)

        assert_raises(GdsApi::HTTPErrorResponse) do
          described_class.by_embedded_document(
            content_block_document: document,
          )
        end
      end
    end
  end
end
