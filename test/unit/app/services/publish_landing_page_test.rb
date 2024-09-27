require "test_helper"

class PublishLandingPageTest < ActiveSupport::TestCase
  test "it assigns a valid content id the first time it publishes the landing_page" do
    pfg_landing_page = JSON.parse(File.read("lib/landing_pages/programme_for_government.json"))

    stub_publishing_api_has_lookups({})
    SecureRandom.stubs(:uuid).returns("a-content-id")

    PublishLandingPage.call(pfg_landing_page)

    assert_publishing_api_put_content("a-content-id", pfg_landing_page)
    assert_publishing_api_publish("a-content-id")
  end

  test "it uses the existing content id when publishing" do
    pfg_landing_page = JSON.parse(File.read("lib/landing_pages/programme_for_government.json"))

    stub_publishing_api_has_lookups("/programme-for-government" => "existing-content-id")

    PublishLandingPage.call(pfg_landing_page)

    assert_publishing_api_put_content("existing-content-id", pfg_landing_page)
    assert_publishing_api_publish("existing-content-id")
  end
end
