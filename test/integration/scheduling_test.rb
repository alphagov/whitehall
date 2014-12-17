require "test_helper"
require "gds_api/test_helpers/publishing_api"

class SchedulingTest < ActiveSupport::TestCase
  include GdsApi::TestHelpers::PublishingApi

  setup do
    @submitted_edition = create(:submitted_edition,
                                scheduled_publication: 1.day.from_now)
    stub_legacy_sidekiq_scheduling
    stub_default_publishing_api_put
    stub_default_publishing_api_put_intent
  end

  test "When scheduling an edition, a publish intent is sent to content-store" do
    path = Whitehall.url_maker.public_document_path(@submitted_edition)
    schedule(@submitted_edition)
    assert_publishing_api_put_intent(path, publish_time: @submitted_edition.scheduled_publication.as_json)
  end

  test "When scheduling an edition that has not been published before, a coming_soon format is sent to content-store" do
    path = Whitehall.url_maker.public_document_path(@submitted_edition)
    schedule(@submitted_edition)
    assert_publishing_api_put_item(path, format: 'coming_soon')
  end

  test "When scheduling an edition that has been published before, no coming_soon format is sent to content-store" do
    published_edition = create(:published_edition)
    new_draft = published_edition.create_draft(published_edition.creator)
    new_draft.change_note = 'changed'
    new_draft.scheduled_publication = 1.day.from_now
    new_draft.save!
    new_draft.submit!

    path = Whitehall.url_maker.public_document_path(new_draft)

    acting_as(create(:user)) { schedule(new_draft) }

    assert_not_requested(:put, %r{#{PUBLISHING_API_ENDPOINT}/content.*})
    assert_publishing_api_put_intent(path, publish_time: new_draft.scheduled_publication.as_json)
  end

private
  def schedule(edition, options = {})
    Whitehall.edition_services.scheduler(edition, options).perform!
  end

  def stub_legacy_sidekiq_scheduling
    # Scheduling an item will enqueue the publish action, and queued actions
    # are performed immediately in test, which will fail: so stub the worker.
    ScheduledPublishingWorker.stubs(:queue)
  end
end
