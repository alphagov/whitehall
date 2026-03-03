require "test_helper"

class PresentPageToPublishingApiJobTest < ActiveSupport::TestCase
  test "instantiates an instance of PresentPageToPublishingApi and calls #publish" do
    service = mock
    PresentPageToPublishingApi.expects(:new).returns(service)

    service.expects(:publish).with(PublishingApi::HowGovernmentWorksPresenter)

    PresentPageToPublishingApiWorker.new.perform("PublishingApi::HowGovernmentWorksPresenter")
  end
end
