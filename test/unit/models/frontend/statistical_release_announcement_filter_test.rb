require 'test_helper'

class Frontend::StatisticalReleaseAnnouncementsFilterTest < ActiveSupport::TestCase
  def build(attrs = {})
    Frontend::StatisticalReleaseAnnouncementsFilter.new(attrs)
  end

  test "to_date= casts into Date, taking the latest possible date in it's assumptions" do
    assert_equal Date.new(2010, 01, 31), build(to_date: "Jan 2010").to_date
  end

  test "from_date= casts into Date, taking the earliest possible date in it's assumptions" do
    assert_equal Date.new(2010, 01, 01), build(from_date: "Jan 2010").from_date
  end

  test "#page= casts to integer" do
    assert build(page: '2').page.is_a? Integer
  end

  test "page default to 1" do
    assert_equal 1, build.page
  end

  test "organisations= parses slugs into real organisations" do
    org_1, org_2 = 2.times.map { create(:organisation) }
    assert_equal [org_1, org_2], build(organisations: [org_1.slug, org_2]).organisations
  end

  test "organisation_slugs returns slugs of organisations" do
    organisation = create(:organisation)
    assert_equal [organisation.slug], build(organisations: [organisation]).organisation_slugs
  end

  test "topics= parses slugs into real topics" do
    topic_1, topic_2 = 2.times.map { create(:topic) }
    assert_equal [topic_1, topic_2], build(topics: [topic_1.slug, topic_2]).topics
  end

  test "topic_slugs returns slugs of topics" do
    topic = create(:topic)
    assert_equal [topic.slug], build(topics: [topic]).topic_slugs
  end

  test "#valid_filter_params returns all attributes if all are present and valid excluding pagination parameters" do
    organisation = create :organisation
    topic = create :topic

    announcement = build(keywords: "keyword",
                         from_date: "2020-01-01",
                         to_date: "2020-02-01",
                         organisations: [organisation],
                         topics: [topic],
                         page: 2)

    assert_equal({ keywords: "keyword",
                   from_date: Date.new(2020, 1, 1),
                   to_date: Date.new(2020, 2, 1),
                   organisations: [organisation.slug],
                   topics: [topic.slug],
                 }, announcement.valid_filter_params)
  end

  test "#valid_filter_params skips blank attributes" do
    refute build(keywords: nil).valid_filter_params.keys.include? :keywords
    refute build(from_date: nil).valid_filter_params.keys.include? :from_date
    refute build(to_date: nil).valid_filter_params.keys.include? :to_date
    refute build(organisations: []).valid_filter_params.keys.include? :organisations
    refute build(topics: []).valid_filter_params.keys.include? :topics
  end

  test "#results should ask the provider for results, using #valid_filter_params + pagination params as search terms" do
    stub_provider = mock
    stub_provider.stubs(:search).with({keywords: "keyword", page: 1, per_page: 40}).returns(:some_results)

    filter = build(keywords: "keyword", page: 1)
    filter.stubs(:provider).returns(stub_provider)

    assert_equal :some_results, filter.results
  end

  test "#next_page_params returns valid_filter_params with the page number incremented by 1" do
    filter = build(keywords: "keyword", page: 1)

    stub_provider = mock
    stub_provider.stubs(:search).returns((1..50).to_a)
    filter.stubs(:provider).returns(stub_provider)

    assert_equal({ keywords: 'keyword', page: 2 }, filter.next_page_params)
  end

  test "#previous_page_params returns valid_filter_params with the page number incremented by 1" do
    filter = build(keywords: "keyword", page: 2)

    stub_provider = mock
    stub_provider.stubs(:search).returns((1..50).to_a)
    filter.stubs(:provider).returns(stub_provider)

    assert_equal({ keywords: 'keyword', page: 1 }, filter.previous_page_params)
  end
end
