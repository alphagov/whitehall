require "test_helper"

class ContentObjectStore::GetHostContentItemsTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  let(:described_class) { ContentObjectStore::GetHostContentItems }

  let(:target_content_id) { SecureRandom.uuid }
  let(:expected_url) { "https://publishing-api.test.gov.uk/v2/content/#{target_content_id}/embedded" }

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
    stub_request(:get, expected_url)
      .to_return(body: response_body.to_json, status: 200)
  end

  describe "#items" do
    it "calls the Publishing API for the embedded content" do
      document = mock("content_block_document", content_id: target_content_id)

      described_class.by_embedded_document(
        content_block_document: document,
      )

      assert_requested :get, expected_url, times: 1
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

    it "returns an empty array if the request fails" do
      document = mock("content_block_document", content_id: target_content_id)

      stub_request(:get, expected_url)
        .to_return(body: "", status: 500)

      result = described_class.by_embedded_document(content_block_document: document)

      assert_equal result, []
    end

    it "depends on Plek to set the right hostname" do
      document = mock("content_block_document", content_id: target_content_id)

      plek_domain = "https://foo.dev.gov.uk"
      Plek.stubs(:find).with("publishing-api").returns(plek_domain)

      stub_request(:get, %r{\A#{plek_domain}/v2/content/#{target_content_id}/embedded})
        .to_return(body: response_body.to_json, status: 200)

      described_class.by_embedded_document(
        content_block_document: document,
      )

      assert_requested(:get, %r{\A#{plek_domain}/v2/content/#{target_content_id}/embedded})
    end
  end
end
