require "test_helper"

class ContentObjectStore::CreateEditionServiceTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  setup do
    @content_id = "49453854-d8fd-41da-ad4c-f99dbac601c3"
    ContentObjectStore::ContentBlockSchema.stubs(:valid_schemas).returns(%w[block_type])
  end

  describe "#call" do
    test "it creates a ContentBlockEdition in Whitehall" do
      schema = stub(id: "content_block_type", fields: %w[foo bar], name: "schema")
      edition_params = {
        document_title: "Some Title",
        block_type: "block_type",
        details: {
          "foo" => "Foo text",
          "bar" => "Bar text",
        },
      }

      # This UUID is created by the database so instead of loading the record
      # we stub the initial creation so we know what UUID to check for.
      ContentObjectStore::ContentBlockEdition.any_instance.stubs(:create_random_id)
        .returns(@content_id)

      assert_changes -> { ContentObjectStore::ContentBlockDocument.count }, from: 0, to: 1 do
        assert_changes -> { ContentObjectStore::ContentBlockEdition.count }, from: 0, to: 1 do
          ContentObjectStore::CreateEditionService.new(schema, edition_params).call
        end
      end

      new_document = ContentObjectStore::ContentBlockDocument.find_by!(content_id: @content_id)
      new_edition = new_document.content_block_editions.first
      assert_equal edition_params[:document_title], new_document.title
      assert_equal edition_params[:block_type], new_document.block_type
      assert_equal edition_params[:details], new_edition.details
      assert_equal new_edition.content_block_document_id, new_document.id
    end

    test "it creates an Edition and Document in the Publishing API" do
      schema = stub(id: "content_block_type", fields: %w[foo bar], name: "schema")
      edition_params = {
        document_title: "Some Title",
        block_type: "block_type",
        details: {
          "foo" => "Foo text",
          "bar" => "Bar text",
        },
      }
      fake_put_content_response = GdsApi::Response.new(
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

      Services.stub :publishing_api, publishing_api_mock do
        ContentObjectStore::CreateEditionService.new(schema, edition_params).call

        publishing_api_mock.verify
      end
    end

    test "if the publishing API request fails, the Whitehall ContentBlockEdition and ContentBlockDocument are rolled back" do
      schema = stub(id: "content_block_type", fields: %w[foo bar], name: "schema")
      edition_params = {
        document_title: "Some Title",
        block_type: "block_type",
        details: {
          "foo" => "Foo text",
          "bar" => "Bar text",
        },
      }

      # This UUID is created by the database so instead of loading the record
      # we stub the initial creation so we know what UUID to check for.
      ContentObjectStore::ContentBlockEdition.any_instance.stubs(:create_random_id)
        .returns(@content_id)

      exception = GdsApi::HTTPUnprocessableEntity.new(
        422,
        "An internal error message",
        "error" => { "message" => "Some backend error" },
      )
      raises_exception = ->(*_args) { raise exception }

      Services.publishing_api.stub :put_content, raises_exception do
        assert_equal ContentObjectStore::ContentBlockDocument.count, 0 do
          assert_equal ContentObjectStore::ContentBlockEdition.count, 0 do
            assert_raises(GdsApi::HTTPUnprocessableEntity) do
              ContentObjectStore::CreateEditionService.new(schema, edition_params).call
            end
          end
        end
      end
    end

    test "if the Whitehall creation fails, no call to the Publishing API is made" do
      schema = stub(id: "content_block_type", fields: %w[foo bar], name: "schema")

      exception = ArgumentError.new("Cannot find schema for block_type")
      raises_exception = ->(*_args) { raise exception }

      Services.publishing_api.expects(:put_content).never

      ContentObjectStore::ContentBlockEdition.stub :create!, raises_exception do
        assert_raises(ArgumentError) do
          ContentObjectStore::CreateEditionService.new(schema, {}).call
        end
      end
    end
  end
end
