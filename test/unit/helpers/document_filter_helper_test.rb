require 'test_helper'

class DocumentFilterHelperTest < ActionView::TestCase
  include ApplicationHelper

  test "#publication_types_for_filter returns all publication filter option types" do
    assert_equal Whitehall::PublicationFilterOption.all, publication_types_for_filter
  end

  test "#announcement_types_for_filter returns all announcement filter option types" do
    announcement_type_options = ["Press releases", "News stories", "Fatality notices", "Speeches", "Statements", "Government responses"]
    assert_equal announcement_type_options, announcement_types_for_filter.map(&:label)
  end

  test "remove_filter_from_params removes filter from params" do
    stubs(:params).returns({ first: 'one', second: ['two', 'three'] })

    assert_equal ({ first: nil, second: ['two', 'three'] }), remove_filter_from_params(:first)
    assert_equal ({ first: 'one', second: ['three'] }), remove_filter_from_params(:second, 'two')
  end

  test "filter_results_selections gets objects ready for mustache" do
    topic = build(:topic, slug: 'my-slug')
    stubs(:params).returns({ controller: 'announcements', action: 'index', "topics" => ['my-slug', 'three'] })

    assert_equal [{ name: topic.name, value: topic.slug, url: announcements_path(topics: ['three']), joining: '' }], filter_results_selections([topic], 'topics')
  end

  test "filter_results_selections handles when params aren't in the expected format" do
    topic = build(:topic, slug: 'my-slug')
    stubs(:params).returns({ controller: 'announcements', action: 'index', "topics" => 'my-slug' })

    assert_equal [{ name: topic.name, value: topic.slug, url: announcements_path, joining: '' }], filter_results_selections([topic], 'topics')
  end

  test "filter_results_keywords gets objects ready for mustache" do
    keywords = %w{one two}
    stubs(:params).returns({ controller: 'announcements', action: 'index', "keywords" => 'one two' })

    assert_equal [
      { name: 'one', url: announcements_path({ keywords: 'two' }), joining: 'or'},
      { name: 'two', url: announcements_path({ keywords: 'one' }), joining: ''},
    ], filter_results_keywords(keywords)
  end

  test "#organisation_filter_options makes option tags with organsation name as text and slug as value" do
    org = create(:ministerial_department, :with_published_edition, name: "Some organisation")
    option_set = Nokogiri::HTML::DocumentFragment.parse(organisation_filter_options)
    option_set.at_css('optgroup option').tap {|option|
      assert_equal org.name, option.text
      assert_equal org.slug, option["value"]
    }
  end

  test "#organisation_filter_options makes an 'All departments' option tag" do
    option_set = Nokogiri::HTML::DocumentFragment.parse(organisation_filter_options)
    option_set.at_css('option').tap {|option|
      assert_equal 'All departments', option.text
      assert_equal 'all', option["value"]
    }
  end

  test "#organisation_filter_options return organisations as select options grouped into \
    'Ministerial departments', 'Other departments & public bodies' and 'Closed organisations'" do
    ministerial_dept = create(:ministerial_department, :with_published_edition, name: "Ministerial department")
    other_dept = create(:executive_office, :with_published_edition, name: "Other department")
    closed_ministerial_dept = create(:ministerial_department, :with_published_edition, :closed, name: "1-Closed Ministerial department")
    closed_other_dept = create(:executive_office, :with_published_edition, :closed, name: "2-Closed Other department")

    option_set = Nokogiri::HTML::DocumentFragment.parse(organisation_filter_options)

    assert_equal [
      ["Ministerial departments", ["Ministerial department"]],
      ["Other departments & public bodies", ["Other department"]],
      ["Closed organisations", ["1-Closed Ministerial department", "2-Closed Other department"]],
    ], option_set.css('optgroup').map { |optgroup|
      [
        optgroup["label"],
        optgroup.css("option").map {|option| option.text}
      ]
    }
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
