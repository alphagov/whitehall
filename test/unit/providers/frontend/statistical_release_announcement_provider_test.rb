class Frontend::StatisticalReleaseAnnouncementProviderTest < ActiveSupport::TestCase
  attr_accessor :rummager_api_stub

  setup do
    @mock_source ||= mock
    Frontend::StatisticalReleaseAnnouncementProvider.stubs(:source).returns(@mock_source)
  end

  test "release announcments are inflated from rummager hashes" do
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
      "search_format_types" => ["statistical_release_announcement"],
      "format" => "statistical_release_announcement"
    }])

    release_announcement = Frontend::StatisticalReleaseAnnouncementProvider.search({page: 1, per_page: 10}).first

    assert_equal "A title",      release_announcement.title
    assert_equal "a-slug",       release_announcement.slug
    assert_equal "The summary",  release_announcement.summary
    assert_equal "Statistics",   release_announcement.document_type
    assert_equal Time.zone.now,  release_announcement.release_date
    assert_equal "About now",    release_announcement.release_date_text
    assert_equal organisation, release_announcement.organisations.first
    assert_equal topic, release_announcement.topics.first
  end

  test "results are returned in a CollectionPage with the correct total, page and per_page values" do
    @mock_source.stubs(:advanced_search).with(page: 2, per_page: 10).returns('total' => 30, 'results' => 10.times.map {|n| {"title" => "A title"} })

    results = Frontend::StatisticalReleaseAnnouncementProvider.search(page: 2, per_page: 10)

    assert_equal 30, results.total
    assert_equal 2, results.page
    assert_equal 10, results.per_page
  end

  test "#search requires :page and :per_page params" do
    assert_raises(ArgumentError){
      Frontend::StatisticalReleaseAnnouncementProvider.search(page: nil, per_page: 1)
    }
    assert_raises(ArgumentError){
      Frontend::StatisticalReleaseAnnouncementProvider.search(page: 1, per_page: nil)
    }
  end
end

class Frontend::StatisticalReleaseAnnouncementProviderTest::FakeRummagerApiTest < ActiveSupport::TestCase
  def subject
    Frontend::StatisticalReleaseAnnouncementProvider::FakeRummagerApi
  end

  def matched_titles(params = {})
    params = params.reverse_merge(page: 1, per_page: 100)
    subject.advanced_search(params)['results'].map {|hash| hash["title"]}
  end

  test "#advanced_search returns 'total' and 'results'" do
    4.times { create :statistical_release_announcement }

    returned = subject.advanced_search(page: 1, per_page: 2)

    assert_equal 4, returned['total']
    assert_equal 2, returned['results'].length
  end

  test "#advanced_search returns announcements in an array of hashes similar to that which rummager would return" do
    announcement = create :statistical_release_announcement,
                          title: "The title",
                          summary: "The summary",
                          organisation: build(:organisation),
                          topic: build(:topic),
                          expected_release_date: Time.zone.parse("2050-01-01"),
                          display_release_date_override: "Jan 2050",
                          publication_type_id: PublicationType.find_by_slug("statistics").id

    returned_announcement_hash = subject.advanced_search(page: 1, per_page: 100)['results'].first

    assert_equal announcement.title,                          returned_announcement_hash["title"]
    assert_equal announcement.summary,                        returned_announcement_hash["description"]
    assert_equal announcement.slug,                           returned_announcement_hash["slug"]
    assert_equal announcement.publication_type.singular_name, returned_announcement_hash["display_type"]
    assert_equal ["statistical_release_announcement"],        returned_announcement_hash["search_format_types"]
    assert_equal "statistical_release_announcement",          returned_announcement_hash["format"]
    assert_equal announcement.organisation.slug,              returned_announcement_hash["organisations"].first
    assert_equal announcement.topic.slug,                     returned_announcement_hash["topics"].first
    assert_equal announcement.expected_release_date.iso8601,  returned_announcement_hash["expected_release_timestamp"]
    assert_equal announcement.display_release_date_override,  returned_announcement_hash["expected_release_text"]
  end

  test "#advanced_search with :keywords returns release announcements matching title or summary" do
    announcement_1 = create :statistical_release_announcement, title: "Wombats", summary: "Population in Wimbledon Common 2013"
    announcement_2 = create :statistical_release_announcement, title: "Womble's troubles", summary: "Population of wombats in Wimbledon Common 2013"
    announcement_3 = create :statistical_release_announcement, title: "Fishslice", summary: "Fishslice"

    assert_equal ["Wombats", "Womble's troubles"], matched_titles(keywords: "wombat")
  end

  test "#advanced_search with :from_date returns release announcements after the given date" do
    announcement_1 = create :statistical_release_announcement, expected_release_date: 10.days.from_now, title: "Wanted release announcement"
    announcement_2 = create :statistical_release_announcement, expected_release_date: 5.days.from_now, title: "Unwanted release announcement"

    assert_equal ["Wanted release announcement"], matched_titles(from_date: 7.days.from_now)
  end

  test "#advanced_search with :to_date returns release announcements before the given date" do
    announcement_1 = create :statistical_release_announcement, expected_release_date: 10.days.from_now, title: "Unwanted release announcement"
    announcement_2 = create :statistical_release_announcement, expected_release_date: 5.days.from_now, title: "Wanted release announcement"

    assert_equal ["Wanted release announcement"], matched_titles(to_date: 7.days.from_now)
  end

  test "#advanced_search returns results ordered by expected_release_date" do
    announcement_1 = create :statistical_release_announcement, expected_release_date: 2.days.from_now
    announcement_2 = create :statistical_release_announcement, expected_release_date: 1.days.from_now
    announcement_3 = create :statistical_release_announcement, expected_release_date: 3.days.from_now
  end

  test "#advanced_search supports pagination" do
    announcements = 4.times.map do |n|
      create :statistical_release_announcement, title: n, expected_release_date: (n+1).days.from_now
    end

    assert_equal ['0', '1'],      matched_titles(page: 1, per_page: 2)
    assert_equal ['2', '3'],      matched_titles(page: 2, per_page: 2)
    assert_equal ['0', '1', '2'], matched_titles(page: 1, per_page: 3)
  end

  test "#advanced_search requires :page and :per_page params" do
    assert_raises(ArgumentError){
      subject.advanced_search(page: nil, per_page: 1)
    }
    assert_raises(ArgumentError){
      subject.advanced_search(page: 1, per_page: nil)
    }
  end
end
