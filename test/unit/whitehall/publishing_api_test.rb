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
end
