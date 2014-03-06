require 'test_helper'

class StatisticalReleaseAnnouncementTest < ActiveSupport::TestCase

  test 'can set publication type using an ID' do
    announcement = StatisticalReleaseAnnouncement.new(publication_type_id: PublicationType::Statistics.id)

    assert_equal PublicationType::Statistics, announcement.publication_type
  end

  test 'only statistical publication types are valid' do
    assert build(:statistical_release_announcement, publication_type_id: PublicationType::Statistics.id).valid?
    assert build(:statistical_release_announcement, publication_type_id: PublicationType::NationalStatistics.id).valid?

    announcement = build(:statistical_release_announcement, publication_type_id: PublicationType::PolicyPaper.id)
    refute announcement.valid?

    assert_match /must be a statistical type/, announcement.errors[:publication_type_id].first
  end

  test 'generates slug from its title' do
    announcement = create(:statistical_release_announcement, title: 'Beard statistics 2015')
    assert_equal 'beard-statistics-2015', announcement.slug
  end
end
