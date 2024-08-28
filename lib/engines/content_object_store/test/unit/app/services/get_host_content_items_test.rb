require "test_helper"

class ContentObjectStore::GetHostContentItemsTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  let(:described_class) { ContentObjectStore::GetHostContentItems }

  let(:target_content_id) { SecureRandom.uuid }

  let(:response_body) do
    {
      "content_id" => SecureRandom.uuid,
      "total" => 1,
      "results" => [
        {
          "title" => "foo",
          "base_path" => "/foo",
          "document_type" => "something",
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
    stub_publishing_api_has_embedded_content(content_id: target_content_id, total: 1, results: response_body["results"])
  end

  describe "#items" do
    it "calls the Publishing API for the content which embeds the target" do
      fake_api_response = GdsApi::Response.new(
        stub("http_response", code: 200, body: response_body.to_json),
      )
      publishing_api_mock = Minitest::Mock.new
      publishing_api_mock.expect :get_content_by_embedded_document, fake_api_response, [target_content_id]

      Services.stub :publishing_api, publishing_api_mock do
        document = mock("content_block_document", content_id: target_content_id)

        described_class.by_embedded_document(
          content_block_document: document,
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

      assert_equal result[0].title, response_body["results"][0]["title"]
      assert_equal result[0].base_path, response_body["results"][0]["base_path"]
      assert_equal result[0].document_type, response_body["results"][0]["document_type"]
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
