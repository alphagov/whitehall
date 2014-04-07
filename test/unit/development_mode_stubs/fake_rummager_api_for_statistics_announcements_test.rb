
class DevelopmentModeStubs::FakeRummagerApiForStatisticsAnnouncementsTest < ActiveSupport::TestCase
  def subject
    DevelopmentModeStubs::FakeRummagerApiForStatisticsAnnouncements
  end

  def matched_titles(params = {})
    params = params.reverse_merge(page: '1', per_page: '100')
    subject.advanced_search(params)['results'].map {|hash| hash["title"]}
  end

  test "#advanced_search returns 'total' and 'results'" do
    4.times { create :statistics_announcement }

    returned = subject.advanced_search(page: '1', per_page: '2')

    assert_equal 4, returned['total']
    assert_equal 2, returned['results'].length
  end

  test "#advanced_search returns announcements in an array of hashes similar to that which rummager would return" do
    announcement = create :statistics_announcement,
                          title: "The title",
                          slug: 'the-title',
                          summary: "The summary",
                          organisation: build(:organisation),
                          topic: build(:topic),
                          publication_type_id: PublicationType.find_by_slug("statistics").id,
                          statistics_announcement_dates: [ build(:statistics_announcement_date,
                                                                 release_date:  "2050-03-01",
                                                                 precision: StatisticsAnnouncementDate::PRECISION[:two_month],
                                                                 confirmed: false,
                                                                 change_note: nil),
                                                           build(:statistics_announcement_date,
                                                                 release_date:  Time.zone.parse("2050-01-01 09:30"),
                                                                 precision: StatisticsAnnouncementDate::PRECISION[:exact],
                                                                 confirmed: true,
                                                                 change_note: 'The change note') ]

    returned_announcement_hash = subject.advanced_search(page: '1', per_page: '100')['results'].first

    assert_equal "The title",                      returned_announcement_hash["title"]
    assert_equal "The summary",                    returned_announcement_hash["description"]
    assert_equal "the-title",                      returned_announcement_hash["slug"]
    assert_equal "Statistics",                     returned_announcement_hash["display_type"]
    assert_equal ["statistics_announcement"],      returned_announcement_hash["search_format_types"]
    assert_equal "statistics_announcement",        returned_announcement_hash["format"]
    assert_equal [announcement.organisation.slug], returned_announcement_hash["organisations"]
    assert_equal [announcement.topic.slug],        returned_announcement_hash["topics"]
    assert_equal "2050-01-01T09:30:00+00:00",      returned_announcement_hash["release_timestamp"]
    assert_equal true,                             returned_announcement_hash["metadata"]["confirmed"]
    assert_equal "The change note",                returned_announcement_hash["metadata"]["change_note"]
    assert_equal "1 January 2050 09:30",           returned_announcement_hash["metadata"]["display_date"]
    assert_equal "March to April 2050",            returned_announcement_hash["metadata"]["previous_display_date"]
  end

  test "#advanced_search with :keywords returns release announcements matching title or summary" do
    announcement_1 = create :statistics_announcement, title: "Wombats", summary: "Population in Wimbledon Common 2013"
    announcement_2 = create :statistics_announcement, title: "Womble's troubles", summary: "Population of wombats in Wimbledon Common 2013"
    announcement_3 = create :statistics_announcement, title: "Fishslice", summary: "Fishslice"

    assert_equal ["Wombats", "Womble's troubles"], matched_titles(keywords: "wombat")
  end

  test "#advanced_search with release_timestamp[:from] returns release announcements after the given date" do
    announcement_1 = create :statistics_announcement, title: "Wanted release announcement",
                                                      current_release_date: build(:statistics_announcement_date, release_date: 10.days.from_now)
    announcement_2 = create :statistics_announcement, title: "Unwanted release announcement",
                                                      current_release_date: build(:statistics_announcement_date, release_date: 5.days.from_now.iso8601)

    assert_equal ["Wanted release announcement"], matched_titles(release_timestamp: { from: 7.days.from_now.iso8601 })
  end

  test "#advanced_search with release_timestamp[:to] returns release announcements before the given date" do
    announcement_1 = create :statistics_announcement, title: "Unwanted release announcement",
                                                      current_release_date: build(:statistics_announcement_date, release_date: 10.days.from_now)
    announcement_2 = create :statistics_announcement, title: "Wanted release announcement",
                                                      current_release_date: build(:statistics_announcement_date, release_date: 5.days.from_now.iso8601)

    assert_equal ["Wanted release announcement"], matched_titles(release_timestamp: { to: 7.days.from_now.iso8601 })
  end

  test "#advanced_search with organisations returns results associated with the organisations" do
    announcement_1 = create :statistics_announcement, organisation: create(:organisation)
    announcement_2 = create :statistics_announcement

    assert_equal [announcement_1.title], matched_titles(organisations: [announcement_1.organisation.slug])
  end

  test "#advanced_search with topics returns results associated with the topics" do
    announcement_1 = create :statistics_announcement, topic: create(:topic)
    announcement_2 = create :statistics_announcement

    assert_equal [announcement_1.title], matched_titles(topics: [announcement_1.topic.slug])
  end

  test "#advanced_search returns results ordered by current_release_date's release_date" do
    announcement_1 = create :statistics_announcement, current_release_date: build(:statistics_announcement_date, release_date: 2.days.from_now)
    announcement_2 = create :statistics_announcement, current_release_date: build(:statistics_announcement_date, release_date: 1.day.from_now)
    announcement_3 = create :statistics_announcement, current_release_date: build(:statistics_announcement_date, release_date: 3.days.from_now)

    assert_equal [announcement_2.title, announcement_1.title, announcement_3.title], matched_titles
  end

  test "#advanced_search supports pagination" do
    announcements = 4.times.map do |n|
      create :statistics_announcement, title: n, current_release_date: build(:statistics_announcement_date, release_date: (n+1).days.from_now)

    end

    assert_equal ['0', '1'],      matched_titles(page: '1', per_page: '2')
    assert_equal ['2', '3'],      matched_titles(page: '2', per_page: '2')
    assert_equal ['0', '1', '2'], matched_titles(page: '1', per_page: '3')
  end

  test "#advanced_search requires :page and :per_page params to be provided" do
    assert_raises(ArgumentError) {
      subject.advanced_search(page: nil, per_page: '1')
    }
    assert_raises(ArgumentError) {
      subject.advanced_search(page: '1', per_page: nil)
    }
  end

  test "#advanced_search doesn't return duplicate results when announcement has 2 or more announcement dates" do
    announcement = create :statistics_announcement, title: "stats announcement", statistics_announcement_dates: 2.times.map {|n| build :statistics_announcement_date }
    assert_equal ['stats announcement'], matched_titles(page: '1', per_page: '10')
  end

  test "#advanced_search requires all paramaters to be provided as strings" do
    # Due to a bug in Rack::Utils.build_nested_query used by gds-api-adapters to form the request to rummager, non-string values in
    # query hashes are dropped silently. This is here to mimic the actual behavior of the rummager api adapter.
    assert_raises(ArgumentError) {
      subject.advanced_search(some_date: Date.new, page: '1', per_page: '1')
    }
    assert_raises(ArgumentError) {
      subject.advanced_search(life_the_universe_and_everything: 42, page: '1', per_page: '1')
    }
    assert_raises(ArgumentError) {
      subject.advanced_search({ release_timestamp: { from: Time.new }, page: '1', per_page: '1' })
    }
    assert_nothing_raised {
      subject.advanced_search({ some_hash: { from: "some date" }, page: '1', per_page: '1' })
    }
    assert_nothing_raised {
      subject.advanced_search({ some_array: ['a-slug'], page: '1', per_page: '1' })
    }
  end
end
