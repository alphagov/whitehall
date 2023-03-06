require "test_helper"

class SitewideSettingTest < ActiveSupport::TestCase
  test "should send the how government works page to publishing api when reshuffle mode is switched on" do
    PublishHowGovernmentWorksPage.any_instance.expects(:publish)

    create(:sitewide_setting, key: :minister_reshuffle_mode, on: true)
  end

  test "should send the how government works page to publishing api when reshuffle mode is switched off" do
    setting = create(:sitewide_setting, key: :minister_reshuffle_mode, on: true)

    PublishHowGovernmentWorksPage.any_instance.expects(:publish)

    setting.update!(on: false)
  end
end
