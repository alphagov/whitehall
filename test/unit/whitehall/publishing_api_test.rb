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

    draft_payload = PublishingApiPresenters.presenter_for(draft, update_type: "republish").as_json
    published_payload = PublishingApiPresenters.presenter_for(published, update_type: "republish").as_json
    archived_payload  = PublishingApiPresenters.presenter_for(archived, update_type: "republish").as_json

    draft_request     = stub_publishing_api_put_item(draft_payload[:base_path], draft_payload)
    published_request = stub_publishing_api_put_item(published_payload[:base_path], published_payload)
    archived_request  = stub_publishing_api_put_item(archived_payload[:base_path], archived_payload)

    Whitehall::PublishingApi.republish(published)
    Whitehall::PublishingApi.republish(archived)
    assert_raise Whitehall::UnpublishableInstanceError do
      Whitehall::PublishingApi.republish(draft)
    end

    assert_requested published_request
    assert_requested archived_request
    assert_not_requested draft_request
  end

  test "publishes editions that are unpublished" do
    case_study = create(:draft_case_study,
                        title: 'Case study title',
                        first_published_at: Time.zone.now,
                        summary: 'The summary')
    unpublishing = create(:unpublishing, edition: case_study,
                          explanation: 'it is rubbish',
                          alternative_url: 'https://www.test.alphagov.co.uk/foobar')
    payload = PublishingApiPresenters.presenter_for(case_study, update_type: "republish").as_json
    request = stub_publishing_api_put_item(payload[:base_path], payload)

    Whitehall::PublishingApi.republish(case_study)
    assert_requested request
  end
end
