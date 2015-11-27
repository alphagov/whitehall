require 'test_helper'
require "gds_api/test_helpers/publishing_api_v2"

class Whitehall::PublishingApiTest < ActiveSupport::TestCase
  include GdsApi::TestHelpers::PublishingApiV2

  setup do
    # Disable any predefined webmock stubs, we want a clean slate
    # TODO: investigate removing stubbing of publishing api calls from standard test setup
    WebMock.reset!

    # In the case of unpublishings, we trigger a job to save the draft edition.
    # That job runs inline because we're in test mode, so we need to stub it.
    stub_any_publishing_api_put_content
    stub_any_publishing_api_put_links
  end

  test "#publish publishes an Edition with the Publishing API" do
    edition = create(:published_publication)
    presenter = PublishingApiPresenters.presenter_for(edition)
    requests = stub_publishing_api_put_content_links_and_publish(presenter.as_json)

    Whitehall::PublishingApi.publish_async(edition)

    assert_all_requested(requests)
  end

  test "#publish publishes non-Edition instances with the Publishing API" do
    organisation = create(:organisation)
    WebMock.reset! # because creating an organisation also pushes to Publishing API
    presenter = PublishingApiPresenters.presenter_for(organisation)
    requests = stub_publishing_api_put_content_links_and_publish(presenter.as_json)

    Whitehall::PublishingApi.publish_async(organisation)

    assert_all_requested(requests)
  end

  test "#publish sends unpublishing for case studies to the content store" do
    edition = create(:draft_case_study)
    unpublishing = create(:unpublishing, edition: edition)

    payload = PublishingApiPresenters::Unpublishing.new(unpublishing).as_json
    requests = stub_publishing_api_put_content_links_and_publish(payload)

    Whitehall::PublishingApi.publish_async(unpublishing)

    assert_all_requested(requests)
  end

  test "#publish skips sending unpublishings for formats other than case study" do
    edition = create(:draft_publication)
    unpublishing = create(:unpublishing, edition: edition)

    Whitehall::PublishingApi.publish_async(unpublishing)

    assert_not_requested :put, %r{/content/}
  end

  test "#publish sends case studies to the content store" do
    edition = create(:published_case_study)

    presenter = PublishingApiPresenters.presenter_for(edition)
    requests = stub_publishing_api_put_content_links_and_publish(presenter.as_json)

    Whitehall::PublishingApi.publish_async(edition)

    assert_all_requested(requests)
  end

  test "#republish publishes to the Publishing API as a 'republish' update_type" do
    edition = create(:published_publication)
    presenter = PublishingApiPresenters.presenter_for(edition, update_type: 'republish')
    requests = stub_publishing_api_put_content_links_and_publish(presenter.as_json)

    Whitehall::PublishingApi.republish_async(edition)

    assert_all_requested(requests)
  end

  test "#publish publishes all available translations of a translatable model" do
    organisation = create(:organisation)
    presenter = PublishingApiPresenters.presenter_for(organisation)

    I18n.with_locale :fr do
      organisation.name = "French name"
      organisation.save!
      WebMock.reset!

      @french_requests = stub_publishing_api_put_content_links_and_publish(presenter.as_json)
    end
    english_requests = stub_publishing_api_put_content_links_and_publish(presenter.as_json)

    Whitehall::PublishingApi.publish_async(organisation)

    assert_all_requested(@french_requests)
    assert_all_requested(english_requests)
  end

  test "#republish republishes all available translations of a translatable model" do
    organisation = create(:organisation)
    presenter = PublishingApiPresenters.presenter_for(organisation, update_type: 'republish')

    I18n.with_locale :fr do
      organisation.name = "French name"
      organisation.save!
      WebMock.reset!

      @french_requests = stub_publishing_api_put_content_links_and_publish(presenter.as_json)
    end
    english_requests = stub_publishing_api_put_content_links_and_publish(presenter.as_json)

    Whitehall::PublishingApi.republish_async(organisation)

    assert_all_requested(@french_requests)
    assert_all_requested(english_requests)
  end

  test "#republish raises error for editions that are not publicly visible" do
    draft     = create(:draft_edition)
    published = create(:published_edition)
    withdrawn = create(:published_edition, state: 'withdrawn')

    draft_payload     = PublishingApiPresenters.presenter_for(draft, update_type: "republish").as_json
    published_payload = PublishingApiPresenters.presenter_for(published, update_type: "republish").as_json
    withdrawn_payload = PublishingApiPresenters.presenter_for(withdrawn, update_type: "republish").as_json

    draft_requests     = stub_publishing_api_put_content_links_and_publish(draft_payload)
    published_requests = stub_publishing_api_put_content_links_and_publish(published_payload)
    withdrawn_requests = stub_publishing_api_put_content_links_and_publish(withdrawn_payload)

    Whitehall::PublishingApi.republish_async(published)
    Whitehall::PublishingApi.republish_async(withdrawn)
    assert_raise Whitehall::UnpublishableInstanceError do
      Whitehall::PublishingApi.republish_async(draft)
    end

    assert_all_requested(published_requests)
    assert_all_requested(withdrawn_requests)
    draft_requests.each { |request| assert_not_requested request }
  end

  test "republishes an unpublishing" do
    unpublishing = create(:unpublishing)
    payload      = PublishingApiPresenters::Unpublishing.new(unpublishing, update_type: "republish").as_json
    requests     = stub_publishing_api_put_content_links_and_publish(payload)

    Whitehall::PublishingApi.republish_async(unpublishing)
    assert_all_requested(requests)
  end

  test "publishes a redirect unpublishing" do
    unpublishing = create(:redirect_unpublishing)
    payload      = PublishingApiPresenters::Unpublishing.new(unpublishing, update_type: "republish").as_json
    requests     = stub_publishing_api_put_content_links_and_publish(payload, payload["content_id"], { update_type: { update_type: "republish", locale: 'en' } })

    Whitehall::PublishingApi.republish_async(unpublishing)
    assert_all_requested(requests)
  end

  test "publishes a translated edition that has been unpublished" do
    unpublishing     = create(:unpublishing)
    edition          = unpublishing.edition
    english_payload  = PublishingApiPresenters::Unpublishing.new(unpublishing).as_json
    english_requests = stub_publishing_api_put_content_links_and_publish(english_payload)

    german_payload, german_requests = nil
    I18n.with_locale(:de) do
      edition.title = 'German title'
      edition.save!

      german_payload  = PublishingApiPresenters::Unpublishing.new(unpublishing).as_json
      german_requests = stub_publishing_api_put_content_links_and_publish(german_payload)
    end

    Whitehall::PublishingApi.publish_async(unpublishing)

    assert_all_requested(english_requests)
    assert_all_requested(german_requests)
  end

  test "schedule for a first edition served from Whitehall doesn't queue jobs to push publish intents and 'coming_soon' items" do
    timestamp = 12.hours.from_now
    edition   = create(:draft_edition, scheduled_publication: timestamp)

    Sidekiq::Testing.fake! do
      Whitehall::PublishingApi.schedule_async(edition)

      assert_empty PublishingApiScheduleWorker.jobs
      assert_empty PublishingApiComingSoonWorker.jobs
    end
  end

  test "schedule for a first edition served from the content store queues jobs to push publish intents and 'coming_soon' items" do
    timestamp = 12.hours.from_now
    edition   = create(:draft_case_study, scheduled_publication: timestamp)

    I18n.with_locale(:fr) do
      edition.title = 'French title'
      edition.save!
    end

    english_path = Whitehall.url_maker.public_document_path(edition)
    french_path  = Whitehall.url_maker.public_document_path(edition, locale: :fr)

    Sidekiq::Testing.fake! do
      Whitehall::PublishingApi.schedule_async(edition)

      assert_equal [english_path, timestamp], PublishingApiScheduleWorker.jobs[0]['args']
      assert_equal [french_path, timestamp], PublishingApiScheduleWorker.jobs[1]['args']

      assert_equal [edition.id, 'en'], PublishingApiComingSoonWorker.jobs[0]['args']
      assert_equal [edition.id, 'fr'], PublishingApiComingSoonWorker.jobs[1]['args']
    end
  end

  test "schedule for a subsequent edition served from the content store queues jobs to push publish intents, but not to publish 'coming_soon' items" do
    timestamp = 2.hours.from_now
    existing_edition = create(:published_case_study)
    updated_edition = create(:draft_case_study, scheduled_publication: timestamp, document: existing_edition.document)

    I18n.with_locale(:es) do
      updated_edition.title = 'Spanish title'
      updated_edition.save!
    end

    english_path = Whitehall.url_maker.public_document_path(updated_edition)
    spanish_path = Whitehall.url_maker.public_document_path(updated_edition, locale: :es)

    Sidekiq::Testing.fake! do
      Whitehall::PublishingApi.schedule_async(updated_edition)

      assert_equal [english_path, timestamp], PublishingApiScheduleWorker.jobs[0]['args']
      assert_equal [spanish_path, timestamp], PublishingApiScheduleWorker.jobs[1]['args']

      assert_equal [], PublishingApiComingSoonWorker.jobs
    end
  end

  test "unschedule for a first edition served from Whitehall doesn't queue jobs to remove publish intents and publish 'gone' items" do
    edition = create(:scheduled_edition)

    Sidekiq::Testing.fake! do
      Whitehall::PublishingApi.unschedule_async(edition)

      assert_empty PublishingApiUnscheduleWorker.jobs
      assert_empty PublishingApiGoneWorker.jobs
    end
  end

  test "unschedule for a first edition served from the content store queues jobs to remove publish intents and publish 'gone' items" do
    edition = create(:scheduled_case_study)

    I18n.with_locale(:de) do
      edition.title = 'German title'
      edition.save!(validate: false)
    end

    english_path = Whitehall.url_maker.public_document_path(edition)
    german_path = Whitehall.url_maker.public_document_path(edition, locale: :de)

    Sidekiq::Testing.fake! do
      Whitehall::PublishingApi.unschedule_async(edition)

      assert_equal [german_path], PublishingApiUnscheduleWorker.jobs[0]['args']
      assert_equal [english_path], PublishingApiUnscheduleWorker.jobs[1]['args']

      assert_equal german_path, PublishingApiGoneWorker.jobs[0]['args'].first
      assert_equal english_path, PublishingApiGoneWorker.jobs[1]['args'].first
    end
  end

  test "unschedule for a subsequent edition served from the content store queues jobs to remove publish intents, but not to publish 'gone' items" do
    existing_edition = create(:published_case_study)
    updated_edition = create(:scheduled_case_study, document: existing_edition.document)

    I18n.with_locale(:de) do
      updated_edition.title = 'German title'
      updated_edition.save!(validate: false)
    end

    english_path = Whitehall.url_maker.public_document_path(updated_edition)
    german_path = Whitehall.url_maker.public_document_path(updated_edition, locale: :de)

    Sidekiq::Testing.fake! do
      Whitehall::PublishingApi.unschedule_async(updated_edition)

      assert_equal [german_path], PublishingApiUnscheduleWorker.jobs[0]['args']
      assert_equal [english_path], PublishingApiUnscheduleWorker.jobs[1]['args']

      assert_equal [], PublishingApiGoneWorker.jobs
    end
  end

  test "#save_draft_async publishes a draft edition" do
    draft_edition = create(:draft_case_study)
    payload = PublishingApiPresenters.presenter_for(draft_edition).as_json
    request = stub_publishing_api_put_content(payload[:content_id], payload.except(:links))

    Whitehall::PublishingApi.save_draft_async(draft_edition)

    assert_requested request
  end

  test "#publish_async propagates update_type and queue overrides to worker" do
    queue_name = "bang"
    update_type = "whizzo"

    edition = create(:published_case_study)

    PublishingApiWorker.expects(:perform_async_in_queue)
      .with(queue_name, edition.class.name, edition.id,
            update_type, edition.primary_locale.to_sym)

    Whitehall::PublishingApi.publish_async(edition, update_type, queue_name)
  end

  test "#save_draft_async propagates update_type and queue overrides to worker" do
    queue_name = "bang"
    update_type = "whizzo"

    draft_edition = create(:draft_case_study)

    PublishingApiDraftWorker.expects(:perform_async_in_queue)
      .with(queue_name, draft_edition.class.name, draft_edition.id,
            update_type, draft_edition.primary_locale.to_sym)

    Whitehall::PublishingApi.save_draft_async(draft_edition, update_type, queue_name)
  end

  test "#publish_redirect publishes a redirect to the Publishing API" do
    redirect_uuid = SecureRandom.uuid
    SecureRandom.stubs(uuid: redirect_uuid)
    base_path = "/government/people/milly-vanilly"
    redirects = [
      {
        content_id: redirect_uuid,
        path: base_path,
        type: "exact",
        destination: "/government/poeple/milli-vanilli"
      }
    ]
    expected_content_request = stub_publishing_api_put_content(redirect_uuid, Whitehall::PublishingApi::Redirect.new(base_path, redirects).as_json)
    expected_publish_request = stub_publishing_api_publish(redirect_uuid, update_type: { update_type: 'major', locale: 'en' })
    Whitehall::PublishingApi.publish_redirect_async(base_path, redirects)

    assert_requested expected_content_request
    assert_requested expected_publish_request
  end
end
