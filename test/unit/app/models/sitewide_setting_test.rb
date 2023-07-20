require "test_helper"

class SitewideSettingTest < ActiveSupport::TestCase
  test "toggling reshuffle mode republished the ministers index page" do
    payload = PublishingApi::MinistersIndexPresenter.new

    create(:sitewide_setting, key: :minister_reshuffle_mode, on: true)

    requests = [
      stub_publishing_api_put_content(payload.content_id, payload.content),
      stub_publishing_api_publish(payload.content_id, locale: "en", update_type: nil),
    ]

    assert_all_requested(requests)
  end

  # moved from duplicate file
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
