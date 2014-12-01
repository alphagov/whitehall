require 'test_helper'
require 'gds_api/test_helpers/publishing_api'

class PublishingApiWorkerTest < ActiveSupport::TestCase
  include GdsApi::TestHelpers::PublishingApi

  test "registers an edition with the publishing api" do
    edition   = create(:published_detailed_guide)
    presenter = PublishingApiPresenters.presenter_for(edition)
    stub_publishing_api_put_item(presenter.base_path, presenter.as_json)

    PublishingApiWorker.new.perform(edition.class.name, edition.id)

    assert_publishing_api_put_item(presenter.base_path,
      JSON.parse(presenter.as_json.to_json))
  end

  test "registers case studies with their own presenter" do
    edition   = create(:published_case_study)
    presenter = PublishingApiPresenters.presenter_for(edition)
    stub_publishing_api_put_item(presenter.base_path, presenter.as_json)

    PublishingApiWorker.new.perform(edition.class.name, edition.id)

    assert_publishing_api_put_item(presenter.base_path,
      JSON.parse(presenter.as_json.to_json))
  end

  test "registers an organisation with the publishing api" do
    organisation = create(:organisation)
    presenter    = PublishingApiPresenters.presenter_for(organisation)

    # We need to reset because registration happens on create above
    WebMock.reset!
    stub_publishing_api_put_item(presenter.base_path, presenter.as_json)

    PublishingApiWorker.new.perform(organisation.class.name, organisation.id)

    assert_publishing_api_put_item(
      presenter.base_path,
      JSON.parse(presenter.as_json.to_json)
    )
  end

  test "passes the update_type option to the presenter" do
    update_type = "republish"

    edition   = create(:published_detailed_guide)
    presenter = PublishingApiPresenters.presenter_for(edition, update_type: update_type)

    stub_publishing_api_put_item(presenter.base_path, presenter.as_json)

    PublishingApiWorker.new.perform(edition.class.name, edition.id, update_type)

    assert_publishing_api_put_item(
      presenter.base_path,
      JSON.parse(presenter.as_json.to_json)
    )

    assert_equal 'republish', presenter.as_json[:update_type]
  end

  test "allows the locale to be overridden" do
    organisation = create(:organisation)
    presenter = PublishingApiPresenters.presenter_for(organisation)

    I18n.with_locale(:es) do
      organisation.name = "Spanish name"
      organisation.save!

      @spanish_request = stub_publishing_api_put_item(presenter.base_path, presenter.as_json)
    end

    PublishingApiWorker.new.perform(organisation.class.name, organisation.id, nil, 'es')

    assert_requested @spanish_request
  end
end
