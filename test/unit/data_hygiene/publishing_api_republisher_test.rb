require 'test_helper'

class DataHygiene::PublishingApiRepublisherTest < ActiveSupport::TestCase
  test "republishes a model to the Publishing API" do
    organisation     = create(:organisation)
    scope            = Organisation.where(id: organisation.id)
    presenter        = PublishingApiPresenters.presenter_for(organisation, update_type: "republish")
    WebMock.reset!

    expected_requests = stub_publishing_api_put_content_links_and_publish(presenter.as_json)

    DataHygiene::PublishingApiRepublisher.new(scope, NullLogger.instance).perform

    assert_all_requested(expected_requests)
  end

end
