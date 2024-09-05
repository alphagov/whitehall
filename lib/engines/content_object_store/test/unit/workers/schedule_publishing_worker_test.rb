require "test_helper"

class ContentObjectStore::SchedulePublishingWorkerTest < ActiveSupport::TestCase
  include SidekiqTestHelpers

  # Suppress noisy Sidekiq logging in the test output
  setup do
    Sidekiq.configure_client do |cfg|
      cfg.logger.level = ::Logger::WARN
    end
  end

  test "#perform publishes a scheduled edition" do
    schema = build(:content_block_schema, block_type: "content_block_type", body: { "properties" => { "foo" => "", "bar" => "" } })
    document = create(:content_block_document, :email_address)
    edition = create(:content_block_edition, document:, state: "scheduled", scheduled_publication: Time.zone.now)

    ContentObjectStore::ContentBlock::Schema.expects(:find_by_block_type).with("email_address").returns(schema)
    publish_service_mock = Minitest::Mock.new
    ContentObjectStore::PublishEditionService.expects(:new).with(schema).returns(publish_service_mock)
    publish_service_mock.expect :call, nil, [edition]

    ContentObjectStore::SchedulePublishingWorker.new.perform(edition.id)

    publish_service_mock.verify
  end

  test "#perform raises an error if the edition cannot be published" do
    schema = build(:content_block_schema, block_type: "content_block_type", body: { "properties" => { "foo" => "", "bar" => "" } })
    document = create(:content_block_document, :email_address)
    edition = create(:content_block_edition, document:, state: "scheduled", scheduled_publication: 7.days.since(Time.zone.now).to_date)

    ContentObjectStore::ContentBlock::Schema.expects(:find_by_block_type).with("email_address").returns(schema)
    publish_service_mock = Minitest::Mock.new

    exception = ContentObjectStore::PublishEditionService::PublishingFailureError.new(
      "Could not publish #{document.content_id} because: Some backend error",
    )

    ContentObjectStore::PublishEditionService.any_instance.stubs(:call).raises(exception)

    assert_raises(ContentObjectStore::SchedulePublishingWorker::SchedulingFailure, "Could not publish #{document.content_id} because: Some backend error") do
      ContentObjectStore::SchedulePublishingWorker.new.perform(edition.id)
    end
    publish_service_mock.verify
  end

  test "#perform returns without consequence if the edition is already published" do
    document = create(:content_block_document, :email_address)
    edition = create(:content_block_edition, document:, state: "published")

    ContentObjectStore::ContentBlock::Schema.expects(:find_by_block_type).never
    ContentObjectStore::PublishEditionService.expects(:new).never
    ContentObjectStore::PublishEditionService.any_instance.expects(:call).never

    ContentObjectStore::SchedulePublishingWorker.new.perform(edition.id)
  end

  test ".queue queues a job for a scheduled edition" do
    document = create(:content_block_document, :email_address)
    edition = create(
      :content_block_edition,
      document:, state: "scheduled",
      scheduled_publication: 1.day.from_now
    )

    ContentObjectStore::SchedulePublishingWorker.queue(edition)

    assert job = ContentObjectStore::SchedulePublishingWorker.jobs.last
    assert_equal edition.id, job["args"].first
    assert_equal edition.scheduled_publication.to_i, job["at"].to_i
  end

  test ".dequeue removes a job for a scheduled edition" do
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
      ContentObjectStore::SchedulePublishingWorker.queue(edition)
      ContentObjectStore::SchedulePublishingWorker.queue(control_edition)

      assert_equal 2, Sidekiq::ScheduledSet.new.size

      ContentObjectStore::SchedulePublishingWorker.dequeue(edition)

      assert_equal 1, Sidekiq::ScheduledSet.new.size

      control_job = Sidekiq::ScheduledSet.new.first

      assert_equal control_job["args"].first, control_edition.id
      assert_equal control_job.at.to_i, control_edition.scheduled_publication.to_i
    end
  end

  test ".dequeue_all removes all content block publishing jobs" do
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
      ContentObjectStore::SchedulePublishingWorker.queue(edition_1)
      ContentObjectStore::SchedulePublishingWorker.queue(edition_2)

      assert_equal 2, Sidekiq::ScheduledSet.new.size

      ContentObjectStore::SchedulePublishingWorker.dequeue_all

      assert_equal 0, Sidekiq::ScheduledSet.new.size
    end
  end

  test ".queue_size returns the number of queued ContentBlockPublishingWorker jobs" do
    with_real_sidekiq do
      ContentObjectStore::SchedulePublishingWorker.perform_at(1.day.from_now, "null")
      assert_equal 1, ContentObjectStore::SchedulePublishingWorker.queue_size

      ContentObjectStore::SchedulePublishingWorker.perform_at(2.days.from_now, "null")
      assert_equal 2, ContentObjectStore::SchedulePublishingWorker.queue_size
    end
  end

  test ".queued_edition_ids returns the edition ids of the currently queued jobs" do
    with_real_sidekiq do
      ContentObjectStore::SchedulePublishingWorker.perform_at(1.day.from_now, "3")
      ContentObjectStore::SchedulePublishingWorker.perform_at(2.days.from_now, "6")

      assert_same_elements %w[3 6], ContentObjectStore::SchedulePublishingWorker.queued_edition_ids
    end
  end
end
