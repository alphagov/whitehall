require 'test_helper'

class PublishingApiPresenters::StatisticsAnnouncementTest < ActiveSupport::TestCase
  def present(record)
    PublishingApiPresenters::StatisticsAnnouncement.new(record)
  end

  test "statistics announcement presents the correct values" do
    statistics_announcement = create(:statistics_announcement)

    expected = {
      content_id: statistics_announcement.content_id,
      base_path: statistics_announcement.slug,
      description: statistics_announcement.summary,
      title: statistics_announcement.title,
      format: 'statistics_announcement',
      locale: 'en',
      need_ids: [],
      public_updated_at: statistics_announcement.updated_at,
      publishing_app: 'whitehall',
      rendering_app: 'whitehall-frontend',
      details: {
        display_date: statistics_announcement.current_release_date.display_date,
        state: statistics_announcement.state,
        format_sub_type: 'official'
      },
      links: {
        organisations: statistics_announcement.organisations.map(&:content_id),
        policy_areas: statistics_announcement.topics.map(&:content_id),
        topics: [],
      }
    }

    presented = present(statistics_announcement)

    assert_valid_against_schema(presented.content, 'statistics_announcement')
    assert_valid_against_links_schema({ links: presented.links }, 'statistics_announcement')

    assert_equal expected[:details], presented.content[:details].except(:body)
    assert_equal expected[:links], presented.links
  end
end
