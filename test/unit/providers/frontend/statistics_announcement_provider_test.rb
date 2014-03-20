class Frontend::StatisticsAnnouncementProviderTest < ActiveSupport::TestCase
  attr_accessor :rummager_api_stub

  setup do
    @mock_source ||= mock
    Frontend::StatisticsAnnouncementProvider.stubs(:source).returns(@mock_source)
  end

  test "#search: page and per_page params are converted to strings" do
    @mock_source.expects(:advanced_search).with(page: '2', per_page: '10').returns({'total' => 0, 'results' => []})
    Frontend::StatisticsAnnouncementProvider.search(page: 2, per_page: 10)
  end

  test "#search: from_date and to_date are moved to expected_release_timestamp[:from] and expected_release_timestamp[:to] and are formatted as iso8601" do
    from_date = 1.day.from_now
    to_date = 1.year.from_now
    @mock_source.expects(:advanced_search).with(expected_release_timestamp: {from: from_date.iso8601, to: to_date.iso8601}, page: '2', per_page: '10').returns({'total' => 0, 'results' => []})
    Frontend::StatisticsAnnouncementProvider.search(from_date: from_date, to_date: to_date, page: 2, per_page: 10)
  end

  test "#search: release announcments are inflated from rummager hashes" do
    organisation = create(:organisation, name: 'Cabinet Office', slug: 'cabinet-office')
    topic = create(:topic, name: 'Home affairs', slug: 'home-affairs')

    @mock_source.stubs(:advanced_search).returns('total' => 1, 'results' => [{
      "title" => "A title",
      "description" => "The summary",
      "slug" => "a-slug",
      "expected_release_timestamp" => Time.zone.now,
      "expected_release_text" => "About now",
      "organisations" => ["cabinet-office"],
      "topics" => ["home-affairs"],
      "display_type" => "Statistics",
      "search_format_types" => ["statistics_announcement"],
      "format" => "statistics_announcement"
    }])

    release_announcement = Frontend::StatisticsAnnouncementProvider.search({page: 1, per_page: 10}).first

    assert_equal "A title",      release_announcement.title
    assert_equal "a-slug",       release_announcement.slug
    assert_equal "The summary",  release_announcement.summary
    assert_equal "Statistics",   release_announcement.document_type
    assert_equal Time.zone.now,  release_announcement.release_date
    assert_equal "About now",    release_announcement.release_date_text
    assert_equal organisation, release_announcement.organisations.first
    assert_equal topic, release_announcement.topics.first
  end

  test "#search: results are returned in a CollectionPage with the correct total, page and per_page values" do
    @mock_source.stubs(:advanced_search).with(page: '2', per_page: '10').returns('total' => 30, 'results' => 10.times.map {|n| {"title" => "A title"} })

    results = Frontend::StatisticsAnnouncementProvider.search(page: 2, per_page: 10)

    assert_equal 30, results.total
    assert_equal 2, results.page
    assert_equal 10, results.per_page
  end


  test "#find_by_slug: finds a publisher StatisticsAnnouncement and inflates from that" do
    publisher_announcement = create :statistics_announcement, slug: "a-slug",
                                                              title: "A Title",
                                                              summary: "A summary",
                                                              publication: create(:published_statistics),
                                                              publication_type_id: PublicationType::NationalStatistics.id,
                                                              expected_release_date: Time.zone.parse("2016-01-01"),
                                                              display_release_date_override: "Jan 2016",
                                                              organisation: create(:ministerial_department),
                                                              topic: create(:topic)

    announcement = Frontend::StatisticsAnnouncementProvider.find_by_slug(publisher_announcement.slug)

    assert_equal announcement.slug,              publisher_announcement.slug
    assert_equal announcement.title,             publisher_announcement.title
    assert_equal announcement.summary,           publisher_announcement.summary
    assert_equal announcement.publication,       publisher_announcement.publication
    assert_equal announcement.document_type,     PublicationType::NationalStatistics.singular_name
    assert_equal announcement.release_date,      publisher_announcement.expected_release_date
    assert_equal announcement.release_date_text, publisher_announcement.display_release_date_override
    assert_equal announcement.organisations,     [publisher_announcement.organisation]
    assert_equal announcement.topics,            [publisher_announcement.topic]
  end

  test "#find_by_slug: returns nil if it can't find one" do
    assert_equal nil, Frontend::StatisticsAnnouncementProvider.find_by_slug("not-a-slug")
  end
