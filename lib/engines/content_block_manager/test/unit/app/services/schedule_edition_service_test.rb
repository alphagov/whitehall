require "test_helper"

class ContentBlockManager::ScheduleEditionServiceTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  let(:content_id) { SecureRandom.uuid }
  let(:organisation) { create(:organisation) }
  let(:schema) { build(:content_block_schema, block_type: "content_block_type", body: { "properties" => { "foo" => "", "bar" => "" } }) }

  let(:edition) do
    create(:content_block_edition,
           document: create(:content_block_document, :email_address, content_id:),
           details: { "foo" => "Foo text", "bar" => "Bar text" },
           organisation:)
  end

  setup do
    stub_publishing_api_has_embedded_content(content_id:, total: 0, results: [])
  end

  describe "#call" do
    let(:scheduled_publication_params) do
      {
        "scheduled_publication(3i)": "2",
        "scheduled_publication(2i)": "9",
        "scheduled_publication(1i)": "2034",
        "scheduled_publication(4i)": "10",
        "scheduled_publication(5i)": "05",
      }
    end

    it "schedules a new Edition via the Content Block Worker" do
      ContentBlockManager::SchedulePublishingWorker.expects(:queue).with do |expected_edition|
        expected_edition.id = edition.id &&
          expected_edition.scheduled_publication.year == scheduled_publication_params[:"scheduled_publication(1i)"].to_i &&
          expected_edition.scheduled_publication.month == scheduled_publication_params[:"scheduled_publication(2i)"].to_i &&
          expected_edition.scheduled_publication.day == scheduled_publication_params[:"scheduled_publication(3i)"].to_i &&
          expected_edition.scheduled_publication.hour == scheduled_publication_params[:"scheduled_publication(4i)"].to_i &&
          expected_edition.scheduled_publication.min == scheduled_publication_params[:"scheduled_publication(5i)"].to_i &&
          expected_edition.scheduled?
      end

      updated_edition = ContentBlockManager::ScheduleEditionService
        .new(schema)
        .call(edition, scheduled_publication_params)

      assert updated_edition.scheduled?
    end

    it "does not persist the changes if the Worker request fails" do
      exception = GdsApi::HTTPErrorResponse.new(
        422,
        "An internal error message",
        "error" => { "message" => "Some backend error" },
      )
      raises_exception = ->(*_args) { raise exception }

      ContentBlockManager::SchedulePublishingWorker.stub :queue, raises_exception do
        assert_raises(GdsApi::HTTPErrorResponse) do
          updated_edition = ContentBlockManager::ScheduleEditionService
            .new(schema)
            .call(edition, scheduled_publication_params)

          assert updated_edition.draft?
          assert_nil updated_edition.scheduled_publication
        end
      end
    end

    it "does not schedule the edition if the Whitehall creation fails" do
      exception = ArgumentError.new("Cannot find schema for block_type")
      raises_exception = ->(*_args) { raise exception }

      ContentBlockManager::SchedulePublishingWorker.expects(:queue).never

      edition.stub :update!, raises_exception do
        assert_raises(ArgumentError) do
          ContentBlockManager::ScheduleEditionService.new.call(edition, scheduled_publication_params)
        end
      end
    end

    it "queues publishing intents for dependent content" do
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

      ContentBlockManager::PublishIntentWorker.expects(:perform_async).with(
        "/host-document",
        "example-app",
        Time.zone.local(2034, 9, 2, 10, 5, 0).to_s,
      ).once

      ContentBlockManager::ScheduleEditionService
        .new(schema)
        .call(edition, scheduled_publication_params)
    end
  end
end
