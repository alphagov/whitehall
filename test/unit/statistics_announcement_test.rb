require 'test_helper'

class StatisticsAnnouncementTest < ActiveSupport::TestCase

  test 'can set publication type using an ID' do
    announcement = StatisticsAnnouncement.new(publication_type_id: PublicationType::Statistics.id)

    assert_equal PublicationType::Statistics, announcement.publication_type
  end

  test 'only statistical publication types are valid' do
    assert build(:statistics_announcement, publication_type_id: PublicationType::Statistics.id).valid?
    assert build(:statistics_announcement, publication_type_id: PublicationType::NationalStatistics.id).valid?

    announcement = build(:statistics_announcement, publication_type_id: PublicationType::PolicyPaper.id)
    refute announcement.valid?

    assert_match /must be a statistical type/, announcement.errors[:publication_type_id].first
  end

  test 'generates slug from its title' do
    announcement = create(:statistics_announcement, title: 'Beard statistics 2015')
    assert_equal 'beard-statistics-2015', announcement.slug
  end

  test 'is search indexable' do
    announcement   = create(:statistics_announcement)
    expected_indexed_content = {
      'title' => announcement.title,
      'link' => announcement.public_path,
      'format' => 'statistics_announcement',
      'description' => announcement.summary,
      'organisations' => [announcement.organisation.slug],
      'topics' => [announcement.topic.slug],
      'display_type' => announcement.display_type,
      'slug' => announcement.slug,
      'release_timestamp' => announcement.release_date,
      'metadata' => {
        confirmed: announcement.confirmed_date?,
        display_date: announcement.display_date,
        change_note: announcement.change_note
      }
    }

    assert announcement.can_index_in_search?
    assert_equal expected_indexed_content, announcement.search_index
  end

  test 'is indexed for search after being saved' do
    assert_indexed_for_search create(:statistics_announcement)
  end

  test 'is removed from search after being deleted' do
    announcement = create(:statistics_announcement)
    announcement.destroy

    assert_deleted_from_search_index announcement
  end

  test 'only valid when associated publication is a statistical publications' do
    announcement = build(:statistics_announcement)

    announcement.publication = create(:draft_national_statistics)
    assert announcement.valid?

    announcement.publication = create(:published_statistics)
    assert announcement.valid?

    announcement.publication = create(:draft_policy_paper)
    refute announcement.valid?
    assert_equal ["must be statistics"], announcement.errors[:publication]
  end
end
