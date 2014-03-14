require 'test_helper'

class Frontend::StatisticalReleaseAnnouncementsFilterTest < ActiveSupport::TestCase
  def build(attrs = {})
    Frontend::StatisticalReleaseAnnouncementsFilter.new(attrs)
  end

  test "#to_date= fills parsed_to_date if possible, taking the latest possible time in it's assumptions" do
    assert_equal Time.zone.parse("2010-02-01 00:00:00 +0000"), build(to_date: "Jan 2010").parsed_to_date
    assert_equal nil, build(to_date: "sandwich").parsed_to_date
  end

  test "#from_date= fills parsed_from_date if possible, taking the earliest possible time in it's assumptions" do
    assert_equal Time.zone.parse("2010-01-01 00:00:00 +0000"), build(from_date: "Jan 2010").parsed_from_date
    assert_equal nil, build(from_date: "sandwich").parsed_from_date
  end

  test "if to_date isn't parseable, a validation error is added" do
    announcement = build(to_date: "sandwich")
    refute announcement.valid?
    assert announcement.errors[:to_date].any?
  end

  test "if from_date isn't parseable, a validation error is added" do
    announcement = build(from_date: "sandwich")
    refute announcement.valid?
    assert announcement.errors[:from_date].any?
  end

  test "#page= casts to integer" do
    assert build(page: '2').page.is_a? Integer
  end

  test "page default to 1" do
    assert_equal 1, build.page
  end

  test "#valid_filter_params returns all attributes if all are present and valid excluding pagination parameters" do
    announcement = build(keywords: "keyword",
                         from_date: "2020-01-01 12:00:00",
                         to_date: "2020-02-01 10:00:00",
                         page: 2)

    assert_equal({ keywords: "keyword",
                   from_date: Time.zone.parse("2020-01-01 12:00:00"),
                   to_date: Time.zone.parse("2020-02-01 10:00:01")
                 }, announcement.valid_filter_params)
  end

  test "#valid_filter_params skips blank attributes" do
    refute build(keywords: nil).valid_filter_params.keys.include? :keywords
    refute build(from_date: nil).valid_filter_params.keys.include? :from_date
    refute build(to_date: nil).valid_filter_params.keys.include? :to_date
  end

  test "#valid_filter_params skips invalid attributes" do
    refute build(from_date: "fishslice").valid_filter_params.keys.include? :from_date
    refute build(to_date: "fishslice").valid_filter_params.keys.include? :to_date
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
