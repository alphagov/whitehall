require 'test_helper'

class FilterHelperTest < ActionView::TestCase
  test "#organisation_options_for_statistics_announcement_filter renders select options for all organisations with an associated release announcement in alphabetical order selecting passed in organisation" do
    org_1, org_2, org_3 = create(:organisation, name: "B org"), create(:organisation, name: "C org"), create(:organisation, name: "A org")

    create :statistics_announcement, organisation: org_2
    create :statistics_announcement, organisation: org_3

    rendered = Nokogiri::HTML::DocumentFragment.parse(organisation_options_for_statistics_announcement_filter(org_3.slug))
    options = rendered.css("option")

    assert_equal ["All departments", org_3.name, org_2.name], options.map(&:text)
    assert_equal ["", org_3.slug, org_2.slug], options.map {|option| option[:value]}
    assert options[1][:selected]
  end

  test "#topic_options_for_statistics_announcement_filter renders select options for all topics with an associated release announcement in alphabetical order selecting passed in topic" do
    topic_1, topic_2, topic_3 = create(:topic, name: "B topic"), create(:topic, name: "C topic"), create(:topic, name: "A topic")

    create :statistics_announcement, topic: topic_2
    create :statistics_announcement, topic: topic_3

    rendered = Nokogiri::HTML::DocumentFragment.parse(topic_options_for_statistics_announcement_filter(topic_3.slug))
    options = rendered.css("option")

    assert_equal ["All topics", topic_3.name, topic_2.name], options.map(&:text)
    assert_equal ["", topic_3.slug, topic_2.slug], options.map {|option| option[:value]}
    assert options[1][:selected]
  end
end

class FilterHelperTest::FilterDescriptionTest < ActionView::TestCase
  include TextAssertions

  def build_filter(params = {})
    OpenStruct.new(params.reverse_merge({
      filter_type: "publication",
      result_count: 1
    }))
  end

  def rendered_description(filter, opts = {})
    Nokogiri::HTML::DocumentFragment.parse(FilterHelper::FilterDescription.new(filter, opts).render)
  end

  test "It describes the total count correctly" do
    assert_string_includes "12,345 documents", rendered_description(build_filter(filter_type: "document", result_count: 12345)).text
    assert_string_includes "1 document", rendered_description(build_filter(filter_type: "document", result_count: 1)).text
  end

  test "It describes keywords" do
    assert_string_includes "containing fishslice", rendered_description(build_filter(keywords: "fishslice")).text
  end

  test "It describes topics" do
    topic = build(:topic, name: "Community and society")
    assert_string_includes "about Community and society", rendered_description(build_filter(topics: [topic])).text
  end

  test "It describes organisations" do
    organisation = build(:organisation, name: "Department of Magic")
    assert_string_includes "by Department of Magic", rendered_description(build_filter(organisations: [organisation])).text
  end

  test "It describes date range" do
    filter = build_filter(from_date: Date.new(2040, 02, 20), to_date: Date.new(2050, 01, 10))
    assert_string_includes "due after 20 February 2040 and before 10 January 2050", rendered_description(filter, date_prefix_text: "due").text

    filter = build_filter(from_date: Date.new(2040, 02, 20))
    assert_string_includes "procrantinated after 20 February 2040", rendered_description(filter, date_prefix_text: "procrantinated").text
  end
end
