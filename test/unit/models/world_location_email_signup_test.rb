require "test_helper"
require "gds_api/test_helpers/email_alert_api"

class WorldLocationEmailSignupTest < ActiveSupport::TestCase
  include GdsApi::TestHelpers::EmailAlertApi

  setup do
    @international_delegation = create(:international_delegation, name: "UK Joint Delegation to NATO")
  end

  test "#slug returns the slug from email-alert-api" do
    email_signup = WorldLocationEmailSignup.new(feed_url)
    response = { "slug" => "some-slug" }

    stub_email_alert_api_creates_subscriber_list(response).with do |request|
      assert_equal("UK Joint Delegation to NATO", JSON.parse(request.body)["title"])
      assert_equal({ "world_locations" => [@international_delegation.content_id] }, JSON.parse(request.body)["links"])
    end

    assert_equal "some-slug", email_signup.slug
  end

  test "#name returns the world locations name" do
    email_signup = WorldLocationEmailSignup.new(feed_url)
    assert_equal "UK Joint Delegation to NATO", email_signup.name
  end

  test "#valid? validates a world location feed url" do
    email_signup = WorldLocationEmailSignup.new(feed_url)
    assert email_signup.valid?
  end

  test "#valid? does not validate a feed url which is invalid" do
    assert_not WorldLocationEmailSignup.new(nil).valid?
  end

  test "#valid? does not validate a feed url when the resource does not exist" do
    assert_not WorldLocationEmailSignup.new(feed_url("/world/does-not-exist")).valid?
  end

  test "#valid? does not validate a feed url which isn't a world location feed" do
    assert_not WorldLocationEmailSignup.new(feed_url("/government/publications/not-world.atom")).valid?
  end

  def feed_url(feed_path = "world/uk-joint-delegation-to-nato.atom")
    "#{Whitehall.public_protocol}://#{Whitehall.public_host}/#{feed_path}"
  end
end