end

class Frontend::StatisticsAnnouncementProviderTest::FakeRummagerApiTest < ActiveSupport::TestCase
  def subject
    Frontend::StatisticsAnnouncementProvider::FakeRummagerApi
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
                          summary: "The summary",
                          organisation: build(:organisation),
                          topic: build(:topic),
                          expected_release_date: Time.zone.parse("2050-01-01"),
                          display_release_date_override: "Jan 2050",
                          publication_type_id: PublicationType.find_by_slug("statistics").id

    returned_announcement_hash = subject.advanced_search(page: '1', per_page: '100')['results'].first

    assert_equal announcement.title,                          returned_announcement_hash["title"]
    assert_equal announcement.summary,                        returned_announcement_hash["description"]
    assert_equal announcement.slug,                           returned_announcement_hash["slug"]
    assert_equal announcement.publication_type.singular_name, returned_announcement_hash["display_type"]
    assert_equal ["statistics_announcement"],        returned_announcement_hash["search_format_types"]
    assert_equal "statistics_announcement",          returned_announcement_hash["format"]
    assert_equal announcement.organisation.slug,              returned_announcement_hash["organisations"].first
    assert_equal announcement.topic.slug,                     returned_announcement_hash["topics"].first
    assert_equal announcement.expected_release_date.iso8601,  returned_announcement_hash["expected_release_timestamp"]
    assert_equal announcement.display_release_date_override,  returned_announcement_hash["expected_release_text"]
  end

  test "#advanced_search with :keywords returns release announcements matching title or summary" do
    announcement_1 = create :statistics_announcement, title: "Wombats", summary: "Population in Wimbledon Common 2013"
    announcement_2 = create :statistics_announcement, title: "Womble's troubles", summary: "Population of wombats in Wimbledon Common 2013"
    announcement_3 = create :statistics_announcement, title: "Fishslice", summary: "Fishslice"

    assert_equal ["Wombats", "Womble's troubles"], matched_titles(keywords: "wombat")
  end

  test "#advanced_search with expected_release_timestamp[:from] returns release announcements after the given date" do
    announcement_1 = create :statistics_announcement, expected_release_date: 10.days.from_now.iso8601, title: "Wanted release announcement"
    announcement_2 = create :statistics_announcement, expected_release_date: 5.days.from_now.iso8601, title: "Unwanted release announcement"

    assert_equal ["Wanted release announcement"], matched_titles(expected_release_timestamp: { from: 7.days.from_now.iso8601 })
  end

  test "#advanced_search with expected_release_timestamp[:to] returns release announcements before the given date" do
    announcement_1 = create :statistics_announcement, expected_release_date: 10.days.from_now.iso8601, title: "Unwanted release announcement"
    announcement_2 = create :statistics_announcement, expected_release_date: 5.days.from_now.iso8601, title: "Wanted release announcement"

    assert_equal ["Wanted release announcement"], matched_titles(expected_release_timestamp: { to: 7.days.from_now.iso8601 })
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

  test "#advanced_search returns results ordered by expected_release_date" do
    announcement_1 = create :statistics_announcement, expected_release_date: 2.days.from_now.iso8601
    announcement_2 = create :statistics_announcement, expected_release_date: 1.days.from_now.iso8601
    announcement_3 = create :statistics_announcement, expected_release_date: 3.days.from_now.iso8601
  end

  test "#advanced_search supports pagination" do
    announcements = 4.times.map do |n|
      create :statistics_announcement, title: n, expected_release_date: (n+1).days.from_now.iso8601
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
      subject.advanced_search({ expected_release_timestamp: { from: Time.new }, page: '1', per_page: '1' })
    }
    assert_nothing_raised {
      subject.advanced_search({ expected_release_timestamp: { from: "some date" }, page: '1', per_page: '1' })
    }
    assert_nothing_raised {
      subject.advanced_search({ some_array: ['a-slug'], page: '1', per_page: '1' })
    }
  end
end
