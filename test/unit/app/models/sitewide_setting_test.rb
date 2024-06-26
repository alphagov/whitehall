require "test_helper"

class SitewideSettingTest < ActiveSupport::TestCase
  test "enabling reshuffle mode republishes custom ministers index and how government work pages" do
    setting = create(:sitewide_setting, key: :minister_reshuffle_mode, on: true)

    mock_worker = mock
    PresentPageToPublishingApiWorker.stubs(:new).returns(mock_worker)
    mock_worker.expects(:perform).with("PublishingApi::HowGovernmentWorksEnableReshufflePresenter", true).once
    mock_worker.expects(:perform).with("PublishingApi::MinistersIndexEnableReshufflePresenter", true).once
    mock_worker.expects(:perform).with("PublishingApi::MinistersIndexPresenter", false).once

    setting.republish_downstream_if_reshuffle
  end

  test "disabling reshuffle mode republishes ministers index and how government work pages" do
    setting = create(:sitewide_setting, key: :minister_reshuffle_mode, on: false)

    PresentPageToPublishingApiWorker.expects(:perform_async).with("PublishingApi::HowGovernmentWorksPresenter", true).once
    PresentPageToPublishingApiWorker.expects(:perform_async).with("PublishingApi::MinistersIndexPresenter", true).once

    setting.republish_downstream_if_reshuffle
  end
end
