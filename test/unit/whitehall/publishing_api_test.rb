require 'test_helper'

class Whitehall::PublishingApiTest < ActiveSupport::TestCase
  test "#publish publishes an Edition with the Publishing API" do
    edition = create(:published_publication)
    presenter = PublishingApiPresenters.presenter_for(edition)
    request = stub_publishing_api_put_item(presenter.base_path, presenter.as_json)

    Whitehall::PublishingApi.publish(edition)

    assert_requested request
  end

  test "#publish publishes non-Edition instances with the Publishing API" do
    organisation = create(:organisation)
    WebMock.reset! # because creating an organisation also pushes to Publishing API
    presenter = PublishingApiPresenters.presenter_for(organisation)
    request = stub_publishing_api_put_item(presenter.base_path, presenter.as_json)

    Whitehall::PublishingApi.publish(organisation)

    assert_requested request
  end

  test "#republish publishes to the Publishing API as a 'republish' update_type" do
    edition = create(:published_publication)
    presenter = PublishingApiPresenters.presenter_for(edition, update_type: 'republish')
    request = stub_publishing_api_put_item(presenter.base_path, presenter.as_json)

    Whitehall::PublishingApi.republish(edition)

    assert_requested request
  end

  test "#publish publishes all available translations of a translatable model" do
    organisation = create(:organisation)
    presenter = PublishingApiPresenters.presenter_for(organisation)

    I18n.with_locale :fr do
      organisation.name = "French name"
      organisation.save!
      WebMock.reset!

      @french_request = stub_publishing_api_put_item(presenter.base_path, presenter.as_json)
    end
    english_request = stub_publishing_api_put_item(presenter.base_path, presenter.as_json)

    Whitehall::PublishingApi.publish(organisation)

    assert_requested @french_request
    assert_requested english_request
  end

  test "#republish republishes all available translations of a translatable model" do
    organisation = create(:organisation)
    presenter = PublishingApiPresenters.presenter_for(organisation, update_type: 'republish')

    I18n.with_locale :fr do
      organisation.name = "French name"
      organisation.save!
      WebMock.reset!

      @french_request = stub_publishing_api_put_item(presenter.base_path, presenter.as_json)
    end
    english_request = stub_publishing_api_put_item(presenter.base_path, presenter.as_json)

    Whitehall::PublishingApi.republish(organisation)

    assert_requested @french_request
    assert_requested english_request
  end

  test "raises error for editions that are not publicly visible" do
    draft     = create(:draft_edition)
    published = create(:published_edition)
    archived  = create(:published_edition, state: 'archived')

    draft_payload     = PublishingApiPresenters.presenter_for(draft, update_type: "republish").as_json
    published_payload = PublishingApiPresenters.presenter_for(published, update_type: "republish").as_json
    archived_payload  = PublishingApiPresenters.presenter_for(archived, update_type: "republish").as_json

    draft_request     = stub_publishing_api_put_item(draft.search_link, draft_payload)
    published_request = stub_publishing_api_put_item(published.search_link, published_payload)
    archived_request  = stub_publishing_api_put_item(archived.search_link, archived_payload)

    Whitehall::PublishingApi.republish(published)
    Whitehall::PublishingApi.republish(archived)
    assert_raise Whitehall::UnpublishableInstanceError do
      Whitehall::PublishingApi.republish(draft)
    end

    assert_requested published_request
    assert_requested archived_request
    assert_not_requested draft_request
  end

  test "republishes an unpublishing" do
    unpublishing = create(:unpublishing)
    payload      = PublishingApiPresenters::Unpublishing.new(unpublishing, update_type: "republish").as_json
    request      = stub_publishing_api_put_item(unpublishing.document_path, payload)

    Whitehall::PublishingApi.republish(unpublishing)
    assert_requested request
  end

  test "publishes a redirect unpublishing" do
    unpublishing = create(:redirect_unpublishing)
    payload      = PublishingApiPresenters::Unpublishing.new(unpublishing, update_type: "republish").as_json
    request      = stub_publishing_api_put_item(unpublishing.document_path, payload)

    Whitehall::PublishingApi.republish(unpublishing)
    assert_requested request
  end

  test "publishes a translated edition that has been unpublished" do
    unpublishing    = create(:unpublishing)
    edition         = unpublishing.edition
    english_payload = PublishingApiPresenters::Unpublishing.new(unpublishing).as_json
    english_request = stub_publishing_api_put_item(unpublishing.document_path, english_payload)

    german_payload, german_request = nil
    I18n.with_locale(:de) do
      edition.title = 'German title'
      edition.save!

      german_payload = PublishingApiPresenters::Unpublishing.new(unpublishing).as_json
      german_request = stub_publishing_api_put_item(unpublishing.document_path, german_payload)
    end

    Whitehall::PublishingApi.publish(unpublishing)

    assert_requested english_request
    assert_requested german_request
  end

  test "schedule for a first edition served from Whitehall doesn't queue jobs to push publish intents and 'coming_soon' items" do
    timestamp = 12.hours.from_now
    edition   = create(:draft_edition, scheduled_publication: timestamp)

    Sidekiq::Testing.fake! do
      Whitehall::PublishingApi.schedule(edition)

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
      Whitehall::PublishingApi.schedule(edition)

      assert_equal [english_path, timestamp], PublishingApiScheduleWorker.jobs[0]['args']
      assert_equal [french_path, timestamp], PublishingApiScheduleWorker.jobs[1]['args']

      assert_equal [english_path, timestamp, 'en'], PublishingApiComingSoonWorker.jobs[0]['args']
      assert_equal [french_path, timestamp, 'fr'], PublishingApiComingSoonWorker.jobs[1]['args']
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
      Whitehall::PublishingApi.schedule(updated_edition)

      assert_equal [english_path, timestamp], PublishingApiScheduleWorker.jobs[0]['args']
      assert_equal [spanish_path, timestamp], PublishingApiScheduleWorker.jobs[1]['args']

      assert_equal [], PublishingApiComingSoonWorker.jobs
    end
  end

  test "unschedule for a first edition served from Whitehall doesn't queue jobs to remove publish intents and publish 'gone' items" do
    edition = create(:scheduled_edition)

    Sidekiq::Testing.fake! do
      Whitehall::PublishingApi.unschedule(edition)

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
      Whitehall::PublishingApi.unschedule(edition)

      assert_equal [german_path], PublishingApiUnscheduleWorker.jobs[0]['args']
      assert_equal [english_path], PublishingApiUnscheduleWorker.jobs[1]['args']

      assert_equal [german_path], PublishingApiGoneWorker.jobs[0]['args']
      assert_equal [english_path], PublishingApiGoneWorker.jobs[1]['args']
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
      Whitehall::PublishingApi.unschedule(updated_edition)

      assert_equal [german_path], PublishingApiUnscheduleWorker.jobs[0]['args']
      assert_equal [english_path], PublishingApiUnscheduleWorker.jobs[1]['args']

      assert_equal [], PublishingApiGoneWorker.jobs
    end
  end
end
