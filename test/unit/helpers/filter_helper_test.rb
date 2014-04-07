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
      result_count: 1,
      valid_filter_params: {}
    }))
  end

  def rendered_description(filter, opts = {})
    Nokogiri::HTML::DocumentFragment.parse(FilterHelper::FilterDescription.new(filter, base_url, opts).render)
  end

  def base_url
    "http://www.example.com"
  end

  test "It describes the total count correctly" do
    assert_string_includes "12,345 documents", rendered_description(build_filter(filter_type: "document",  result_count: 12345)).text
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
    assert_string_includes "due after 20 February 2040", rendered_description(filter, date_prefix_text: "due").text
    assert_string_includes "and before 10 January 2050", rendered_description(filter, date_prefix_text: "due").text

    filter = build_filter(from_date: Date.new(2040, 02, 20))
    assert_string_includes "procrantinated after 20 February 2040", rendered_description(filter, date_prefix_text: "procrantinated").text
  end

  def assert_remove_filter_link_present(html_fragment, field, expected_text, expected_value, expected_query_params)
    link = html_fragment.at_css("a[data-field=#{field}]")
    assert link.present?, "No link with data-field=\"#{field}\""
    assert_equal expected_value, link[:"data-value"]
    assert_equal "Remove #{expected_text}", link[:title]
    assert_equal expected_query_params, Rack::Utils.parse_nested_query(URI.parse(link[:href]).query).symbolize_keys
  end

  test "It renders links to remove search parameters" do
    topic = build(:topic, name: "Community and society", slug: "community-and-society")
    organisation = build(:organisation, name: "Department of Magic", slug: "department-of-magic")

    filter = build_filter keywords: "fishslice",
                          organisations: [organisation],
                          topics: [topic],
                          from_date: Date.new(2040, 1, 1),
                          to_date: Date.new(2050, 1, 1)

    expected_filter_params = {
      keywords: "fishslice",
      organisations: [organisation.slug],
      topics: [topic.slug],
      from_date: "2040-01-01",
      to_date: "2050-01-01"
    }

    filter.stubs(:valid_filter_params).returns(expected_filter_params)

    rendered = rendered_description(filter)
    assert_remove_filter_link_present(rendered, :keywords,      "fishslice",             "fishslice",       expected_filter_params.except(:keywords))
    assert_remove_filter_link_present(rendered, :organisations, organisation.name,       organisation.slug, expected_filter_params.except(:organisations))
    assert_remove_filter_link_present(rendered, :topics,        topic.name,              topic.slug,        expected_filter_params.except(:topics))
    assert_remove_filter_link_present(rendered, :from_date,     "published after date",  "2040-01-01",      expected_filter_params.except(:from_date))
    assert_remove_filter_link_present(rendered, :to_date,       "published before date", "2050-01-01",      expected_filter_params.except(:to_date))
  end
end
