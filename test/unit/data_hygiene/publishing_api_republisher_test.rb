require 'test_helper'

class DataHygiene::PublishingApiRepublisherTest < ActiveSupport::TestCase
  test "republishes a model to the Publishing API" do
    organisation     = create(:organisation)
    scope            = Organisation.where(id: organisation.id)
    presenter        = PublishingApiPresenters.presenter_for(organisation, update_type: "republish")
    WebMock.reset!

    expected_request = stub_publishing_api_put_item(presenter.base_path, presenter.as_json)

    DataHygiene::PublishingApiRepublisher.new(scope, NullLogger.instance).perform

    assert_requested expected_request
  end

  test "skips editions that are not publically visible" do
    draft     = create(:draft_edition)
    published = create(:published_edition)
    archived  = create(:published_edition, state: 'archived')

    draft_payload = PublishingApiPresenters.presenter_for(draft, update_type: "republish").as_json
    published_payload = PublishingApiPresenters.presenter_for(published, update_type: "republish").as_json
    archived_payload  = PublishingApiPresenters.presenter_for(archived, update_type: "republish").as_json

    draft_request     = stub_publishing_api_put_item(draft_payload[:base_path], draft_payload)
    published_request = stub_publishing_api_put_item(published_payload[:base_path], published_payload)
    archived_request  = stub_publishing_api_put_item(archived_payload[:base_path], archived_payload)

    DataHygiene::PublishingApiRepublisher.new(Edition.where(true), NullLogger.instance).perform

    assert_requested published_request
    assert_requested archived_request
    assert_not_requested draft_request
  end
end
