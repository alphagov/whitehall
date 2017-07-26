require 'test_helper'

class PublishingApi::StatisticsAnnouncementPresenterTest < ActiveSupport::TestCase
  def present(record)
    PublishingApi::StatisticsAnnouncementPresenter.new(record)
  end

  test "a scheduled statistics announcement presents the correct values" do
    statistics_announcement = create(:statistics_announcement)

    public_path = Whitehall.url_maker.statistics_announcement_path(statistics_announcement)

    expected_content = {
      base_path: public_path,
      description: statistics_announcement.summary,
      title: statistics_announcement.title,
      schema_name: 'statistics_announcement',
      document_type: 'official_statistics_announcement',
      locale: 'en',
      need_ids: [],
      public_updated_at: statistics_announcement.updated_at,
      publishing_app: 'whitehall',
      rendering_app: 'government-frontend',
      routes: [
        { path: public_path, type: 'exact' }
      ],
      redirects: [],
      update_type: "major",
      details: {
        display_date: statistics_announcement.current_release_date.display_date,
        state: statistics_announcement.state,
        format_sub_type: 'official'
      }
    }

    expected_links = {
      organisations: statistics_announcement.organisations.map(&:content_id),
      policy_areas: statistics_announcement.topics.map(&:content_id),
    }

    presented_item = present(statistics_announcement)
    presented_content = presented_item.content

    assert_valid_against_schema(presented_content, 'statistics_announcement')
    assert_valid_against_links_schema({ links: presented_item.links }, 'statistics_announcement')

    assert_equivalent_html expected_content[:details].delete(:body),
      presented_content[:details].delete(:body)

    assert_equal expected_content, presented_content
    assert_hash_includes presented_item.links, expected_links
  end

  test "a cancelled statistics announcement presents the correct values" do
    statistics_announcement = create(:cancelled_statistics_announcement)

    public_path = Whitehall.url_maker.statistics_announcement_path(statistics_announcement)

    expected_content = {
      base_path: public_path,
      description: statistics_announcement.summary,
      title: statistics_announcement.title,
      schema_name: 'statistics_announcement',
      document_type: 'official_statistics_announcement',
      locale: 'en',
      need_ids: [],
      public_updated_at: statistics_announcement.updated_at,
      publishing_app: 'whitehall',
      rendering_app: 'government-frontend',
      routes: [
        { path: public_path, type: 'exact' }
      ],
      redirects: [],
      update_type: "major",
      details: {
        display_date: statistics_announcement.current_release_date.display_date,
        state: statistics_announcement.state,
        format_sub_type: 'official',
        cancelled_at: statistics_announcement.cancelled_at,
        cancellation_reason: 'Cancelled for a reason'
      }
    }

    expected_links = {
      organisations: statistics_announcement.organisations.map(&:content_id),
      policy_areas: statistics_announcement.topics.map(&:content_id),
    }

    presented_item = present(statistics_announcement)
    presented_content = presented_item.content

    assert_valid_against_schema(presented_content, 'statistics_announcement')
    assert_valid_against_links_schema({ links: presented_item.links }, 'statistics_announcement')

    assert_equivalent_html expected_content[:details].delete(:body),
      presented_content[:details].delete(:body)

    assert_equal expected_content, presented_content
    assert_hash_includes presented_item.links, expected_links
  end

  test "a statistics announcement with a date change presents both dates and a notice" do
    statistics_announcement = create(:statistics_announcement,
      previous_display_date: 7.days.from_now,
      change_note: "Reasons")

    public_path = Whitehall.url_maker.statistics_announcement_path(statistics_announcement)

    expected_content = {
      base_path: public_path,
      description: statistics_announcement.summary,
      title: statistics_announcement.title,
      schema_name: 'statistics_announcement',
      document_type: 'official_statistics_announcement',
      locale: 'en',
      need_ids: [],
      public_updated_at: statistics_announcement.updated_at,
      publishing_app: 'whitehall',
      rendering_app: 'government-frontend',
      routes: [
        { path: public_path, type: 'exact' }
      ],
      redirects: [],
      update_type: "major",
      details: {
        display_date: statistics_announcement.current_release_date.display_date,
        previous_display_date: 7.days.from_now.to_s(:date_with_time),
        latest_change_note: "Reasons",
        state: statistics_announcement.state,
        format_sub_type: 'official',
      }
    }

    expected_links = {
      organisations: statistics_announcement.organisations.map(&:content_id),
      policy_areas: statistics_announcement.topics.map(&:content_id),
    }

    presented_item = present(statistics_announcement)
    presented_content = presented_item.content

    assert_valid_against_schema(presented_content, 'statistics_announcement')
    assert_valid_against_links_schema({ links: presented_item.links }, 'statistics_announcement')

    assert_equivalent_html expected_content[:details].delete(:body),
      presented_content[:details].delete(:body)

    assert_equal expected_content, presented_content
    assert_hash_includes presented_item.links, expected_links
  end
end
