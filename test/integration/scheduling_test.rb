require "test_helper"
require "gds_api/test_helpers/publishing_api"

class SchedulingTest < ActiveSupport::TestCase
  include GdsApi::TestHelpers::PublishingApi

  setup do
    disable_publishes_to_publishing_api do
      @submitted_edition = create(
        :submitted_publication,
        scheduled_publication: 1.day.from_now,
      )
    end
    stub_legacy_sidekiq_scheduling
    stub_any_publishing_api_call
    stub_any_publishing_api_put_intent
  end

  test "scheduling a first-edition publishes a publish intent" do
    Sidekiq::Testing.inline! do
      path = @submitted_edition.public_path(locale: :en)
      schedule(@submitted_edition)
      assert_publishing_api_put_intent(
        path,
        publish_time: @submitted_edition.scheduled_publication.as_json,
      )
    end
  end

  test "scheduling a subsequent edition publishes a publish intent to the Publishing API" do
    Sidekiq::Testing.inline! do
      published_edition = nil
      new_draft = nil
      user = nil

      disable_publishes_to_publishing_api do
        published_edition = create(:published_publication)
        new_draft = published_edition.create_draft(published_edition.creator)
        new_draft.change_note = "changed"
        new_draft.scheduled_publication = 1.day.from_now
        new_draft.save!
        new_draft.submit!

        user = create(:user)
      end

      path = new_draft.public_path(locale: :en)

      acting_as(user) { schedule(new_draft) }

      assert_not_requested(:put, %r{#{PUBLISHING_API_ENDPOINT}/content/#{published_edition.content_id}})
      assert_publishing_api_put_intent(path, publish_time: new_draft.scheduled_publication.as_json)
    end
  end

  test "scheduling a translated edition publishes a publish intent for each translation" do
    Sidekiq::Testing.inline! do
      I18n.with_locale :fr do
        @submitted_edition.title = "French title"
        @submitted_edition.save!
      end

      english_path = @submitted_edition.public_path(locale: :en)
      french_path  = @submitted_edition.public_path(locale: :fr)
      publish_time = @submitted_edition.scheduled_publication.as_json

      schedule(@submitted_edition)

      assert_publishing_api_put_intent(english_path, publish_time:)
      assert_publishing_api_put_intent(french_path, publish_time:)
    end
  end

  test "unscheduling a scheduled first-edition removes the publish intent" do
    Sidekiq::Testing.inline! do
      gone_uuid = SecureRandom.uuid
      SecureRandom.stubs(uuid: gone_uuid)
      scheduled_edition = create(:scheduled_case_study)
      unscheduler       = Whitehall.edition_services.unscheduler(scheduled_edition)
      base_path         = scheduled_edition.public_path(locale: :en)

      destroy_intent_request = stub_publishing_api_destroy_intent(base_path)
      unscheduler.perform!

      assert_requested destroy_intent_request
    end
  end

  test "unscheduling a scheduled subsequent edition removes the publish intent" do
    Sidekiq::Testing.inline! do
      published_edition = create(:published_case_study)
      scheduled_edition = create(:scheduled_case_study, document: published_edition.document)

      unscheduler       = Whitehall.edition_services.unscheduler(scheduled_edition)
      base_path         = scheduled_edition.public_path(locale: :en)

      destroy_intent_request = stub_publishing_api_destroy_intent(base_path)

      unscheduler.perform!

      assert_requested destroy_intent_request
    end
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
