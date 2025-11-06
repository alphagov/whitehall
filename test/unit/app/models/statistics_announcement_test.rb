require "test_helper"

class StatisticsAnnouncementTest < ActiveSupport::TestCase
  test "can set publication type using an ID" do
    announcement = StatisticsAnnouncement.new(publication_type_id: PublicationType::OfficialStatistics.id)

    assert_equal PublicationType::OfficialStatistics, announcement.publication_type
  end

  test "only statistical publication types are valid" do
    assert build(:statistics_announcement, publication_type_id: PublicationType::OfficialStatistics.id).valid?
    assert build(:statistics_announcement, publication_type_id: PublicationType::NationalStatistics.id).valid?

    announcement = build(:statistics_announcement, publication_type_id: PublicationType::PolicyPaper.id)
    assert_not announcement.valid?

    assert_match %r{must be a statistical type}, announcement.errors[:publication_type_id].first
  end

  test "when unpublished, a redirect_url is required" do
    announcement = build(:unpublished_statistics_announcement, redirect_url: nil)
    assert_not announcement.valid?

    assert_match %r{must be provided when unpublishing an announcement}, announcement.errors[:redirect_url].first
  end

  test "when unpublished, a GOV.UK redirect_url is required" do
    announcement = build(:unpublished_statistics_announcement, redirect_url: "https://www.youtube.com")
    assert_not announcement.valid?

    assert_match "is not a GOV.UK URL", announcement.errors[:redirect_url].first
  end

  test "when unpublished, it cannot redirect to itself" do
    announcement = build(:unpublished_statistics_announcement, slug: "dummy")
    announcement.redirect_url = announcement.base_path
    assert_not announcement.valid?

    assert_match %r{cannot redirect to itself}, announcement.errors[:redirect_url].first
  end

  test "when unpublished, is valid with a GOV.UK redirect_url" do
    announcement = build(:unpublished_statistics_announcement, redirect_url: "https://www.test.gov.uk/government/statistics")
    assert announcement.valid?
  end

  test "generates slug from its title" do
    announcement = create(:statistics_announcement, title: "Beard statistics 2015")
    assert_equal "beard-statistics-2015", announcement.slug
  end

  test "is search indexable" do
    announcement = create_announcement_with_changes
    expected_indexed_content = {
      "content_id" => announcement.content_id,
      "title" => announcement.title,
      "link" => announcement.base_path,
      "format" => "statistics_announcement",
      "description" => announcement.summary,
      "organisations" => announcement.organisations.map(&:slug),
      "public_timestamp" => announcement.updated_at,
      "display_date" => announcement.display_date,
      "display_type" => announcement.display_type,
      "slug" => announcement.slug,
      "release_timestamp" => announcement.release_date,
      "statistics_announcement_state" => announcement.state,
      "metadata" => {
        # TODO: the "confirmed" metadata becomes redundant once all entries are
        # updated with a "statistics_announcement_state". Get rid.
        confirmed: announcement.confirmed?,
        display_date: announcement.display_date,
        change_note: announcement.last_change_note,
        previous_display_date: announcement.previous_display_date,
        cancelled_at: announcement.cancelled_at,
        cancellation_reason: announcement.cancellation_reason,
      },
    }

    assert announcement.can_index_in_search?
    assert_equal expected_indexed_content, announcement.search_index
  end

  test ".with_title_containing returns statistics announcements matching provided title" do
    match = create(:statistics_announcement, title: "MQ5 statistics")
    create(:statistics_announcement, title: "PQ6 statistics")

    assert_equal [match], StatisticsAnnouncement.with_title_containing("mq5")
  end

  test "#most_recent_change_note returns the most recent change note" do
    announcement = create_announcement_with_changes

    assert_equal "18 January 2012 9:30am", announcement.reload.display_date
    assert announcement.confirmed?
    assert_equal "Delayed because of census", announcement.last_change_note
  end

  test "#previous_display_date returns the release date prior to the most recent change note" do
    announcement = create_announcement_with_changes

    assert_equal "18 January 2012 9:30am", announcement.reload.display_date
    assert_equal "December 2011", announcement.previous_display_date
  end

  test "#build_statistics_announcement_date_change returns a date change based on the current date" do
    announcement = create(:statistics_announcement)
    current_date = announcement.current_release_date
    date_change  = announcement.build_statistics_announcement_date_change

    assert date_change.is_a?(StatisticsAnnouncementDateChange)
    assert_equal announcement, date_change.statistics_announcement
    assert_equal announcement.current_release_date, date_change.current_release_date
    assert_equal current_date.precision, date_change.precision
    assert_equal current_date.release_date, date_change.release_date
    assert_equal current_date.confirmed, date_change.confirmed
  end

  test "#build_statistics_announcement_date_change can override attributes" do
    announcement = create(:statistics_announcement)
    current_date = announcement.current_release_date
    date_change  = announcement.build_statistics_announcement_date_change(change_note: "Some changes being made")

    assert_equal "Some changes being made", date_change.change_note
    assert_equal current_date.release_date, date_change.release_date
  end

  test "#cancel! cancels an announcement" do
    announcement = create(:statistics_announcement)
    announcement.cancel!("Reason for cancellation", announcement.creator)

    assert announcement.cancelled?
    assert_equal "Reason for cancellation", announcement.cancellation_reason
    assert_equal announcement.creator, announcement.cancelled_by
    assert_equal Time.zone.now, announcement.cancelled_at
  end

  test 'a cancelled announcement is in a "cancelled" state, even when previously confirmed' do
    announcement = create(:cancelled_statistics_announcement)
    assert_equal "cancelled", announcement.state

    announcement.current_release_date.confirmed = true
    assert_equal "cancelled", announcement.state
  end

  test 'a provisional announcement is in a "provisional" state' do
    announcement = build(
      :statistics_announcement,
      current_release_date: build(:statistics_announcement_date, confirmed: false),
    )

    assert_equal "provisional", announcement.state
  end

  test 'a confirmed announcement is in a "confirmed" state' do
    announcement = build(
      :statistics_announcement,
      current_release_date: build(:statistics_announcement_date, confirmed: true),
    )

    assert_equal "confirmed", announcement.state
  end

  test "cannot cancel without a reason" do
    announcement = create(:statistics_announcement)

    assert_not announcement.cancel!("", announcement.creator)
    assert_match %r{must be provided when cancelling an announcement}, announcement.errors[:cancellation_reason].first
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
    StatisticsAnnouncementOrganisation.create!(statistics_announcement: announcement, organisation:)

    assert_includes announcement.reload.organisations, organisation
  end

  test "#destroy destroys organisation associations" do
    statistics_announcement = create(:statistics_announcement)
    assert_difference %w[StatisticsAnnouncement.count StatisticsAnnouncementOrganisation.count], -1 do
      statistics_announcement.destroy
    end
  end

  test "requires_redirect? returns true when unpublished?" do
    statistics_announcement = build(
      :statistics_announcement,
      publishing_state: "unpublished",
    )
    assert statistics_announcement.requires_redirect?
  end

  test "requires_redirect? returns false when not unpublished?" do
    statistics_announcement = build(
      :statistics_announcement,
      publishing_state: "published",
      publication: nil,
    )
    assert_not statistics_announcement.requires_redirect?
  end

  test "requires_redirect? returns true when when publication is published?" do
    statistics_announcement = build(
      :statistics_announcement,
      publishing_state: "published",
      publication: build(:published_statistics),
    )
    assert statistics_announcement.requires_redirect?
  end

  test "requires_redirect? returns false when when publication is draft" do
    statistics_announcement = build(
      :statistics_announcement,
      publishing_state: "published",
      publication: build(:draft_statistics),
    )
    assert_not statistics_announcement.requires_redirect?
  end

  test "publishes to publishing api with a minor update type" do
    Sidekiq::Testing.inline! do
      edition = create(:statistics_announcement)

      presenter = PublishingApiPresenters.presenter_for(edition)
      requests = [
        stub_publishing_api_put_content(presenter.content_id, presenter.content),
        stub_publishing_api_patch_links(presenter.content_id, links: presenter.links),
        stub_publishing_api_publish(presenter.content_id, locale: "en", update_type: nil),
      ]

      requests.each { |request| assert_requested request }
    end
  end

  test "display type translates correctly for languages which do and don't use singular nouns" do
    locales_and_expected_translations = {
      de: "document.type.official_statistics.one",
      zh: "document.type.official_statistics.other",
    }
    locales_and_expected_translations.each do |locale, expected_translation_path|
      with_locale(locale) do
        speech = create(:statistics_announcement)
        assert_equal I18n.t(expected_translation_path), speech.display_type
      end
    end
  end

  test "updates the statistics_announcements current_release_date_id to the most recently created statistics_announcement_dates id" do
    statistics_announcement = create(:statistics_announcement)
    assert_equal statistics_announcement.statistics_announcement_dates.first.id, statistics_announcement.reload.current_release_date_id

    statistics_announcement_date2 = create(:statistics_announcement_date, statistics_announcement:)

    assert_equal statistics_announcement_date2.id, statistics_announcement.reload.current_release_date_id

    statistics_announcement_date3 = create(:statistics_announcement_date, statistics_announcement:)

    assert_equal statistics_announcement_date3.id, statistics_announcement.reload.current_release_date_id
  end

  test "only valid when associated publication is of a matching type" do
    statistics          = create(:draft_statistics)
    national_statistics = create(:draft_national_statistics)
    policy_paper        = create(:draft_policy_paper)

    announcement = build(:statistics_announcement, publication_type_id: PublicationType::OfficialStatistics.id)

    announcement.publication = statistics
    assert announcement.valid?

    announcement.publication = national_statistics
    assert_not announcement.valid?
    assert_equal ["type does not match announcement type: must be 'Official Statistics'"], announcement.errors[:publication]

    announcement.publication_type_id = PublicationType::NationalStatistics.id
    assert announcement.valid?

    announcement.publication = policy_paper
    assert_not announcement.valid?
    assert_equal ["type does not match announcement type: must be 'Accredited Official Statistics'"], announcement.errors[:publication]
  end

  test "deleting statistics announcement does not delete publication" do
    national_statistics = create(:draft_national_statistics, title: "Test")
    announcement = create(:statistics_announcement, publication_type_id: PublicationType::NationalStatistics.id, publication: national_statistics)

    announcement.delete
    assert_equal Publication.find(national_statistics.id).title, "Test"
    assert_equal StatisticsAnnouncement.where(id: announcement.id).count, 0
  end

  # === BEGIN: Publication Type update callback ===
  test "should update publication type when there's no connected publication" do
    announcement = create(:statistics_announcement, publication_type_id: PublicationType::OfficialStatistics.id)

    announcement.publication_type_id = PublicationType::NationalStatistics.id
    announcement.save!

    assert announcement.valid?
    assert announcement.errors.empty?
  end

  test "should update with same publication type when there's a connected draft publication" do
    national_statistics = create(:draft_national_statistics)
    announcement = create(:statistics_announcement, publication_type_id: PublicationType::NationalStatistics.id, publication: national_statistics)

    announcement.assign_attributes(
      publication_type_id: PublicationType::NationalStatistics.id,
      title: "New title",
    )
    announcement.save!

    assert announcement.valid?
    assert announcement.errors.empty?
    assert_equal PublicationType::NationalStatistics.id, national_statistics.reload.publication_type_id
  end

  test "should update with a different publication type and update publication when there's a connected draft publication" do
    national_statistics = create(:draft_national_statistics)
    announcement = create(:statistics_announcement, publication_type_id: PublicationType::NationalStatistics.id, publication: national_statistics)

    announcement.assign_attributes(
      publication_type_id: PublicationType::OfficialStatistics.id,
      title: "New title",
    )
    announcement.save!

    assert announcement.valid?
    assert announcement.errors.empty?
    assert_equal PublicationType::OfficialStatistics.id, national_statistics.reload.publication_type_id
  end

  test "should not create new announcement with publication of mismatched Publication type" do
    national_statistics = create(:draft_national_statistics)
    announcement = build(:statistics_announcement, publication_type_id: PublicationType::OfficialStatistics.id, publication: national_statistics)

    assert_not announcement.save
    assert_equal 1, announcement.errors.count
    assert announcement.errors[:publication].include? "type does not match announcement type: must be 'Official Statistics'"
    assert_equal PublicationType::NationalStatistics.id, national_statistics.reload.publication_type_id
  end

  test "should not update Publication type nor update publication when connected publication is published" do
    national_statistics = create(:published_national_statistics)
    announcement = create(:statistics_announcement, publication_type_id: PublicationType::NationalStatistics.id, publication: national_statistics)

    announcement.assign_attributes(
      publication_type_id: PublicationType::OfficialStatistics.id,
      title: "New title",
    )

    assert_not announcement.save
    assert_equal 1, announcement.errors.count
    assert_equal announcement.errors.first.full_message, "Publication type cannot be modified when edition is in the published state"
    assert_equal PublicationType::NationalStatistics.id, national_statistics.reload.publication_type_id
  end
  # === END: Publication Type update callback ===

private

  def create_announcement_with_changes
    announcement = create(:cancelled_statistics_announcement)
    _first_minor_change = Timecop.travel(1.day) do
      create(
        :statistics_announcement_date,
        statistics_announcement: announcement,
        release_date: announcement.release_date + 1.week,
      )
    end
    major_change = Timecop.travel(2.days) do
      create(
        :statistics_announcement_date,
        statistics_announcement: announcement,
        release_date: announcement.release_date + 1.month,
        change_note: "Delayed because of census",
      )
    end
    _second_minor_change = Timecop.travel(3.days) do
      create(
        :statistics_announcement_date,
        statistics_announcement: announcement,
        release_date: major_change.release_date,
        precision: StatisticsAnnouncementDate::PRECISION[:exact],
        confirmed: true,
      )
    end

    announcement
  end
end
