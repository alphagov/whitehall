require "test_helper"

class ContentBlockManager::SchedulePublishingWorkerTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL
  include SidekiqTestHelpers

  # Suppress noisy Sidekiq logging in the test output
  setup do
    Sidekiq.configure_client do |cfg|
      cfg.logger.level = ::Logger::WARN
    end
  end

  describe "#perform" do
    it "publishes a scheduled edition" do
      document = create(:content_block_document, :email_address)
      edition = create(:content_block_edition, document:, state: "scheduled", scheduled_publication: Time.zone.now)

      publish_service_mock = Minitest::Mock.new
      ContentBlockManager::PublishEditionService.expects(:new).returns(publish_service_mock)
      publish_service_mock.expect :call, nil, [edition]

      ContentBlockManager::SchedulePublishingWorker.new.perform(edition.id)

      publish_service_mock.verify
    end

    it "raises an error if the edition cannot be published" do
      document = create(:content_block_document, :email_address)
      edition = create(:content_block_edition, document:, state: "scheduled", scheduled_publication: 7.days.since(Time.zone.now).to_date)

      publish_service_mock = Minitest::Mock.new

      exception = ContentBlockManager::PublishEditionService::PublishingFailureError.new(
        "Could not publish #{document.content_id} because: Some backend error",
      )

      ContentBlockManager::PublishEditionService.any_instance.stubs(:call).raises(exception)

      assert_raises(ContentBlockManager::SchedulePublishingWorker::SchedulingFailure, "Could not publish #{document.content_id} because: Some backend error") do
        ContentBlockManager::SchedulePublishingWorker.new.perform(edition.id)
      end
      publish_service_mock.verify
    end

    it "returns without consequence if the edition is already published" do
      document = create(:content_block_document, :email_address)
      edition = create(:content_block_edition, document:, state: "published")

      ContentBlockManager::PublishEditionService.expects(:new).never
      ContentBlockManager::PublishEditionService.any_instance.expects(:call).never

      ContentBlockManager::SchedulePublishingWorker.new.perform(edition.id)
    end
  end

  describe ".queue" do
    it "queues a job for a scheduled edition" do
      document = create(:content_block_document, :email_address)
      edition = create(
        :content_block_edition,
        document:, state: "scheduled",
        scheduled_publication: 1.day.from_now
      )

      ContentBlockManager::SchedulePublishingWorker.queue(edition)

      assert job = ContentBlockManager::SchedulePublishingWorker.jobs.last
      assert_equal edition.id, job["args"].first
      assert_equal edition.scheduled_publication.to_i, job["at"].to_i
    end
  end

  describe ".dequeue" do
    it "removes a job for a scheduled edition" do
      document = create(:content_block_document, :email_address)
      edition = create(
        :content_block_edition,
        document:,
        state: "scheduled",
        scheduled_publication: 1.day.from_now,
      )

      control_document = create(:content_block_document, :email_address)
      control_edition = create(
        :content_block_edition,
        document: control_document,
        state: "scheduled",
        scheduled_publication: 1.day.from_now,
      )

      with_real_sidekiq do
        ContentBlockManager::SchedulePublishingWorker.queue(edition)
        ContentBlockManager::SchedulePublishingWorker.queue(control_edition)

        assert_equal 2, Sidekiq::ScheduledSet.new.size

        ContentBlockManager::SchedulePublishingWorker.dequeue(edition)

        assert_equal 1, Sidekiq::ScheduledSet.new.size

        control_job = Sidekiq::ScheduledSet.new.first

        assert_equal control_job["args"].first, control_edition.id
        assert_equal control_job.at.to_i, control_edition.scheduled_publication.to_i
      end
    end
  end

  describe ".dequeue_all" do
    it "removes all content block publishing jobs" do
      document_1 = create(:content_block_document, :email_address)
      edition_1 = create(
        :content_block_edition,
        document: document_1,
        state: "scheduled",
        scheduled_publication: 1.day.from_now,
      )

      document_2 = create(:content_block_document, :email_address)
      edition_2 = create(
        :content_block_edition,
        document: document_2,
        state: "scheduled",
        scheduled_publication: 1.day.from_now,
      )

      with_real_sidekiq do
        ContentBlockManager::SchedulePublishingWorker.queue(edition_1)
        ContentBlockManager::SchedulePublishingWorker.queue(edition_2)

        assert_equal 2, Sidekiq::ScheduledSet.new.size

        ContentBlockManager::SchedulePublishingWorker.dequeue_all

        assert_equal 0, Sidekiq::ScheduledSet.new.size
      end
    end
  end

  describe ".queue_size" do
    it "returns the number of queued ContentBlockPublishingWorker jobs" do
      with_real_sidekiq do
        ContentBlockManager::SchedulePublishingWorker.perform_at(1.day.from_now, "null")
        assert_equal 1, ContentBlockManager::SchedulePublishingWorker.queue_size

        ContentBlockManager::SchedulePublishingWorker.perform_at(2.days.from_now, "null")
        assert_equal 2, ContentBlockManager::SchedulePublishingWorker.queue_size
      end
    end
  end

  describe ".queued_edition_ids" do
    it "returns the edition ids of the currently queued jobs" do
      with_real_sidekiq do
        ContentBlockManager::SchedulePublishingWorker.perform_at(1.day.from_now, "3")
        ContentBlockManager::SchedulePublishingWorker.perform_at(2.days.from_now, "6")

        assert_same_elements %w[3 6], ContentBlockManager::SchedulePublishingWorker.queued_edition_ids
      end
    end
  end
end
