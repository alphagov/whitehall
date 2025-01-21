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
           scheduled_publication: Time.zone.parse("2034-09-02T10:05:00"),
           organisation:)
  end

  setup do
    ContentBlockManager::ContentBlock::Schema.stubs(:find_by_block_type)
                                             .returns(schema)
    stub_publishing_api_has_embedded_content(content_id:, total: 0, results: [], order: ContentBlockManager::HostContentItem::DEFAULT_ORDER)
  end

  describe "#call" do
    it "schedules a new Edition via the Content Block Worker" do
      ContentBlockManager::SchedulePublishingWorker.expects(:dequeue).never

      ContentBlockManager::SchedulePublishingWorker.expects(:queue).with do |expected_edition|
        expected_edition.id = edition.id &&
          expected_edition.scheduled_publication == edition.scheduled_publication &&
          expected_edition.scheduled?
      end

      updated_edition = ContentBlockManager::ScheduleEditionService
        .new(schema)
        .call(edition)

      assert updated_edition.scheduled?
    end

    it "dequeues existing jobs if the edition is already scheduled" do
      ContentBlockManager::SchedulePublishingWorker.expects(:dequeue).with do |expected_edition|
        expected_edition.id = edition.id
      end

      ContentBlockManager::SchedulePublishingWorker.expects(:queue).with do |expected_edition|
        expected_edition.id = edition.id
      end

      edition.schedule!

      ContentBlockManager::ScheduleEditionService
        .new(schema)
        .call(edition)
    end

    it "supersedes any previously scheduled editions" do
      scheduled_editions = create_list(:content_block_edition, 2,
                                       document: edition.document,
                                       scheduled_publication: 7.days.from_now,
                                       state: "scheduled")

      ContentBlockManager::SchedulePublishingWorker.expects(:queue).with do |expected_edition|
        expected_edition.id = edition.id
      end

      scheduled_editions.each do |scheduled_edition|
        ContentBlockManager::SchedulePublishingWorker.expects(:dequeue).with(scheduled_edition)
      end

      ContentBlockManager::ScheduleEditionService
        .new(schema)
        .call(edition)

      scheduled_editions.each do |scheduled_edition|
        assert scheduled_edition.reload.superseded?
      end
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
            .call(edition)

          assert updated_edition.draft?
          assert_nil updated_edition.scheduled_publication
        end
      end
    end

    it "does not schedule the edition if the Whitehall creation fails" do
      exception = ArgumentError.new("Cannot find schema for block_type")
      raises_exception = ->(*_args) { raise exception }

      ContentBlockManager::SchedulePublishingWorker.expects(:queue).never

      edition.stub :schedule!, raises_exception do
        assert_raises(ArgumentError) do
          ContentBlockManager::ScheduleEditionService.new(schema).call(edition)
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

      stub_publishing_api_has_embedded_content(content_id:, total: 0, results: dependent_content, order: ContentBlockManager::HostContentItem::DEFAULT_ORDER)

      ContentBlockManager::PublishIntentWorker.expects(:perform_async).with(
        "/host-document",
        "example-app",
        Time.zone.local(2034, 9, 2, 10, 5, 0).to_s,
      ).once

      ContentBlockManager::ScheduleEditionService
        .new(schema)
        .call(edition)
    end
  end
end
