require "test_helper"

class TopicalEventSocialMediaLinkTest < ActiveSupport::TestCase
  def setup
    @social_media_link = TopicalEvent::SocialMediaLink.new
    ConfigurableDocumentType.instance_variable_set(:@types, nil)
  end

  test "block_content includes legacy social media accounts when json is empty" do
    event = create(:topical_event, block_content: { "body" => "Something" })

    twitter_service = create(:social_media_service, name: "Twitter")
    create(:social_media_account, socialable: event, social_media_service: twitter_service, url: "https://twitter.com/legacy", title: "Legacy Twitter")

    event.reload

    assert_equal 1, event.block_content.social_media_links.count
    link = event.block_content.social_media_links.first
    assert_equal "twitter", link["social_media_service_id"]
    assert_equal "https://twitter.com/legacy", link["url"]
  end

  test "block_content prefers existing json content over legacy" do
    create(:social_media_service, name: "Twitter")

    event = create(:topical_event, block_content: {
      "body" => "Something",
      "social_media_links" => [{ "social_media_service_id" => "twitter", "url" => "https://twitter.com/real" }],
    })

    create(:social_media_account, socialable: event, social_media_service: SocialMediaService.find_by(name: "Twitter"), url: "https://twitter.com/legacy", title: "Legacy Twitter")

    assert_equal 1, event.block_content.social_media_links.count
    link = event.block_content.social_media_links.first
    assert_equal "twitter", link["social_media_service_id"]
    assert_equal "https://twitter.com/real", link["url"]
  end

  test "social_media_accounts reader serves from block_content" do
    create(:social_media_service, name: "Twitter", id: "twitter")

    event = create(:topical_event, block_content: {
      "social_media_links" => [{ "social_media_service_id" => "twitter", "url" => "https://twitter.com/new" }],
    })

    create(:social_media_account, socialable: event, social_media_service: create(:social_media_service, name: "Facebook"))

    assert_equal 1, event.social_media_accounts.size
    link = event.social_media_accounts.first
    assert_kind_of TopicalEvent::SocialMediaLink, link
    assert_equal "twitter", link.social_media_service_id
    assert_equal "https://twitter.com/new", link.url

    link.url = "bad-url"
    assert_not link.valid?
    assert_match(/is not a valid URI/, link.errors[:url].first)

    link.url = "http://"
    assert_not link.valid?
    assert_match(/is not a valid URI/, link.errors[:url].first)

    link.url = "https://good-url.com"
    link.social_media_service_id = "twitter"
    assert link.valid?
  end

  test "validator adds errors to social_media_accounts attribute" do
    event = create(:topical_event)
    event.social_media_accounts_attributes = { "0" => { "social_media_service_id" => "twitter", "url" => "" } }

    assert_not event.valid?
    assert_includes event.errors[:base], "Social media links cannot be blank"
  end
end
