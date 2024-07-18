require "test_helper"
require "capybara/rails"

class ContentBlockEditionsTest < ActionDispatch::IntegrationTest
  include Capybara::DSL

  setup do
    login_as_admin
    @content_id = "49453854-d8fd-41da-ad4c-f99dbac601c3"

    stub_request_for_schema("email_address")
  end

  test "#index returns all Content Block Editions" do
    content_block_document = create(:content_block_document, :email_address)
    create(
      :content_block_edition,
      :email_address,
      details: { "email_address" => "example@example.com" },
      content_block_document_id: content_block_document.id,
    )
    visit content_object_store.content_object_store_content_block_editions_path
    assert_text "example@example.com"
  end

  test "#create creates a new content block with params generated by the schema" do
    title = "Some Title"
    block_type = "email_address"
    details = {
      "foo" => "Foo text",
      "bar" => "Bar text",
    }

    # This UUID is created by the database so instead of loading the record
    # we stub the initial creation so we know what UUID to check for.
    ContentObjectStore::ContentBlockEdition.any_instance.stubs(:create_random_id)
      .returns(@content_id)

    assert_changes -> { ContentObjectStore::ContentBlockDocument.count }, from: 0, to: 1 do
      assert_changes -> { ContentObjectStore::ContentBlockEdition.count }, from: 0, to: 1 do
        post content_object_store.content_object_store_content_block_editions_path, params: {
          something: "else",
          content_object_store_content_block_edition: {
            title:,
            block_type:,
            details:,
          },
        }
      end
    end

    new_document = ContentObjectStore::ContentBlockDocument.find_by!(content_id: @content_id)
    new_edition = new_document.content_block_editions.first
    assert_equal title, new_document.title
    assert_equal block_type, new_document.block_type
    assert_equal details, new_edition.details
    assert_equal new_edition.content_block_document_id, new_document.id
  end

  test "#create posts the new edition to the Publishing API" do
    title = "Some Title"
    block_type = "email_address"
    details = {
      foo: "Foo text",
      bar: "Bar text",
    }
    fake_put_content_response = GdsApi::Response.new(
      stub("http_response", code: 200, body: {}),
    )
    fake_publish_content_response = GdsApi::Response.new(
      stub("http_response", code: 200, body: {}),
    )

    # This UUID is created by the database so instead of loading the record
    # we stub the initial creation so we know what UUID to check for.
    ContentObjectStore::ContentBlockEdition.any_instance.stubs(:create_random_id)
      .returns(@content_id)

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
      },
    ]
    publishing_api_mock.expect :publish, fake_publish_content_response, [
      @content_id,
      "major",
    ]

    Services.stub :publishing_api, publishing_api_mock do
      post content_object_store.content_object_store_content_block_editions_path, params: {
        content_object_store_content_block_edition: {
          title:,
          block_type:,
          details:,
        },
      }
      publishing_api_mock.verify
    end
  end

  test "#create should render the template when a validation error occurs" do
    edition = build(:content_block_edition)
    err = ActiveRecord::RecordInvalid.new(edition)
    ContentObjectStore::CreateEditionService.any_instance
                                            .stubs(:call)
                                            .raises(err)

    post content_object_store.content_object_store_content_block_editions_path, params: {
      content_object_store_content_block_edition: {
        block_type: "email_address",
      },
    }

    assert_template :new
    assert_equal edition, assigns(:content_block_edition)
  end
end

def stub_request_for_schema(block_type)
  schema = stub(id: "content_block_type", fields: %w[foo bar], name: "schema", body: {}, block_type:)
  ContentObjectStore::ContentBlockSchema.stubs(:find_by_block_type).with(block_type).returns(schema)
end
