require "test_helper"

module PublishingApi
  module PayloadBuilder
    class SocialMediaLinksTest < ActiveSupport::TestCase
      test "returns empty hash when item has no social_media_accounts method" do
        item = stub

        assert_equal({}, SocialMediaLinks.for(item))
      end

      test "returns empty social_media_links when item has no social media accounts" do
        item = stub(social_media_accounts: [])

        assert_equal({ social_media_links: [] }, SocialMediaLinks.for(item))
      end

      test "returns social_media_links when item has social media accounts" do
        social_media_account = stub(
          url: "https://instagram.com/example",
          service_name: "Instagram",
          display_name: "Example Instagram Account",
        )
        item = stub(social_media_accounts: [social_media_account])

        expected = {
          social_media_links: [
            {
              href: "https://instagram.com/example",
              service_type: "instagram",
              title: "Example Instagram Account",
            },
          ],
        }

        assert_equal(expected, SocialMediaLinks.for(item))
      end

      test "returns multiple social media links" do
        first_account = stub(
          url: "https://instagram.com/example",
          service_name: "Instagram",
          display_name: "Example Instagram",
        )
        second_account = stub(
          url: "https://youtube.com/example",
          service_name: "YouTube",
          display_name: "Example YouTube",
        )
        item = stub(social_media_accounts: [first_account, second_account])

        result = SocialMediaLinks.for(item)

        assert_equal 2, result[:social_media_links].length
        assert_equal "instagram", result[:social_media_links][0][:service_type]
        assert_equal "youtube", result[:social_media_links][1][:service_type]
      end
    end
  end
end
