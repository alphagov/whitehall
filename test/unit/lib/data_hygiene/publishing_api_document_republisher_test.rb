require "test_helper"

class DataHygiene::PublishingApiDocumentRepublisherTest < ActiveSupport::TestCase
  test "republishes a model to the Publishing API" do
    fatality_notice = create(:published_fatality_notice)
    presenter = PublishingApiPresenters.presenter_for(fatality_notice, update_type: "republish")
    WebMock.reset!

    expected_requests = [
      stub_publishing_api_put_content(presenter.content_id, presenter.content.merge(bulk_publishing: true)),
      stub_publishing_api_patch_links(presenter.content_id, links: presenter.links, bulk_publishing: true),
      stub_publishing_api_publish(presenter.content_id, locale: "en", update_type: nil),
    ]

    Sidekiq::Testing.inline! do
      DataHygiene::PublishingApiDocumentRepublisher.new(FatalityNotice, NullLogger.instance).perform
    end

    assert_all_requested(expected_requests)
  end

  test "rejects a scope if passed in" do
    assert_raise ArgumentError do
      DataHygiene::PublishingApiDocumentRepublisher.new(FatalityNotice.all)
    end
  end

  test "rejects a class that isn't a subclass of Edition" do
    assert_raise ArgumentError do
      DataHygiene::PublishingApiDocumentRepublisher.new(Organisation)
    end
  end
end
