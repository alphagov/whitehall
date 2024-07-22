require "test_helper"

class ContentObjectStore::CreateEditionServiceTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  describe "#call" do
    let(:content_id) { "49453854-d8fd-41da-ad4c-f99dbac601c3" }
    let(:schema) { build(:content_block_schema, block_type: "content_block_type", body: { "properties" => { "foo" => "", "bar" => "" } }) }
    let(:edition_params) do
      {
        content_block_document_attributes: {
          title: "Some Title",
          block_type: "email_address",
        }.with_indifferent_access,
        details: {
          "foo" => "Foo text",
          "bar" => "Bar text",
        },
        creator: build(:user),
      }
    end

    setup do
      # This UUID is created by the database so instead of loading the record
      # we stub the initial creation so we know what UUID to check for.
      ContentObjectStore::ContentBlockEdition.any_instance.stubs(:create_random_id)
                                             .returns(content_id)

      ContentObjectStore::ContentBlockSchema.stubs(:find_by_block_type)
                                            .returns(schema)
    end

    test "it creates a ContentBlockEdition in Whitehall" do
      assert_changes -> { ContentObjectStore::ContentBlockDocument.count }, from: 0, to: 1 do
        assert_changes -> { ContentObjectStore::ContentBlockEdition.count }, from: 0, to: 1 do
          ContentObjectStore::CreateEditionService.new(schema).call(edition_params)
        end
      end

      new_document = ContentObjectStore::ContentBlockDocument.find_by!(content_id:)
      new_edition = new_document.content_block_editions.first

      assert_equal edition_params[:content_block_document_attributes][:title], new_document.title
      assert_equal edition_params[:content_block_document_attributes][:block_type], new_document.block_type
      assert_equal edition_params[:details], new_edition.details
      assert_equal new_edition.content_block_document_id, new_document.id

      assert_equal new_document.live_edition_id, new_edition.id
      assert_equal new_document.latest_edition_id, new_edition.id
    end

    test "it creates an Edition and Document in the Publishing API" do
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
        },
      ]
      publishing_api_mock.expect :publish, fake_publish_content_response, [
        content_id,
        "major",
      ]

      Services.stub :publishing_api, publishing_api_mock do
        ContentObjectStore::CreateEditionService.new(schema).call(edition_params)

        publishing_api_mock.verify
      end
    end

    test "if the publishing API request fails, the Whitehall ContentBlockEdition and ContentBlockDocument are rolled back" do
      exception = GdsApi::HTTPErrorResponse.new(
        422,
        "An internal error message",
        "error" => { "message" => "Some backend error" },
      )
      raises_exception = ->(*_args) { raise exception }

      Services.publishing_api.stub :put_content, raises_exception do
        assert_equal ContentObjectStore::ContentBlockDocument.count, 0 do
          assert_equal ContentObjectStore::ContentBlockEdition.count, 0 do
            assert_raises(GdsApi::HTTPErrorResponse) do
              ContentObjectStore::CreateEditionService.new(schema).call(edition_params)
            end
          end
        end
      end
    end

    test "if the Whitehall creation fails, no call to the Publishing API is made" do
      exception = ArgumentError.new("Cannot find schema for block_type")
      raises_exception = ->(*_args) { raise exception }

      Services.publishing_api.expects(:put_content).never

      ContentObjectStore::ContentBlockEdition.stub :create!, raises_exception do
        assert_raises(ArgumentError) do
          ContentObjectStore::CreateEditionService.new(schema).call(nil, {})
        end
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
        assert_equal ContentObjectStore::ContentBlockDocument.count, 0 do
          assert_equal ContentObjectStore::ContentBlockEdition.count, 0 do
            assert_raises(ContentObjectStore::CreateEditionService::PublishingFailureError, "Could not publish #{content_id} because: Some backend error") do
              ContentObjectStore::CreateEditionService.new(schema).call(edition_params)
            end

            publishing_api_mock.verify
          end
        end
      end
    end
  end
end
