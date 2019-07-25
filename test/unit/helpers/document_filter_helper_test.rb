require 'test_helper'

class DocumentFilterHelperTest < ActionView::TestCase
  include ApplicationHelper
  include TaxonomyHelper

  test "#taxon_filter_options makes option tags for taxons" do
    redis_cache_has_taxons([root_taxon, grandparent_taxon])
    result = taxon_filter_options
    assert_includes result, '<option selected="selected" value="all">All topics</option>'
    assert_includes(
      result,
      "<option value=\"#{root_taxon['content_id']}\">#{root_taxon['title']}</option>"
    )
    assert_includes(
      result,
      "<option value=\"#{root_taxon['content_id']}\">#{root_taxon['title']}</option>"
    )
  end

  test "#announcement_type_filter_options makes option tags with subtype name as text and slug as value" do
    expected = Whitehall::AnnouncementFilterOption.all.map { |o| [o.label, o.slug] }.unshift(["All announcement types", "all"])
    option_set = Nokogiri::HTML::DocumentFragment.parse(announcement_type_filter_options)
    actual = option_set.css('option').map { |o| [o.text, o['value']] }

    assert_same_elements expected, actual
  end

  test "#publication_type_filter_options makes option tags with subtype name as text and slug as value" do
    expected = Whitehall::PublicationFilterOption.all.map { |o| [o.label, o.slug] }.unshift(["All publication types", "all"])
    option_set = Nokogiri::HTML::DocumentFragment.parse(publication_type_filter_options)
    actual = option_set.css('option').map { |o| [o.text, o['value']] }

    assert_same_elements expected, actual
  end

  test "remove_filter_from_params removes filter from params" do
    stubs(:params).returns(first: 'one', second: %w[two three])

    assert_equal ({ first: nil, second: %w[two three] }), remove_filter_from_params(:first)
    assert_equal ({ first: 'one', second: %w[three] }), remove_filter_from_params(:second, 'two')
  end

  test "#filter_taxon_selections gets objects ready for mustache" do
    stubs(:params).returns(
      controller: 'publications',
      action: 'index',
      "taxons" => [grandparent_taxon['content_id']],
      "subtaxons" => [parent_taxon['content_id']]
    )
    redis_cache_has_taxons([root_taxon, grandparent_taxon, parent_taxon])

    expected = [
      {
        name: parent_taxon['title'],
        value: parent_taxon['content_id'],
        url: publications_path(taxons: [grandparent_taxon['content_id']]),
        joining: ''
      }
    ]
    actual = filter_taxon_selections(
      [grandparent_taxon['content_id']],
      [parent_taxon['content_id']]
    )

    assert_same_elements expected, actual
  end

  test "filter_results_selections gets objects ready for mustache" do
    topic = build(:topic, slug: 'my-slug')
    stubs(:params).returns(controller: 'announcements', action: 'index', "topics" => %w[my-slug three])

    assert_equal [{ name: topic.name, value: topic.slug, url: announcements_path(topics: %w[three]), joining: '' }], filter_results_selections([topic], 'topics')
  end

  test "filter_results_selections handles when params aren't in the expected format" do
    topic = build(:topic, slug: 'my-slug')
    stubs(:params).returns(controller: 'announcements', action: 'index', "topics" => 'my-slug')

    assert_equal [{ name: topic.name, value: topic.slug, url: announcements_path, joining: '' }], filter_results_selections([topic], 'topics')
  end

  test "filter_results_keywords gets objects ready for mustache" do
    stubs(:params).returns(controller: 'announcements', action: 'index', "keywords" => 'one two')

    assert_equal({ name: 'one two', url: announcements_path }, filter_results_keywords(%w{one two}))
  end

  test "#organisation_filter_options makes option tags with organsation name as text and slug as value" do
    org = create(:ministerial_department, :with_published_edition, name: "Some organisation")
    option_set = Nokogiri::HTML::DocumentFragment.parse(organisation_filter_options)
    option_set.at_css('optgroup option').tap { |option|
      assert_equal org.name, option.text
      assert_equal org.slug, option["value"]
    }
  end

  test "#organisation_filter_options makes an 'All departments' option tag" do
    option_set = Nokogiri::HTML::DocumentFragment.parse(organisation_filter_options)
    option_set.at_css('option').tap { |option|
      assert_equal 'All departments', option.text
      assert_equal 'all', option["value"]
    }
  end

  test "#organisation_filter_options return organisations as select options grouped into \
    'Ministerial departments', 'Other departments & public bodies' and 'Closed organisations'" do
    _ministerial_dept = create(:ministerial_department, :with_published_edition, name: "Ministerial department")
    _other_dept = create(:executive_office, :with_published_edition, name: "Other department")
    _closed_ministerial_dept = create(:ministerial_department, :with_published_edition, :closed, name: "1-Closed Ministerial department")
    _closed_other_dept = create(:executive_office, :with_published_edition, :closed, name: "2-Closed Other department")

    option_set = Nokogiri::HTML::DocumentFragment.parse(organisation_filter_options)

    expected_options = [
      ["Ministerial departments", ["Ministerial department"]],
      ["Other departments & public bodies", ["Other department"]],
      ["Closed organisations", ["1-Closed Ministerial department", "2-Closed Other department"]],
    ]

    actual_options = option_set
                       .css('optgroup')
                       .map { |optgroup| [optgroup["label"], optgroup.css("option").map(&:text)] }

    assert_equal expected_options, actual_options
  end

  test "#official_document_status_filter_options should return the options 'All statuses', 'Command papers' and 'Act papers'" do
    option_set = Nokogiri::HTML::DocumentFragment.parse(official_document_status_filter_options)

    option_set.css("option")[0].tap { |option|
      assert_equal "All documents", option.text
      assert_equal "all", option['value']
    }
    option_set.css("option")[1].tap { |option|
      assert_equal "Command or act papers", option.text
      assert_equal "command_and_act_papers", option['value']
    }
    option_set.css("option")[2].tap { |option|
      assert_equal "Command papers only", option.text
      assert_equal "command_papers_only", option['value']
    }
    option_set.css("option")[3].tap { |option|
      assert_equal "Act papers only", option.text
      assert_equal "act_papers_only", option['value']
    }
  end

  test "#official_document_status_filter_options should select the passed in option" do
    option_set = Nokogiri::HTML::DocumentFragment.parse(official_document_status_filter_options(:command_papers_only))

    assert_equal "Command papers only", option_set.at_css("option[selected]").text
  end
end
