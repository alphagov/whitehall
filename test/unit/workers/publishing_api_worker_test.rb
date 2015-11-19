require 'test_helper'
require 'gds_api/test_helpers/publishing_api_v2'

class PublishingApiWorkerTest < ActiveSupport::TestCase
  include GdsApi::TestHelpers::PublishingApiV2

  test "registers an edition with the publishing api" do
    edition         = create(:published_detailed_guide)
    presenter       = PublishingApiPresenters.presenter_for(edition)
    requests        = stub_publishing_api_put_content_links_and_publish(presenter.as_json)

    PublishingApiWorker.new.perform(edition.class.name, edition.id)

    requests.each { |request| assert_requested request }
  end

  test "registers case studies with their own presenter" do
    edition         = create(:published_case_study)
    presenter       = PublishingApiPresenters.presenter_for(edition)
    requests        = stub_publishing_api_put_content_links_and_publish(presenter.as_json)

    PublishingApiWorker.new.perform(edition.class.name, edition.id)

    requests.each { |request| assert_requested request }
  end

  test "registers an organisation with the publishing api" do
    organisation = create(:organisation)
    presenter    = PublishingApiPresenters.presenter_for(organisation)

    requests      = stub_publishing_api_put_content_links_and_publish(presenter.as_json)

    PublishingApiWorker.new.perform(organisation.class.name, organisation.id)

    requests.each { |request| assert_requested request }
  end

  test "fails gracefully if the model cannot be found" do
    PublishingApiWorker.new.perform('Edition', non_existant_id = 12)
  end

  test "passes the update_type option to the presenter" do
    update_type = "republish"

    edition         = create(:published_detailed_guide)
    presenter       = PublishingApiPresenters.presenter_for(edition, update_type: update_type)
    requests        = stub_publishing_api_put_content_links_and_publish(presenter.as_json)
    payload         = presenter.as_json
    content_request = stub_publishing_api_put_content(payload[:content_id], payload)
    publish_request = stub_publishing_api_publish(payload[:content_id], { update_type: { locale: "en", update_type: "republish" } })

    PublishingApiWorker.new.perform(edition.class.name, edition.id, update_type)

    assert_requested content_request
    assert_requested publish_request
  end

  test "allows the locale to be overridden" do
    organisation = create(:organisation)
    presenter = PublishingApiPresenters.presenter_for(organisation)

    I18n.with_locale(:es) do
      organisation.name = "Spanish name"
      organisation.save!

      @spanish_request = stub_publishing_api_put_content(presenter.as_json[:content_id], presenter.as_json)
      @publish_request = stub_publishing_api_publish(presenter.as_json[:content_id], { update_type: { locale: "es", update_type: "major" } })
    end

    PublishingApiWorker.new.perform(organisation.class.name, organisation.id, nil, 'es')

    assert_requested @spanish_request
    assert_requested @publish_request
  end
end
