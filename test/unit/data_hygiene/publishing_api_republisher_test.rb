require 'test_helper'

class DataHygiene::PublishingApiRepublisherTest < ActiveSupport::TestCase
  setup do
    @organisation = create(:organisation)
    @scope = Organisation.where(id: @organisation.id)
  end

  test "republishes a model to the Publishing API" do
    presenter = PublishingApiPresenters.presenter_for(@organisation, update_type: "republish")
    WebMock.reset!

    expected_requests = [
      stub_publishing_api_put_content(presenter.content_id, presenter.content),
      stub_publishing_api_patch_links(presenter.content_id, links: presenter.links),
      stub_publishing_api_publish(presenter.content_id, locale: 'en', update_type: 'republish')
    ]

    Sidekiq::Testing.inline! do
      DataHygiene::PublishingApiRepublisher.new(@scope, NullLogger.instance).perform
    end

    assert_all_requested(expected_requests)
  end

  test "uses bulk_republish_async" do
    Whitehall::PublishingApi.expects(:bulk_republish_async).with(@organisation)
    DataHygiene::PublishingApiRepublisher.new(@scope, NullLogger.instance).perform
  end
end
