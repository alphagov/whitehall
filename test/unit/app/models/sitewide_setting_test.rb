require "test_helper"

class SitewideSettingTest < ActiveSupport::TestCase
  def setup
    @content_id = "324e4708-2285-40a0-b3aa-cb13af14ec5f"
  end

  test "enabling reshuffle mode republishes custom ministers index and how government work pages" do
    setting = create(:sitewide_setting, key: :minister_reshuffle_mode, on: true)

    Services.publishing_api.expects(:put_content).with(@content_id, PublishingApi::MinistersIndexEnableReshufflePresenter.new.content).once
    Services.publishing_api.expects(:publish).with(@content_id, nil, locale: "en").once
    Services.publishing_api.expects(:put_content).with(@content_id, PublishingApi::MinistersIndexPresenter.new.content).once
    PresentPageToPublishingApiWorker.expects(:perform_async).with("PublishingApi::HowGovernmentWorksEnableReshufflePresenter").once

    setting.republish_downstream_if_reshuffle
  end

  test "disabling reshuffle mode republishes ministers index and how government work pages" do
    setting = create(:sitewide_setting, key: :minister_reshuffle_mode, on: false)

    PresentPageToPublishingApiWorker.expects(:perform_async).with("PublishingApi::HowGovernmentWorksPresenter").once
    Services.publishing_api.expects(:publish).with(@content_id, nil, locale: "en").once

    setting.republish_downstream_if_reshuffle
  end
end
