require "test_helper"

class ContentBlockManager::GetHostContentItemsTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  let(:described_class) { ContentBlockManager::GetHostContentItems }

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
          "publishing_app" => "publisher",
          "last_edited_by_editor_id" => SecureRandom.uuid,
          "last_edited_at" => "2023-01-01T08:00:00.000Z",
          "primary_publishing_organisation" => {
            "content_id" => SecureRandom.uuid,
            "title" => "bar",
            "base_path" => "/bar",
          },
        },
      ],
    }
  end

  let(:document) { mock("content_block_document", content_id: target_content_id) }

  setup do
    stub_publishing_api_has_embedded_content(content_id: target_content_id, total: 1, results: response_body["results"])
    ContentBlockManager::PageViewsService.stubs(:new).with(paths: ["/foo"]).returns(stub(call: []))
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
      result = described_class.by_embedded_document(content_block_document: document)

      expected_publishing_organisation = {
        "content_id" => response_body["results"][0]["primary_publishing_organisation"]["content_id"],
        "title" => response_body["results"][0]["primary_publishing_organisation"]["title"],
        "base_path" => response_body["results"][0]["primary_publishing_organisation"]["base_path"],
      }

      assert_equal result[0].title, response_body["results"][0]["title"]
      assert_equal result[0].base_path, response_body["results"][0]["base_path"]
      assert_equal result[0].document_type, response_body["results"][0]["document_type"]
      assert_equal result[0].publishing_app, response_body["results"][0]["publishing_app"]
      assert_equal result[0].last_edited_by_editor_id, response_body["results"][0]["last_edited_by_editor_id"]
      assert_equal result[0].last_edited_at, Time.zone.parse(response_body["results"][0]["last_edited_at"])
      assert_equal result[0].page_views, "0"

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
        assert_raises(GdsApi::HTTPErrorResponse) do
          described_class.by_embedded_document(
            content_block_document: document,
          )
        end
      end
    end

    context "when PageViewsService has data for a page" do
      let(:pageviews) do
        [
          ContentBlockManager::PageView.new(path: "/foo", page_views: "123"),
        ]
      end
      setup do
        ContentBlockManager::PageViewsService.stubs(:new).with(paths: ["/foo"]).returns(stub(call: pageviews))
      end

      it "returns the correct pageviews" do
        result = described_class.by_embedded_document(content_block_document: document)

        assert_equal result[0].page_views, "123"
      end
    end
  end
end
