require "test_helper"

class ContentObjectStore::UpdateEditionServiceTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  setup do
    @original_content_block_edition = create(:content_block_edition,
                                             document: create(:content_block_document, :email_address, content_id:),
                                             details: { "foo" => "Foo text", "bar" => "Bar text" },
                                             organisation: create(:organisation))

    stub_publishing_api_has_embedded_content(content_id:, total: 0, results: [])
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
                                                       .object
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
                                                       .object
      assert_equal result.document.title, edition_params[:document_attributes][:title]
    end

    test "raises an error when an unknown change dispatcher is received" do
      unknown_change_dispatcher = stub("unknown_change_dispatcher")

      assert_raises(ArgumentError) do
        ContentObjectStore::UpdateEditionService.new(schema, @original_content_block_edition, unknown_change_dispatcher)
                                              .call({})
      end
    end

    test "it will always dequeue any old scheduleding jobs" do
      ContentObjectStore::SchedulePublishingWorker.expects(:dequeue).with(@original_content_block_edition)
      ContentObjectStore::UpdateEditionService.new(schema, @original_content_block_edition)
                                              .call(edition_params)
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

        fake_embedded_content_response = GdsApi::Response.new(stub("http_response",
                                                                   code: 200, body: { "content_id" => "1234abc",
                                                                                      "total" => 0,
                                                                                      "results" => [] }.to_json))

        publishing_api_mock.expect :get_content_by_embedded_document, fake_embedded_content_response, [content_id]

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
          result = ContentObjectStore::UpdateEditionService
              .new(schema, @original_content_block_edition)
              .call({})
          assert_equal result.success?, false
          assert_equal result.message, "Edition params must be provided"
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
                                                       .object

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

      fake_embedded_content_response = GdsApi::Response.new(stub("http_response",
                                                                 code: 200, body: { "content_id" => "1234abc",
                                                                                    "total" => 0,
                                                                                    "results" => [] }.to_json))

      publishing_api_mock.expect :get_content_by_embedded_document, fake_embedded_content_response, [content_id]

      Services.stub :publishing_api, publishing_api_mock do
        ContentObjectStore::UpdateEditionService
          .new(schema, @original_content_block_edition)
          .call(edition_params)

        publishing_api_mock.verify
      end
    end

    test "it queues publishing intents for dependent content" do
      dependent_content =
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

      stub_publishing_api_has_embedded_content(content_id:, total: 0, results: dependent_content)

      ContentObjectStore::PublishIntentWorker.expects(:perform_async).with(
        "/host-document",
        "example-app",
        Time.zone.now.to_s,
      ).once

      ContentObjectStore::UpdateEditionService
        .new(schema, @original_content_block_edition)
        .call(edition_params)
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

    describe "when a scheduled publish date is provided" do
      let(:scheduled_edition_params) do
        edition_params.merge(
          "scheduled_publication(3i)": "2",
          "scheduled_publication(2i)": "9",
          "scheduled_publication(1i)": "2034",
          "scheduled_publication(4i)": "10",
          "scheduled_publication(5i)": "05",
        )
      end

      test "it creates a new scheduled ContentBlockEdition in Whitehall" do
        original_document = ContentObjectStore::ContentBlock::Document.find_by!(content_id:)

        assert_changes -> { ContentObjectStore::ContentBlock::Edition.count }, from: 1, to: 2 do
          ContentObjectStore::UpdateEditionService
            .new(schema, @original_content_block_edition, ContentObjectStore::ChangeDispatcher::Schedule.new)
            .call(scheduled_edition_params)
        end

        new_edition = original_document.editions.last

        assert_equal scheduled_edition_params[:details], new_edition.details
        assert_equal "scheduled", new_edition.state
        assert_equal Time.zone.local(2034, 9, 2, 10, 0o5), new_edition.scheduled_publication
      end

      test "it schedules a new Edition via the Content Block Worker" do
        ContentObjectStore::SchedulePublishingWorker.expects(:queue).with do |content_block_edition|
          content_block_edition.scheduled? &&
            content_block_edition.document.title == scheduled_edition_params[:document_attributes][:title] &&
            content_block_edition.details == scheduled_edition_params[:details] &&
            content_block_edition.lead_organisation.id.to_s == scheduled_edition_params[:organisation_id] &&
            content_block_edition.scheduled_publication == Time.zone.local(2034, 9, 2, 10, 0o5)
        end

        ContentObjectStore::UpdateEditionService
          .new(schema, @original_content_block_edition, ContentObjectStore::ChangeDispatcher::Schedule.new)
          .call(scheduled_edition_params)
      end

      test "if the Worker request fails, the Whitehall ContentBlockEdition and ContentBlockDocument are rolled back" do
        exception = GdsApi::HTTPErrorResponse.new(
          422,
          "An internal error message",
          "error" => { "message" => "Some backend error" },
        )
        raises_exception = ->(*_args) { raise exception }

        ContentObjectStore::SchedulePublishingWorker.stub :queue, raises_exception do
          assert_equal ContentObjectStore::ContentBlock::Document.count, 1 do
            assert_equal ContentObjectStore::ContentBlock::Edition.count, 1 do
              assert_raises(GdsApi::HTTPErrorResponse) do
                ContentObjectStore::UpdateEditionService
                  .new(schema, @original_content_block_edition)
                  .call(scheduled_edition_params, be_scheduled: true)

                @original_content_block_edition.document.reload
                @original_content_block_edition.document.latest_edition = @original_content_block_edition
              end
            end
          end
        end
      end

      test "if the Whitehall creation fails, no call to schedule the Edition is made" do
        exception = ArgumentError.new("Cannot find schema for block_type")
        raises_exception = ->(*_args) { raise exception }

        ContentObjectStore::SchedulePublishingWorker.expects(:queue).never

        ContentObjectStore::ContentBlock::Edition.stub :create!, raises_exception do
          assert_raises(ArgumentError) do
            ContentObjectStore::UpdateEditionService
              .new(@original_content_block_edition)
              .call({}, be_scheduled: true)
          end
        end
      end
    end
  end
end
