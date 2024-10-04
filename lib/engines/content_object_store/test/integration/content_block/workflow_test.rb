require "test_helper"
require "capybara/rails"

class ContentObjectStore::ContentBlock::WorkflowTest < ActionDispatch::IntegrationTest
  include Capybara::DSL
  extend Minitest::Spec::DSL
  include SidekiqTestHelpers

  setup do
    login_as_admin
    @content_id = "49453854-d8fd-41da-ad4c-f99dbac601c3"

    stub_request_for_schema("email_address")

    feature_flags.switch!(:content_object_store, true)

    stub_publishing_api_has_embedded_content(content_id: @content_id, total: 0, results: [])
  end

  describe "#create" do
    it "posts the new edition to the Publishing API and marks edition as published" do
      details = {
        foo: "Foo text",
        bar: "Bar text",
      }

      organisation = create(:organisation)
      document = create(:content_block_document, :email_address, content_id: @content_id, title: "Some Title")
      edition = create(:content_block_edition, document:, details:, organisation:)

      fake_put_content_response = GdsApi::Response.new(
        stub("http_response", code: 200, body: {}),
      )
      fake_publish_content_response = GdsApi::Response.new(
        stub("http_response", code: 200, body: {}),
      )

      publishing_api_mock = Minitest::Mock.new
      publishing_api_mock.expect :put_content, fake_put_content_response, [
        @content_id,
        {
          schema_name: "content_block_type",
          document_type: "content_block_type",
          publishing_app: "whitehall",
          title: "Some Title",
          details: {
            "foo" => "Foo text",
            "bar" => "Bar text",
          },
          links: {
            primary_publishing_organisation: [organisation.content_id],
          },
        },
      ]
      publishing_api_mock.expect :publish, fake_publish_content_response, [
        @content_id,
        "major",
      ]

      Services.stub :publishing_api, publishing_api_mock do
        post content_object_store.publish_content_object_store_content_block_edition_path(id: edition.id)
        publishing_api_mock.verify
        document = ContentObjectStore::ContentBlock::Document.find_by!(content_id: @content_id)
        new_edition = ContentObjectStore::ContentBlock::Edition.find(document.live_edition_id)

        assert_equal document.live_edition_id, document.latest_edition_id

        assert_equal "published", new_edition.state
      end
    end
  end
end

def stub_request_for_schema(block_type)
  schema = stub(id: "content_block_type", fields: %w[foo bar], name: "schema", body: {}, block_type:)
  ContentObjectStore::ContentBlock::Schema.stubs(:find_by_block_type).with(block_type).returns(schema)
end

def update_params(edition_id:, organisation_id:)
  {
    id: edition_id,
    schedule_publishing: "schedule",
    scheduled_at: {
      "scheduled_publication(3i)": "2",
      "scheduled_publication(2i)": "9",
      "scheduled_publication(1i)": "2024",
      "scheduled_publication(4i)": "10",
      "scheduled_publication(5i)": "05",
    },
    "content_block/edition": {
      creator: "1",
      details: { foo: "newnew@example.com", bar: "edited" },
      document_attributes: { block_type: "email_address", title: "Another email" },
      organisation_id:,
    },
  }
end
