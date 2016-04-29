require 'test_helper'

class PublishingApiPresenters::StatisticsAnnouncementTest < ActiveSupport::TestCase
  def present(record)
    PublishingApiPresenters::StatisticsAnnouncement.new(record)
  end

  test "a scheduled statistics announcement presents the correct values" do
    statistics_announcement = create(:statistics_announcement)

    expected = {
      content_id: statistics_announcement.content_id,
      base_path: statistics_announcement.slug,
      description: statistics_announcement.summary,
      title: statistics_announcement.title,
      schema_name: 'statistics_announcement',
      document_type: 'official',
      locale: 'en',
      need_ids: [],
      public_updated_at: statistics_announcement.updated_at,
      publishing_app: 'whitehall',
      rendering_app: 'government-frontend',
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

  test "a cancelled statistics announcement presents the correct values" do
    statistics_announcement = create(:cancelled_statistics_announcement)

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
      rendering_app: 'government-frontend',
      details: {
        display_date: statistics_announcement.current_release_date.display_date,
        state: statistics_announcement.state,
        format_sub_type: 'official',
        cancelled_at: statistics_announcement.cancelled_at,
        cancellation_reason: 'Cancelled for a reason'
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

  test "a statistics announcement with a date change presents both dates and a notice" do
    statistics_announcement = create(:statistics_announcement,
      previous_display_date: 7.days.from_now,
      change_note: "Reasons")

    expected = {
      content_id: statistics_announcement.content_id,
      base_path: statistics_announcement.slug,
      description: statistics_announcement.summary,
      title: statistics_announcement.title,
      schema_name: 'statistics_announcement',
      document_type: 'official',
      locale: 'en',
      need_ids: [],
      public_updated_at: statistics_announcement.updated_at,
      publishing_app: 'whitehall',
      rendering_app: 'government-frontend',
      details: {
        display_date: statistics_announcement.current_release_date.display_date,
        previous_display_date: 7.days.from_now.to_s(:date_with_time),
        latest_change_note: "Reasons",
        state: statistics_announcement.state,
        format_sub_type: 'official',
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
