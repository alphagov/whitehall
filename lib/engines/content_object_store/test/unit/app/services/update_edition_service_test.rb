require "test_helper"

class ContentObjectStore::UpdateEditionServiceTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  setup do
    @original_content_block_edition = create(:content_block_edition,
                                             document: create(:content_block_document, :email_address, content_id:),
                                             details: { "foo" => "Foo text", "bar" => "Bar text" },
                                             organisation: create(:organisation))
  end

  describe "#call" do
    let(:content_id) { "49453854-d8fd-41da-ad4c-f99dbac601c3" }
    let(:organisation) { create("organisation") }
    let(:schema) { build(:content_block_schema, block_type: "content_block_type", body: { "properties" => { "foo" => "", "bar" => "" } }) }
    let(:edition_params) do
      {
        document_attributes: {
          title: "Some Title",
          block_type: "email_address",
        }.with_indifferent_access,
        details: {
          "foo" => "Foo text",
          "bar" => "Bar text",
        },
        creator: build(:user),
        organisation_id: organisation.id.to_s,
      }
    end

    setup do
      # This UUID is created by the database so instead of loading the record
      # we stub the initial creation so we know what UUID to check for.
      ContentObjectStore::ContentBlock::Edition.any_instance.stubs(:create_random_id)
                                             .returns(content_id)

      ContentObjectStore::ContentBlock::Schema.stubs(:find_by_block_type)
                                            .returns(schema)
    end

    test "it returns the new content block edition so the controller can redirect" do
      result = ContentObjectStore::UpdateEditionService.new(schema, @original_content_block_edition)
                                                       .call(edition_params)
      assert_instance_of ContentObjectStore::ContentBlock::Edition, result
    end

    test "it does not create a new ContentBlockDocument" do
      original_count = ContentObjectStore::ContentBlock::Document.count
      ContentObjectStore::UpdateEditionService.new(schema, @original_content_block_edition)
                                              .call(edition_params)
      assert_equal original_count, ContentObjectStore::ContentBlock::Document.count
    end

    test "updates the title field on the original ContentBlockDocument" do
      result = ContentObjectStore::UpdateEditionService.new(schema, @original_content_block_edition)
                                                       .call(edition_params)
      assert_equal result.document.title, edition_params[:document_attributes][:title]
    end

    describe "when a document title isn't provided" do
      test "does not update the document" do
        edition_params.delete(:document_attributes)

        assert_no_changes -> { @original_content_block_edition.document.title } do
          ContentObjectStore::UpdateEditionService
            .new(schema, @original_content_block_edition)
            .call(edition_params)
        end
      end
    end

    describe "when no parameters are changed" do
      it "publishes a new edition with the same values as the original" do
        duplicate_edition_params = {
          document_attributes: {
            title: @original_content_block_edition.document.title,
            block_type: @original_content_block_edition.document.block_type,
          }.with_indifferent_access,
          details: @original_content_block_edition.details,
          creator: build(:user),
          organisation_id: @original_content_block_edition.lead_organisation.id.to_s,
        }

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
            title: @original_content_block_edition.document.title,
            details: @original_content_block_edition.details,
            links: {
              primary_publishing_organisation: [@original_content_block_edition.lead_organisation.content_id],
            },
          },
        ]
        publishing_api_mock.expect :publish, fake_publish_content_response, [
          content_id,
          "major",
        ]

        Services.stub :publishing_api, publishing_api_mock do
          ContentObjectStore::UpdateEditionService
            .new(schema, @original_content_block_edition)
            .call(duplicate_edition_params)

          publishing_api_mock.verify
        end
      end
    end

    describe "when no params are passed" do
      it "raises an ArgumentError" do
        assert_raises(ArgumentError) do
          ContentObjectStore::UpdateEditionService
            .new(schema, @original_content_block_edition)
            .call({})
        end
      end
    end

    describe "when params attempt to change the block type" do
      test "does not update the document" do
        second_schema = build(:content_block_schema, block_type: "postal_address")
        ContentObjectStore::ContentBlock::Schema.stubs(:find_by_block_type)
          .returns(second_schema)

        edition_params[:document_attributes][:block_type] = "postal_address"

        assert_no_changes -> { @original_content_block_edition.document.block_type } do
          ContentObjectStore::UpdateEditionService
            .new(second_schema, @original_content_block_edition)
            .call(edition_params)
        end
      end
    end

    it "updates the original ContentBlockDocument's latest_edition_id and live_edition_id to the new Edition" do
      result = ContentObjectStore::UpdateEditionService.new(schema, @original_content_block_edition)
                                                       .call(edition_params)

      @original_content_block_edition.document.reload

      assert_equal @original_content_block_edition.document.live_edition_id, result.id
      assert_equal @original_content_block_edition.document.latest_edition_id, result.id
    end

    test "it creates a new ContentBlockEdition in Whitehall" do
      original_document = ContentObjectStore::ContentBlock::Document.find_by!(content_id:)

      assert_changes -> { ContentObjectStore::ContentBlock::Edition.count }, from: 1, to: 2 do
        ContentObjectStore::UpdateEditionService
          .new(schema, @original_content_block_edition)
          .call(edition_params)
      end

      new_edition = original_document.editions.last

      assert_equal edition_params[:details], new_edition.details
    end

    test "it creates a new Edition in the Publishing API" do
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
            primary_publishing_organisation: [organisation.content_id],
          },
        },
      ]
      publishing_api_mock.expect :publish, fake_publish_content_response, [
        content_id,
        "major",
      ]

      Services.stub :publishing_api, publishing_api_mock do
        ContentObjectStore::UpdateEditionService
          .new(schema, @original_content_block_edition)
          .call(edition_params)

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
        assert_equal ContentObjectStore::ContentBlock::Document.count, 1 do
          assert_equal ContentObjectStore::ContentBlock::Edition.count, 1 do
            assert_raises(GdsApi::HTTPErrorResponse) do
              ContentObjectStore::UpdateEditionService
                .new(schema, @original_content_block_edition)
                .call(edition_params)
            end
          end
        end
      end
    end

    test "if the Whitehall creation fails, no call to the Publishing API is made" do
      exception = ArgumentError.new("Cannot find schema for block_type")
      raises_exception = ->(*_args) { raise exception }

      Services.publishing_api.expects(:put_content).never

      ContentObjectStore::ContentBlock::Edition.stub :create!, raises_exception do
        assert_raises(ArgumentError) do
          ContentObjectStore::UpdateEditionService
            .new(schema, @original_content_block_edition)
            .call({})
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
        assert_equal ContentObjectStore::ContentBlock::Document.count, 1 do
          assert_equal ContentObjectStore::ContentBlock::Edition.count, 1 do
            assert_raises(ContentObjectStore::CreateEditionService::PublishingFailureError, "Could not publish #{content_id} because: Some backend error") do
              ContentObjectStore::UpdateEditionService
                .new(schema, @original_content_block_edition)
                .call(edition_params)
            end

            publishing_api_mock.verify
          end
        end
      end
    end
  end
end
