require "test_helper"
require "gds_api/test_helpers/publishing_api"

class Whitehall::PublishingApiTest < ActiveSupport::TestCase
  include GdsApi::TestHelpers::PublishingApi

  setup do
    # Disable any predefined webmock stubs, we want a clean slate
    # TODO: investigate removing stubbing of publishing api calls from standard test setup
    WebMock.reset!

    # Stub all publishing-api endpoints because creating a model makes the calls
    # before we have a chance to stub inside each test. Individual tests still
    # check for calls to publishing-api with test-specific data.
    stub_any_publishing_api_put_content
    stub_any_publishing_api_patch_links
    stub_any_publishing_api_publish
  end

  test ".publish publishes an Edition with the Publishing API" do
    edition = create(:published_publication)
    presenter = PublishingApiPresenters.presenter_for(edition)
    requests = [
      stub_publishing_api_put_content(presenter.content_id, presenter.content),
      stub_publishing_api_publish(presenter.content_id, locale: presenter.content[:locale], update_type: nil),
    ]

    Whitehall::PublishingApi.publish(edition)

    assert_all_requested(requests)
  end

  test ".publish publishes non-Edition instances with the Publishing API" do
    organisation = create(:organisation)
    WebMock.reset! # because creating an organisation also pushes to Publishing API
    presenter = PublishingApiPresenters.presenter_for(organisation)
    requests = [
      stub_publishing_api_put_content(presenter.content_id, presenter.content),
      stub_publishing_api_publish(presenter.content_id, locale: presenter.content[:locale], update_type: nil),
    ]

    Whitehall::PublishingApi.publish(organisation)

    assert_all_requested(requests)
  end

  test ".publish sends case studies to the content store" do
    edition = create(:published_case_study)

    presenter = PublishingApiPresenters.presenter_for(edition)
    requests = [
      stub_publishing_api_put_content(presenter.content_id, presenter.content),
      stub_publishing_api_publish(presenter.content_id, locale: presenter.content[:locale], update_type: nil),
    ]

    Whitehall::PublishingApi.publish(edition)

    assert_all_requested(requests)
  end

  test ".publish publishes all available translations of a translatable model" do
    organisation = create(:organisation)
    presenter = PublishingApiPresenters.presenter_for(organisation)

    french_requests = I18n.with_locale :fr do
      organisation.name = "French name"
      organisation.save!
      WebMock.reset!

      [
        stub_publishing_api_put_content(presenter.content_id, presenter.content),
        stub_publishing_api_publish(presenter.content_id, locale: "fr", update_type: nil),
      ]
    end

    english_requests = [
      stub_publishing_api_put_content(presenter.content_id, presenter.content),
      stub_publishing_api_publish(presenter.content_id, locale: "en", update_type: nil),
    ]

    Whitehall::PublishingApi.publish(organisation)

    assert_all_requested(french_requests)
    assert_all_requested(english_requests)
  end

  test ".republish_async publishes to the Publishing API as a 'republish' update_type" do
    take_part_page = create(:take_part_page)
    presenter = PublishingApiPresenters.presenter_for(take_part_page, update_type: "republish")
    WebMock.reset!

    requests = [
      stub_publishing_api_put_content(presenter.content_id, presenter.content),
      stub_publishing_api_patch_links(presenter.content_id, links: presenter.links),
      stub_publishing_api_publish(presenter.content_id, locale: presenter.content[:locale], update_type: nil),
    ]

    Sidekiq::Testing.inline! do
      Whitehall::PublishingApi.republish_async(take_part_page)
    end

    assert_all_requested(requests)
  end

  test ".republish_async republishes all available translations of a translatable model" do
    organisation = create(:organisation)
    presenter = PublishingApiPresenters.presenter_for(organisation, update_type: "republish")

    french_requests = I18n.with_locale :fr do
      organisation.name = "French name"
      organisation.save!
      WebMock.reset!

      [
        stub_publishing_api_put_content(presenter.content_id, presenter.content),
        stub_publishing_api_publish(presenter.content_id, locale: "fr", update_type: nil),
      ]
    end

    english_requests = [
      stub_publishing_api_put_content(presenter.content_id, presenter.content),
      stub_publishing_api_publish(presenter.content_id, locale: "en", update_type: nil),
    ]

    links_request = stub_publishing_api_patch_links(presenter.content_id, links: presenter.links)

    Sidekiq::Testing.inline! do
      Whitehall::PublishingApi.republish_async(organisation)
    end

    assert_all_requested(french_requests)
    assert_all_requested(english_requests)
    assert_requested(links_request, times: 2)
  end

  test ".republish_async raises an error when passed an Edition type" do
    edition = create(:published_edition)
    assert_raise(ArgumentError, "Use republish_document_async for republishing Editions") do
      Whitehall::PublishingApi.republish_async(edition)
    end
  end

  test ".bulk_republish_async publishes to the Publishing API as a 'republish'" do
    take_part_page = create(:take_part_page)
    presenter = PublishingApiPresenters.presenter_for(take_part_page, update_type: "republish")
    WebMock.reset!

    requests = [
      stub_publishing_api_put_content(presenter.content_id, presenter.content),
      stub_publishing_api_patch_links(presenter.content_id, links: presenter.links),
      stub_publishing_api_publish(presenter.content_id, locale: presenter.content[:locale], update_type: nil),
    ]

    Sidekiq::Testing.inline! do
      Whitehall::PublishingApi.bulk_republish_async(take_part_page)
    end

    assert_all_requested(requests)
  end

  test ".bulk_republish_async queues the job on the bulk_republishing queue" do
    take_part_page = create(:take_part_page)
    PublishingApiWorker.expects(:perform_async_in_queue)
      .with(
        "bulk_republishing",
        "TakePartPage",
        take_part_page.id,
        "republish",
        "en",
      )
    Whitehall::PublishingApi.bulk_republish_async(take_part_page)
  end

  test ".republish_document_async publishes to the publishing API as a 'republish' update_type" do
    edition = create(:published_publication)
    presenter = PublishingApiPresenters.presenter_for(edition, update_type: "republish")
    html_attachment_content_id = edition.html_attachments.first.content_id

    requests = [
      stub_publishing_api_put_content(presenter.content_id, presenter.content),
      stub_publishing_api_patch_links(presenter.content_id, links: presenter.links),
      stub_publishing_api_publish(presenter.content_id, locale: presenter.content[:locale], update_type: nil),
      stub_publishing_api_publish(html_attachment_content_id, locale: presenter.content[:locale], update_type: nil),
    ]

    Sidekiq::Testing.inline! do
      Whitehall::PublishingApi.republish_document_async(edition.document)
    end

    assert_all_requested(requests)
  end

  test ".schedule_async for a first edition served from the content store queues jobs to push publish intents" do
    timestamp = 12.hours.from_now
    edition   = create(:draft_publication, scheduled_publication: timestamp)

    I18n.with_locale(:fr) do
      edition.title = "French title"
      edition.save!
    end

    english_path = edition.public_path
    french_path  = edition.public_path(locale: :fr)

    Whitehall::PublishingApi.schedule_async(edition)

    first_job = PublishingApiScheduleWorker.jobs[0]["args"]
    second_job = PublishingApiScheduleWorker.jobs[1]["args"]

    assert_equal english_path, first_job[0]
    assert_equal timestamp, first_job[1]

    assert_equal french_path, second_job[0]
    assert_equal timestamp, second_job[1]
  end

  test ".schedule_async for a subsequent edition served from the content store queues jobs to push publish intents" do
    timestamp = 2.hours.from_now
    existing_edition = create(:published_case_study)
    updated_edition = create(:draft_publication, scheduled_publication: timestamp, document: existing_edition.document)

    I18n.with_locale(:es) do
      updated_edition.title = "Spanish title"
      updated_edition.save!
    end

    english_path = updated_edition.public_path
    spanish_path = updated_edition.public_path(locale: :es)

    Whitehall::PublishingApi.schedule_async(updated_edition)

    first_job = PublishingApiScheduleWorker.jobs[0]["args"]
    second_job = PublishingApiScheduleWorker.jobs[1]["args"]

    assert_equal english_path, first_job[0]
    assert_equal timestamp, first_job[1]

    assert_equal spanish_path, second_job[0]
    assert_equal timestamp, second_job[1]
  end

  test ".unschedule_async for a first edition served from the content store queues jobs to remove publish intents" do
    edition = create(:scheduled_publication)

    I18n.with_locale(:de) do
      edition.title = "German title"
      edition.save!(validate: false)
    end

    english_path = edition.public_path
    german_path = edition.public_path(locale: :de)

    Whitehall::PublishingApi.unschedule_async(edition)

    assert_equal german_path, PublishingApiUnscheduleWorker.jobs[0]["args"].first
    assert_equal english_path, PublishingApiUnscheduleWorker.jobs[1]["args"].first
  end

  test ".unschedule_async for a subsequent edition served from the content store queues jobs to remove publish intents" do
    existing_edition = create(:published_publication)
    updated_edition = create(:scheduled_publication, document: existing_edition.document)

    I18n.with_locale(:de) do
      updated_edition.title = "German title"
      updated_edition.save!(validate: false)
    end

    english_path = updated_edition.public_path
    german_path = updated_edition.public_path(locale: :de)

    Whitehall::PublishingApi.unschedule_async(updated_edition)

    assert_equal german_path, PublishingApiUnscheduleWorker.jobs[0]["args"].first
    assert_equal english_path, PublishingApiUnscheduleWorker.jobs[1]["args"].first
  end

  test ".save_draft publishes a draft edition" do
    draft_edition = create(:draft_case_study)
    payload = PublishingApiPresenters.presenter_for(draft_edition)
    request = stub_publishing_api_put_content(payload.content_id, payload.content)

    Whitehall::PublishingApi.save_draft(draft_edition)

    assert_requested request
  end

  test ".publish_redirect_async publishes a redirect to the Publishing API" do
    document = create(:document)
    destination = "/government/people/milli-vanilli"
    redirect_request = stub_publishing_api_unpublish(
      document.content_id,
      body: {
        type: "redirect",
        alternative_path: destination,
        locale: "en",
        discard_drafts: true,
      },
    )

    Sidekiq::Testing.inline! do
      Whitehall::PublishingApi.publish_redirect_async(document.content_id, destination)
    end

    assert_requested redirect_request
  end

  test ".publish_gone_async publishes a gone to the Publishing API" do
    document = create(:document)

    gone_request = stub_publishing_api_unpublish(
      document.content_id,
      body: {
        type: "gone",
        locale: "en",
        discard_drafts: true,
      },
    )

    Sidekiq::Testing.inline! do
      Whitehall::PublishingApi.publish_gone_async(document.content_id, nil, nil)
    end

    assert_requested gone_request
  end

  test ".unpublish_async queues a PublishingApiUnpublishingWorker job for the unpublishing" do
    unpublishing = build(:unpublishing, id: 1)
    PublishingApiUnpublishingWorker.expects(:perform_async).with(1)
    Whitehall::PublishingApi.unpublish_async(unpublishing)
  end

  test ".publish handles the specific exception for a worldwide organisation" do
    raises_exception = lambda { |_, _, _|
      body = {
        "error" => {
          "code" => 422,
          "message" => "base path=/world/organisations/uk-science-innovation-network-in-belgium conflicts with content_id=9bb528b1-743c-4ea2-a323-5b1aaf41818b and locale=en",
          "fields" => {
            "base" => [
              "base path=/world/organisations/uk-science-innovation-network-in-belgium conflicts with content_id=9bb528b1-743c-4ea2-a323-5b1aaf41818b and locale=en",
            ],
          },
        },
      }.to_json
      raise GdsApi::HTTPUnprocessableEntity.new(422, body)
    }

    document = create(:worldwide_organisation)
    destination = "/world/organisations/uk-science-innovation-network-in-belgium"

    Services.publishing_api.stub(:publish, raises_exception) do
      assert_nothing_raised do
        Whitehall::PublishingApi.publish(document, destination)
      end
    end
  end

  test ".publish handles the specific exception for an object that isn't a worldwide organisation" do
    raises_exception = lambda { |_, _, _|
      body = {
        "error" => {
          "code" => 422,
          "message" => "base path=/world/organisations/uk-science-innovation-network-in-belgium conflicts with content_id=9bb528b1-743c-4ea2-a323-5b1aaf41818b and locale=en",
          "fields" => {
            "base" => [
              "base path=/world/organisations/uk-science-innovation-network-in-belgium conflicts with content_id=9bb528b1-743c-4ea2-a323-5b1aaf41818b and locale=en",
            ],
          },
        },
      }.to_json
      raise GdsApi::HTTPUnprocessableEntity.new(422, body)
    }

    document = create(:published_publication)
    destination = "/government/people/milli-vanilli"

    Services.publishing_api.stub(:publish, raises_exception) do
      assert_raises Whitehall::UnpublishableInstanceError do
        Whitehall::PublishingApi.publish(document, destination)
      end
    end
  end
end
