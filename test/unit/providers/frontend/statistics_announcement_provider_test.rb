class Frontend::StatisticsAnnouncementProviderTest < ActiveSupport::TestCase
  attr_accessor :rummager_api_stub

  setup do
    @mock_source = mock
    Whitehall.stubs(:statistics_announcement_search_client).returns(@mock_source)
  end

  test "#search: page and per_page params are converted to strings" do
    @mock_source.expects(:advanced_search).with {|actual|
      actual[:page] == '2' &&
      actual[:per_page] == '10'
    }.returns({'total' => 0, 'results' => []})
    Frontend::StatisticsAnnouncementProvider.search(page: 2, per_page: 10)
  end

  test "#search: from_date and to_date are moved to release_timestamp[:from] and release_timestamp[:to] and are formatted as iso8601" do
    from_date = 1.day.from_now
    to_date = 1.year.from_now
    @mock_source.expects(:advanced_search).with {|actual|
      actual[:release_timestamp] == {from: from_date.iso8601, to: to_date.iso8601} &&
      actual[:from_date].nil? &&
      actual[:to_date].nil?
    }.returns({'total' => 0, 'results' => []})
    Frontend::StatisticsAnnouncementProvider.search(from_date: from_date, to_date: to_date, page: 2, per_page: 10)
  end

  test "#search adds in the paramater format=statistics_announcement" do
    @mock_source.expects(:advanced_search).with {|actual|
      actual[:format] == "statistics_announcement"
    }.returns({'total' => 0, 'results' => []})
    Frontend::StatisticsAnnouncementProvider.search(page: 2, per_page: 10)
  end

  test "#search adds in the paramater order={release_timestamp: 'asc'" do
    @mock_source.expects(:advanced_search).with {|actual|
      actual[:order][:release_timestamp] == 'asc'
    }.returns({'total' => 0, 'results' => []})
    Frontend::StatisticsAnnouncementProvider.search(page: 2, per_page: 10)
  end

  test "#search: release announcments are inflated from rummager hashes" do
    organisation = create(:organisation, name: 'Cabinet Office', slug: 'cabinet-office')
    topic = create(:topic, name: 'Home affairs', slug: 'home-affairs')

    @mock_source.stubs(:advanced_search).returns('total' => 1, 'results' => [{
      "title" => "A title",
      "description" => "The summary",
      "slug" => "a-slug",
      "release_timestamp" => Time.zone.now,
      "organisations" => ["cabinet-office"],
      "topics" => ["home-affairs"],
      "display_type" => "Statistics",
      "search_format_types" => ["statistics_announcement"],
      "format" => "statistics_announcement",
      "statistics_announcement_state" => "cancelled",
      "metadata" => {
        "display_date" => "About now",
        "confirmed" => false,
        "change_note" => "Change is good",
        "previous_display_date" => 1.year.ago,
        "cancellation_reason" => "Cancel reason",
        "cancelled_at" => 1.week.ago,
      }
    }])

    release_announcement = Frontend::StatisticsAnnouncementProvider.search({page: 1, per_page: 10}).first

    assert_equal "A title",        release_announcement.title
    assert_equal "a-slug",         release_announcement.slug
    assert_equal "The summary",    release_announcement.summary
    assert_equal "Statistics",     release_announcement.document_type
    assert_equal Time.zone.now,    release_announcement.release_date
    assert_equal "About now",      release_announcement.display_date
    assert_equal false,            release_announcement.release_date_confirmed
    assert_equal "Change is good", release_announcement.release_date_change_note
    assert_equal 1.year.ago,       release_announcement.previous_display_date
    assert_equal organisation,     release_announcement.organisations.first
    assert_equal topic,            release_announcement.topics.first
    assert_equal "cancelled",      release_announcement.state
    assert_equal "Cancel reason",  release_announcement.cancellation_reason
    assert_equal 1.week.ago,       release_announcement.cancellation_date
  end

  test "#search: results are returned in a CollectionPage with the correct total, page and per_page values" do
    @mock_source.stubs(:advanced_search).returns('total' => 30, 'results' => 10.times.map {|n| {"title" => "A title", "metadata" => {}} })

    results = Frontend::StatisticsAnnouncementProvider.search(page: 2, per_page: 10)

    assert_equal 30, results.total
    assert_equal 2, results.page
    assert_equal 10, results.per_page
  end

  test "#find_by_slug: finds a publisher StatisticsAnnouncement and inflates from that" do
    organisation = create(:ministerial_department)
    topic        = create(:topic)
    publication  = create(:published_statistics)

    publisher_announcement = create :statistics_announcement, slug: "a-title",
                                                              title: "A Title",
                                                              summary: "A summary",
                                                              publication: publication,
                                                              publication_type_id: PublicationType::Statistics.id,
                                                              organisation_ids: [organisation.id],
                                                              topics: [topic],
                                                              cancellation_reason: "Cancelled for reasons",
                                                              cancelled_at: 1.day.ago,
                                                              statistics_announcement_dates: [build(:statistics_announcement_date,
                                                                                                     release_date:  "2050-03-01",
                                                                                                     precision: StatisticsAnnouncementDate::PRECISION[:two_month],
                                                                                                     confirmed: false,
                                                                                                     change_note: nil),
                                                                                               build(:statistics_announcement_date,
                                                                                                     release_date:  Time.zone.parse("2050-01-01 09:30:00"),
                                                                                                     precision: StatisticsAnnouncementDate::PRECISION[:exact],
                                                                                                     confirmed: true,
                                                                                                     change_note: 'Change note')]

    announcement = Frontend::StatisticsAnnouncementProvider.find_by_slug(publisher_announcement.slug)

    assert_equal "a-title",                                 announcement.slug
    assert_equal "A Title",                                 announcement.title
    assert_equal "A summary",                               announcement.summary
    assert_equal publication,                               announcement.publication
    assert_equal PublicationType::Statistics.singular_name, announcement.document_type
    assert_equal Time.zone.parse("2050-01-01 09:30:00"),    announcement.release_date
    assert_equal "1 January 2050 9:30am",                   announcement.display_date
    assert_equal true,                                      announcement.release_date_confirmed
    assert_equal "Change note",                             announcement.release_date_change_note
    assert_equal "March to April 2050",                     announcement.previous_display_date
    assert_equal [organisation],                            announcement.organisations
    assert_equal [topic],                                   announcement.topics
    assert_equal "cancelled",                               announcement.state
    assert_equal "Cancelled for reasons",                   announcement.cancellation_reason
    assert_equal 1.day.ago,                                 announcement.cancellation_date
  end

  test "#find_by_slug: returns nil if it can't find one" do
    assert_equal nil, Frontend::StatisticsAnnouncementProvider.find_by_slug("not-a-slug")
  end
end
