require "test_helper"

class PresentPageToPublishingApiWorkerTest < ActiveSupport::TestCase
  test "instantiates an instance of PresentPageToPublishingApi and calls #publish" do
    service = mock
    PresentPageToPublishingApi.expects(:new).returns(service)

    service.expects(:publish).with(PublishingApi::HowGovernmentWorksPresenter)

    PresentPageToPublishingApiWorker.new.perform("PublishingApi::HowGovernmentWorksPresenter")
  end

  test "calls `save_draft` method when `update_live` parameter is false" do
    service = mock
    PresentPageToPublishingApi.expects(:new).returns(service)

    service.expects(:save_draft).with(PublishingApi::HowGovernmentWorksPresenter)

    PresentPageToPublishingApiWorker.new.perform("PublishingApi::HowGovernmentWorksPresenter", false)
  end
end
