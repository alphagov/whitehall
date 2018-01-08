require 'test_helper'

class Frontend::StatisticsAnnouncementsFilterTest < ActiveSupport::TestCase
  def build(attrs = {})
    Frontend::StatisticsAnnouncementsFilter.new(attrs)
  end

  test "to_date= casts into Date, taking the latest possible date in its assumptions" do
    assert_equal Date.new(2010, 01, 31), build(to_date: "Jan 2010").to_date
  end

  test "from_date= casts into Date, taking the earliest possible date in its assumptions" do
    assert_equal Date.new(2010, 01, 01), build(from_date: "Jan 2010").from_date
  end

  test "to_date= and from_date= assumes english date format when ambiguous" do
    assert_equal Date.new(2010, 06, 12), build(to_date: "12/6/2010").to_date
    assert_equal Date.new(2010, 06, 12), build(from_date: "12/6/2010").from_date
  end

  test "#page= casts to integer" do
    assert build(page: '2').page.is_a? Integer
  end

  test "page default to 1" do
    assert_equal 1, build.page
  end

  test "organisations= parses slugs into real organisations" do
    org_1, org_2 = 2.times.map { create(:organisation) }
    assert_equal [org_1, org_2], build(organisations: [org_1.slug, org_2.slug]).organisations
  end

  test "organisations= handles nil" do
    assert_equal [], build(organisations: nil).organisations
  end

  test "organisation_slugs returns slugs of organisations" do
    organisation = create(:organisation)
    assert_equal [organisation.slug], build(organisations: [organisation.slug]).organisation_slugs
  end

  test "topics= parses slugs into real topics" do
    topic_1, topic_2 = 2.times.map { create(:topic) }
    assert_equal [topic_1, topic_2], build(topics: [topic_1.slug, topic_2.slug]).topics
  end

  test "topics= handles nil" do
    assert_equal [], build(topics: nil).topics
  end

  test "policy_area_slugs returns slugs of topics" do
    topic = create(:topic)
    assert_equal [topic.slug], build(topics: [topic.slug]).policy_area_slugs
  end

  test "#valid_filter_params returns all attributes if all are present and valid excluding pagination parameters" do
    organisation = create :organisation
    topic = create :topic

    filter = build(keywords: "keyword",
                   from_date: "2020-01-01",
                   to_date: "2020-02-01",
                   organisations: [organisation.slug],
                   topics: [topic.slug],
                   page: 2)

    assert_equal(
      {
        keywords: "keyword",
        from_date: Date.new(2020, 1, 1),
        to_date: Date.new(2020, 2, 1),
        organisations: [
          organisation.slug,
        ],
        policy_areas: [
          topic.slug,
        ],
      },
      filter.valid_filter_params
    )
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
    stub_provider.stubs(:search).with(keywords: "keyword", page: 2, per_page: 40).returns(:some_results)

    filter = build(keywords: "keyword", page: 2)
    filter.stubs(:provider).returns(stub_provider)

    assert_equal :some_results, filter.results
  end

  test "When on page 1 and no from date has been give, #results also fetches statistics announcements between one month ago and now, and prepends those results returning them in a new CollectionPage" do
    normal_resultset = CollectionPage.new(%i[an_announcement another_announcement], total: 10, page: 1, per_page: 2)
    cancelled_and_past_resultset = CollectionPage.new(%i[a_cancelled_announcement another_cancelled_announcement], total: 2, page: 1, per_page: 100)

    stub_provider = mock
    stub_provider.stubs(:search).with(page: 1, per_page: 40).returns(normal_resultset)
    stub_provider.stubs(:search).with(page: 1, per_page: 40, statistics_announcement_state: 'cancelled', from_date: 1.month.ago.to_date, to_date: Time.zone.now.to_date).returns(cancelled_and_past_resultset)

    filter = build
    filter.stubs(:provider).returns(stub_provider)

    resultset = filter.results

    assert_equal %i[a_cancelled_announcement another_cancelled_announcement an_announcement another_announcement], filter.results
    assert_equal 12, resultset.total
    assert_equal 1, resultset.page
    assert_equal 40, resultset.per_page
  end

  test "#next_page_params returns valid_filter_params with the page number incremented by 1" do
    filter = build(keywords: "keyword", page: 2)

    stub_provider = mock
    stub_provider.stubs(:search).returns((1..50).to_a)
    filter.stubs(:provider).returns(stub_provider)

    assert_equal({ keywords: 'keyword', page: 3 }, filter.next_page_params)
  end

  test "#previous_page_params returns valid_filter_params with the page number incremented by 1" do
    filter = build(keywords: "keyword", page: 2)

    stub_provider = mock
    stub_provider.stubs(:search).returns((1..50).to_a)
    filter.stubs(:provider).returns(stub_provider)

    assert_equal({ keywords: 'keyword', page: 1 }, filter.previous_page_params)
  end
end
