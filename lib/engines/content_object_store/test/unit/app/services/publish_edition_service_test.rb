require "test_helper"

class ContentObjectStore::PublishEditionServiceTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  describe "#call" do
    let(:content_id) { "49453854-d8fd-41da-ad4c-f99dbac601c3" }
    let(:schema) { build(:content_block_schema, block_type: "content_block_type", body: { "properties" => { "foo" => "", "bar" => "" } }) }
    let(:document) { create(:content_block_document, :email_address, content_id:, title: "Some Title") }
    let(:edition) { create(:content_block_edition, document:, details: { "foo" => "Foo text", "bar" => "Bar text" }, organisation: @organisation) }

    setup do
      ContentObjectStore::ContentBlock::Schema.stubs(:find_by_block_type)
                                              .returns(schema)
      @organisation = create(:organisation)

      stub_publishing_api_has_embedded_content(content_id:, total: 0, results: [])
    end

    test "returns a ContentBlockEdition" do
      result = ContentObjectStore::PublishEditionService.new(schema).call(edition)
      assert_instance_of ContentObjectStore::ContentBlock::Edition, result
    end

    test "it publishes the Edition in Whitehall" do
      ContentObjectStore::PublishEditionService.new(schema).call(edition)

      assert_equal "published", edition.state
      assert_equal edition.id, document.live_edition_id
    end

    test "it creates an Edition in the Publishing API" do
      fake_put_content_response = GdsApi::Response.new(
        stub("http_response", code: 200, body: {}),
      )
      fake_publish_content_response = GdsApi::Response.new(
        stub("http_response", code: 200, body: {}),
      )

      publishing_api_mock = Minitest::Mock.new
      publishing_api_mock.expect :put_content, fake_put_content_response, [
        content_id,
        {
          schema_name: schema.id,
          document_type: schema.id,
          publishing_app: "whitehall",
          title: "Some Title",
          details: {
            "foo" => "Foo text",
            "bar" => "Bar text",
          },
          links: {
            primary_publishing_organisation: [@organisation.content_id],
          },
        },
      ]
      publishing_api_mock.expect :publish, fake_publish_content_response, [
        content_id,
        "major",
      ]

      fake_embedded_content_response = GdsApi::Response.new(stub("http_response",
                                                                 code: 200, body: { "content_id" => "1234abc",
                                                                                    "total" => 0,
                                                                                    "results" => [] }.to_json))

      publishing_api_mock.expect :get_content_by_embedded_document, fake_embedded_content_response, [content_id]

      Services.stub :publishing_api, publishing_api_mock do
        ContentObjectStore::PublishEditionService.new(schema).call(edition)

        publishing_api_mock.verify
        assert_equal "published", edition.state
        assert_equal edition.id, document.live_edition_id
      end
    end

    test "it queues publishing intents for host content on the Publishing API" do
      host_content =
        [
          {
            "title" => "Content title",
            "document_type" => "document",
            "base_path" => "/host-document",
            "content_id" => "1234abc",
            "publishing_app" => "example-app",
            "primary_publishing_organisation" => {
              "content_id" => "456abc",
              "title" => "Organisation",
              "base_path" => "/organisation/org",
            },
          },
        ]

      stub_publishing_api_has_embedded_content(content_id:, total: 0, results: host_content)

      ContentObjectStore::PublishIntentWorker.expects(:perform_async).with(
        "/host-document",
        "example-app",
        Time.zone.now.to_s,
      ).once

      ContentObjectStore::PublishEditionService.new(schema).call(edition)
    end

    test "if the publishing API request fails, the Whitehall ContentBlockEdition and ContentBlockDocument are rolled back" do
      exception = GdsApi::HTTPErrorResponse.new(
        422,
        "An internal error message",
        "error" => { "message" => "Some backend error" },
      )
      raises_exception = ->(*_args) { raise exception }

      assert_equal "draft", edition.state
      assert_nil document.live_edition_id

      Services.publishing_api.stub :put_content, raises_exception do
        assert_raises(GdsApi::HTTPErrorResponse) do
          ContentObjectStore::PublishEditionService.new(schema).call(edition)
        end
        assert_equal "draft", edition.state
        assert_nil document.live_edition_id
      end
    end

    test "if the publish request fails, the latest draft is discarded and the database actions are rolled back" do
      fake_put_content_response = GdsApi::Response.new(
        stub("http_response", code: 200, body: {}),
      )
      fake_discard_draft_content_response = GdsApi::Response.new(
        stub("http_response", code: 200, body: {}),
      )

      publishing_api_mock = Minitest::Mock.new
      publishing_api_mock.expect :put_content, fake_put_content_response, [
        String,
        Hash,
      ]
      publishing_api_mock.expect :discard_draft, fake_discard_draft_content_response, [
        content_id,
      ]

      exception = GdsApi::HTTPErrorResponse.new(
        422,
        "An internal error message",
        "error" => { "message" => "Some backend error" },
      )
      raises_exception = ->(*_args) { raise exception }

      Services.publishing_api.stub :publish, raises_exception do
        assert_raises(ContentObjectStore::PublishEditionService::PublishingFailureError, "Could not publish #{content_id} because: Some backend error") do
          ContentObjectStore::PublishEditionService.new(schema).call(edition)
          publishing_api_mock.verify
        end
        assert_equal "draft", edition.state
        assert_nil document.live_edition_id
      end
    end
  end
end
