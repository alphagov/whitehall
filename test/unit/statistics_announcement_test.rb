require 'test_helper'

class StatisticsAnnouncementTest < ActiveSupport::TestCase
  test 'can set publication type using an ID' do
    announcement = StatisticsAnnouncement.new(publication_type_id: PublicationType::OfficialStatistics.id)

    assert_equal PublicationType::OfficialStatistics, announcement.publication_type
  end

  test 'only statistical publication types are valid' do
    assert build(:statistics_announcement, publication_type_id: PublicationType::OfficialStatistics.id).valid?
    assert build(:statistics_announcement, publication_type_id: PublicationType::NationalStatistics.id).valid?

    announcement = build(:statistics_announcement, publication_type_id: PublicationType::PolicyPaper.id)
    refute announcement.valid?

    assert_match %r[must be a statistical type], announcement.errors[:publication_type_id].first
  end

  test 'when unpublished, a redirect_url is required' do
    announcement = build(:unpublished_statistics_announcement, redirect_url: nil)
    refute announcement.valid?

    assert_match %r[must be provided when unpublishing an announcement], announcement.errors[:redirect_url].first
  end

  test 'when unpublished, a GOV.UK redirect_url is required' do
    announcement = build(:unpublished_statistics_announcement, redirect_url: "https://www.youtube.com")
    refute announcement.valid?

    assert_match %r{must be in the form of https://www.test.gov.uk/example}, announcement.errors[:redirect_url].first
  end

  test 'when unpublished, it cannot redirect to itself' do
    announcement = build(:unpublished_statistics_announcement, slug: "dummy")
    announcement.redirect_url = announcement.public_path
    refute announcement.valid?

    assert_match %r[cannot redirect to itself], announcement.errors[:redirect_url].first
  end

  test 'when unpublished, is valid with a GOV.UK redirect_url' do
    announcement = build(:unpublished_statistics_announcement, redirect_url: "https://www.test.gov.uk/government/statistics")
    assert announcement.valid?
  end

  test 'generates slug from its title' do
    announcement = create(:statistics_announcement, title: 'Beard statistics 2015')
    assert_equal 'beard-statistics-2015', announcement.slug
  end

  test 'must have at least one topic' do
    announcement = build(:statistics_announcement, topics: [])
    refute announcement.valid?
  end

  test 'is search indexable' do
    announcement = create_announcement_with_changes
    expected_indexed_content = {
      'content_id' => announcement.content_id,
      'title' => announcement.title,
      'link' => announcement.public_path,
      'format' => 'statistics_announcement',
      'description' => announcement.summary,
      'organisations' => announcement.organisations.map(&:slug),
      'policy_areas' => announcement.topics.map(&:slug),
      'display_type' => announcement.display_type,
      'slug' => announcement.slug,
      'release_timestamp' => announcement.release_date,
      'statistics_announcement_state' => announcement.state,
      'metadata' => {
        # TODO: the "confirmed" metadata becomes redundant once all entries are
        # updated with a "statistics_announcement_state". Get rid.
        confirmed: announcement.confirmed?,
        display_date: announcement.display_date,
        change_note: announcement.last_change_note,
        previous_display_date: announcement.previous_display_date,
        cancelled_at: announcement.cancelled_at,
        cancellation_reason: announcement.cancellation_reason,
      }
    }

    assert announcement.can_index_in_search?
    assert_equal expected_indexed_content, announcement.search_index
  end

  test 'only valid when associated publication is of a matching type' do
    statistics          = create(:draft_statistics)
    national_statistics = create(:draft_national_statistics)
    policy_paper        = create(:draft_policy_paper)

    announcement = build(:statistics_announcement, publication_type_id: PublicationType::OfficialStatistics.id)

    announcement.publication = statistics
    assert announcement.valid?

    announcement.publication = national_statistics
    refute announcement.valid?
    assert_equal ["type does not match: must be statistics"], announcement.errors[:publication]

    announcement.publication_type_id = PublicationType::NationalStatistics.id
    assert announcement.valid?

    announcement.publication = policy_paper
    refute announcement.valid?
    assert_equal ["type does not match: must be national statistics"], announcement.errors[:publication]
  end

  test ".with_title_containing returns statistics announcements matching provided title" do
    match = create(:statistics_announcement, title: "MQ5 statistics")
    create(:statistics_announcement, title: "PQ6 statistics")

    assert_equal [match], StatisticsAnnouncement.with_title_containing("mq5")
  end

  test '#most_recent_change_note returns the most recent change note' do
    announcement = create_announcement_with_changes

    assert_equal '11 January 2012 9:30am', announcement.reload.display_date
    assert announcement.confirmed?
    assert_equal 'Delayed because of census', announcement.last_change_note
  end

  test '#previous_display_date returns the release date prior to the most recent change note' do
    announcement = create_announcement_with_changes

    assert_equal '11 January 2012 9:30am', announcement.reload.display_date
    assert_equal 'December 2011', announcement.previous_display_date
  end

  test '#build_statistics_announcement_date_change returns a date change based on the current date' do
    announcement = build(:statistics_announcement)
    current_date = announcement.current_release_date
    date_change  = announcement.build_statistics_announcement_date_change

    assert date_change.is_a?(StatisticsAnnouncementDateChange)
    assert_equal announcement, date_change.statistics_announcement
    assert_equal announcement.current_release_date, date_change.current_release_date
    assert_equal current_date.precision, date_change.precision
    assert_equal current_date.release_date, date_change.release_date
    assert_equal current_date.confirmed, date_change.confirmed
  end

  test '#build_statistics_announcement_date_change can override attributes' do
    announcement = build(:statistics_announcement)
    current_date = announcement.current_release_date
    date_change  = announcement.build_statistics_announcement_date_change(change_note: 'Some changes being made')

    assert_equal 'Some changes being made', date_change.change_note
    assert_equal current_date.release_date, date_change.release_date
  end

  test '#cancel! cancels an announcement' do
    announcement = create(:statistics_announcement)
    announcement.cancel!("Reason for cancellation", announcement.creator)

    assert announcement.cancelled?
    assert_equal "Reason for cancellation", announcement.cancellation_reason
    assert_equal announcement.creator, announcement.cancelled_by
    assert_equal Time.zone.now, announcement.cancelled_at
  end

  test 'a cancelled announcement is in a "cancelled" state, even when previously confirmed' do
    announcement = build(:cancelled_statistics_announcement)
    assert_equal "cancelled", announcement.state

    announcement.current_release_date.confirmed = true
    assert_equal "cancelled", announcement.state
  end

  test 'a provisional announcement is in a "provisional" state' do
    announcement = build(:statistics_announcement,
      current_release_date: build(:statistics_announcement_date, confirmed: false))

    assert_equal "provisional", announcement.state
  end

  test 'a confirmed announcement is in a "confirmed" state' do
    announcement = build(:statistics_announcement,
      current_release_date: build(:statistics_announcement_date, confirmed: true))

    assert_equal "confirmed", announcement.state
  end

  test 'cannot cancel without a reason' do
    announcement = create(:statistics_announcement)

    refute announcement.cancel!('', announcement.creator)
    assert_match %r[must be provided when cancelling an announcement], announcement.errors[:cancellation_reason].first
  end

  test "an announcement that has a publiction that is post-publishing is not indexable in search" do
    announcement = create(:statistics_announcement, publication: create(:published_statistics))

    Whitehall::SearchIndex.expects(:add).never
    announcement.update_in_search_index

    announcement.publication.supersede!

    Whitehall::SearchIndex.expects(:add).never
    announcement.update_in_search_index
  end

  test "#organisations returns organisations associated with the statistics announcement" do
    announcement = create(:statistics_announcement)
    organisation = create(:organisation)
    StatisticsAnnouncementOrganisation.create!(statistics_announcement: announcement, organisation: organisation)

    assert_includes announcement.reload.organisations, organisation
  end

  test '#destroy destroys organisation associations' do
    statistics_announcement = create(:statistics_announcement)
    assert_difference %w(StatisticsAnnouncement.count StatisticsAnnouncementOrganisation.count), -1 do
      statistics_announcement.destroy
    end
  end

  test '#destroy destroys topic associations' do
    statistics_announcement = create(:statistics_announcement)
    assert_difference %w(StatisticsAnnouncement.count StatisticsAnnouncementTopic.count), -1 do
      statistics_announcement.destroy
    end
  end

  test 'StatisticsAnnouncement.with_topics scope returns announcements with matching topics' do
    topic_1 = create(:topic)
    topic_2 = create(:topic)
    announcement_1 = create(:statistics_announcement, topics: [topic_1, topic_2])
    announcement_2 = create(:statistics_announcement, topics: [topic_2])

    assert_equal [announcement_1], StatisticsAnnouncement.with_topics(topic_1)
    assert_equal [announcement_1], StatisticsAnnouncement.with_topics(topic_1.id)

    assert_equal [announcement_1, announcement_2],
      StatisticsAnnouncement.with_topics([topic_2])
  end

  test 'requires_redirect? returns true when unpublished?' do
    statistics_announcement = build(
      :statistics_announcement,
      publishing_state: 'unpublished',
    )
    assert statistics_announcement.requires_redirect?
  end

  test 'requires_redirect? returns false when not unpublished?' do
    statistics_announcement = build(
      :statistics_announcement,
      publishing_state: 'published',
      publication: nil,
    )
    refute statistics_announcement.requires_redirect?
  end

  test 'requires_redirect? returns true when when publication is published?' do
    statistics_announcement = build(
      :statistics_announcement,
      publishing_state: 'published',
      publication: build(:published_statistics),
    )
    assert statistics_announcement.requires_redirect?
  end

  test 'requires_redirect? returns false when when publication is draft' do
    statistics_announcement = build(
      :statistics_announcement,
      publishing_state: 'published',
      publication: build(:draft_statistics),
    )
    refute statistics_announcement.requires_redirect?
  end

  test 'publishes to publishing api with a minor update type' do
    edition = create(:statistics_announcement)

    presenter = PublishingApiPresenters.presenter_for(edition)
    requests = [
      stub_publishing_api_put_content(presenter.content_id, presenter.content),
      stub_publishing_api_patch_links(presenter.content_id, links: presenter.links),
      stub_publishing_api_publish(presenter.content_id, update_type: "minor", locale: "en")
    ]

    requests.each { |request| assert_requested request }
  end

private

  def create_announcement_with_changes
    announcement = create(:cancelled_statistics_announcement)
    _first_minor_change = Timecop.travel(1.day) do
      create(:statistics_announcement_date,
              statistics_announcement: announcement,
              release_date: announcement.release_date + 1.week)
    end
    major_change = Timecop.travel(2.days) do
      create(:statistics_announcement_date,
              statistics_announcement: announcement,
              release_date: announcement.release_date + 1.month,
              change_note: 'Delayed because of census')
    end
    _second_minor_change = Timecop.travel(3.days) do
      create(:statistics_announcement_date,
              statistics_announcement: announcement,
              release_date: major_change.release_date,
              precision: StatisticsAnnouncementDate::PRECISION[:exact],
              confirmed: true)
    end

    announcement
  end
end
