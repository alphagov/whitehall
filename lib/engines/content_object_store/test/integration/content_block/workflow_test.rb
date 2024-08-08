require "test_helper"
require "capybara/rails"

class ContentObjectStore::ContentBlock::WorkflowTest < ActionDispatch::IntegrationTest
  include Capybara::DSL

  setup do
    login_as_admin
    @content_id = "49453854-d8fd-41da-ad4c-f99dbac601c3"

    stub_request_for_schema("email_address")

    feature_flags.switch!(:content_object_store, true)
  end

  test "#publish posts the new edition to the Publishing API and marks edition as published" do
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
      post content_object_store.publish_content_object_store_content_block_edition_path(id: edition.id), params: {
        id: edition.id,
      }
      publishing_api_mock.verify
      assert_equal "published", edition.reload.state
    end
  end
end

def stub_request_for_schema(block_type)
  schema = stub(id: "content_block_type", fields: %w[foo bar], name: "schema", body: {}, block_type:)
  ContentObjectStore::ContentBlock::Schema.stubs(:find_by_block_type).with(block_type).returns(schema)
end
