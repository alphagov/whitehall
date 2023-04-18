require "test_helper"

class SitewideSettingTest < ActiveSupport::TestCase
  test "should send the how government works page to publishing api when reshuffle mode is switched on" do
    PresentPageToPublishingApi.any_instance.expects(:publish).with(PublishingApi::HowGovernmentWorksPresenter)

    create(:sitewide_setting, key: :minister_reshuffle_mode, on: true)
  end

  test "should send the how government works page to publishing api when reshuffle mode is switched off" do
    setting = create(:sitewide_setting, key: :minister_reshuffle_mode, on: true)

    PresentPageToPublishingApi.any_instance.expects(:publish).with(PublishingApi::HowGovernmentWorksPresenter)

    setting.update!(on: false)
  end
end
