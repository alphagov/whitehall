require "test_helper"

module PublishingApiPresenters
  class StatisticsAnnouncementRedirectTest < ActiveSupport::TestCase
    test "#content returns a redirect representation" do
      statistics_announcement = create(
        :statistics_announcement, redirect_url: "https://www.test.alphagov.co.uk/example"
      )

      expected_hash = {
        base_path: statistics_announcement.base_path,
        format: "redirect",
        publishing_app: "whitehall",
        redirects: [
          {
            path: statistics_announcement.base_path,
            type: "exact",
            destination: "/example"
          },
        ],
      }

      presenter = StatisticsAnnouncementRedirect.new(statistics_announcement)

      assert_equal expected_hash, presenter.content
      assert_valid_against_schema(presenter.content, "redirect")
    end

    test "#content uses the publication url for the redirect if the associated
      publication is published" do
      published_statistics = create(:published_statistics)
      statistics_announcement = create(
        :statistics_announcement,
        publication: published_statistics
      )

      expected_hash = {
        base_path: statistics_announcement.base_path,
        format: "redirect",
        publishing_app: "whitehall",
        redirects: [
          {
            path: statistics_announcement.base_path,
            type: "exact",
            destination: Whitehall.url_maker.public_document_path(published_statistics)
          },
        ],
      }

      presenter = StatisticsAnnouncementRedirect.new(statistics_announcement)

      assert_equal expected_hash, presenter.content
    end

    test "#content_id is a newly created random uuid" do
      statistics_announcement = build(:statistics_announcement)
      uuid = SecureRandom.uuid
      SecureRandom.stubs(:uuid).returns(uuid)

      presenter = StatisticsAnnouncementRedirect.new(statistics_announcement)
      assert_equal uuid, presenter.content_id
    end
  end
end
