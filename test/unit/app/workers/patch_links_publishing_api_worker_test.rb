require "test_helper"

class PatchLinksPublishingApiWorkerTest < ActiveSupport::TestCase
  test "instantiates an instance of PresentPageToPublishingApi and calls #patch_links" do
    service = mock
    PresentPageToPublishingApi.expects(:new).returns(service)

    service.expects(:patch_links).with(PublishingApi::HowGovernmentWorksPresenter)

    PatchLinksPublishingApiWorker.new.perform("PublishingApi::HowGovernmentWorksPresenter")
  end
end
