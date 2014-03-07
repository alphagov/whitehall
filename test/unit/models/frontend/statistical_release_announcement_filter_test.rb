require 'test_helper'

class Frontend::StatisticalReleaseAnnouncementsFilterTest < ActiveSupport::TestCase
  def build(attrs = {})
    Frontend::StatisticalReleaseAnnouncementsFilter.new attrs.reverse_merge({ keywords: "keyword",
                                                                   from_date: "2010-01-01",
                                                                   to_date: "2010-01-02" })
  end

  test "#to_date= and #from_date= also populates :parsed_to_date and :parsed_from_date if possible" do
    assert_equal Date.new(2010, 1, 1), build(from_date: "2010-01-01").parsed_from_date
    assert_equal Date.new(2010, 1, 1), build(to_date: "2010-01-01").parsed_to_date

    assert_equal nil, build(from_date: "sandwich").parsed_from_date
    assert_equal nil, build(to_date: "sandwich").parsed_to_date
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

  test "#valid_filter_params returns all attributes if all are present and valid" do
    announcement = build(keywords: "keyword",
                         from_date: "2020-01-01",
                         to_date: "2020-02-01")

    assert_equal({ keywords: "keyword",
                   from_date: Date.new(2020, 1, 1),
                   to_date: Date.new(2020, 2, 1) }, announcement.valid_filter_params)
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
end
