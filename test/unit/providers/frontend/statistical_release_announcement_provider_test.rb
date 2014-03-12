class Frontend::StatisticalReleaseAnnouncementProviderTest < ActiveSupport::TestCase
  attr_accessor :rummager_api_stub

  setup do
    @mock_source ||= mock
    Frontend::StatisticalReleaseAnnouncementProvider.stubs(:source).returns(@mock_source)
  end

  test ".find_by should ask rummager for all release announcements which match the filter params given" do
    @mock_source.stubs(:advanced_search).with({keywords: 'keyword'}).returns([{'slug' => 'an-announcement-slug'},
                                                                              {'slug' => 'another-announcement-slug'}])

    assert_equal ['an-announcement-slug', 'another-announcement-slug'], Frontend::StatisticalReleaseAnnouncementProvider.find_by(keywords: 'keyword').map(&:slug)
  end

  test "release announcments are inflated from rummager hashes" do
    organisation = create(:organisation, name: 'Cabinet Office', slug: 'cabinet-office')
    topic = create(:topic, name: 'Home affairs', slug: 'home-affairs')

    @mock_source.stubs(:advanced_search).returns([{
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

    release_announcement = Frontend::StatisticalReleaseAnnouncementProvider.find_by(:something).first

    assert_equal "A title",      release_announcement.title
    assert_equal "a-slug",       release_announcement.slug
    assert_equal "The summary",  release_announcement.summary
    assert_equal "Statistics",   release_announcement.document_type
    assert_equal Time.zone.now,  release_announcement.release_date
    assert_equal "About now",    release_announcement.release_date_text
    assert_equal organisation, release_announcement.organisations.first
    assert_equal topic, release_announcement.topics.first
  end
end

class Frontend::StatisticalReleaseAnnouncementProviderTest::FakeRummagerApiTest < ActiveSupport::TestCase
  def subject
    Frontend::StatisticalReleaseAnnouncementProvider::FakeRummagerApi
  end

  def matched_titles(params = {})
    subject.advanced_search(params).map {|hash| hash["title"]}
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

    returned_announcement_hash = subject.advanced_search.first

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

  test "#advanced_search never returns expired release announcments" do
    announcement_1 = create :statistical_release_announcement, expected_release_date: 1.day.ago
    assert_equal [], matched_titles(from_date: 10.days.ago)
  end
end
