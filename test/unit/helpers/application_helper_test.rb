require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase
  test "should supply options with IDs and descriptions for the all ministerial appointments" do
    theresa_may_appointment = appoint_minister(forename: "Theresa", surname: "May", role: "Secretary of State", organisation: "Home Office", started_at: Date.parse('2011-01-01'))
    philip_hammond_appointment = appoint_minister(forename: "Philip", surname: "Hammond", role: "Secretary of State", organisation: "Ministry of Defence", started_at: Date.parse('2011-01-01'))
    philip_hammond_home_secretary_appointment = appoint_minister(forename: "Philip", surname: "Hammond", role: "Secretary of State", organisation: "Home Office", started_at: Date.parse('2010-01-01'), ended_at: Date.parse('2011-01-01'))

    options = ministerial_appointment_options

    assert_equal 3, options.length
    assert options.include? [philip_hammond_appointment.id, "Philip Hammond, Secretary of State, in Ministry of Defence"]
    assert options.include? [philip_hammond_home_secretary_appointment.id, "Philip Hammond, as Secretary of State (01 January 2010 to 01 January 2011), in Home Office"]
    assert options.include? [theresa_may_appointment.id, "Theresa May, Secretary of State, in Home Office"]
  end

  test "should supply options with IDs and descriptions for all the ministerial roles" do
    theresa_may_appointment = appoint_minister(forename: "Theresa", surname: "May", role: "Secretary of State", organisation: "Home Office", started_at: Date.parse('2011-01-01'))
    philip_hammond_appointment = appoint_minister(forename: "Philip", surname: "Hammond", role: "Secretary of State", organisation: "Ministry of Defence", started_at: Date.parse('2011-01-01'))
    home_secretary = theresa_may_appointment.role
    defence_secretary = philip_hammond_appointment.role

    options = ministerial_role_options

    assert_equal 2, options.length
    assert options.include? [defence_secretary.id, "Secretary of State, in Ministry of Defence (Philip Hammond)"]
    assert options.include? [home_secretary.id, "Secretary of State, in Home Office (Theresa May)"]
  end

  test "should not include non-ministerial appointments" do
    create(:board_member_role_appointment)
    assert_equal [], ministerial_appointment_options
  end

  test '#link_to_attachment returns nil when attachment is nil' do
    assert_nil link_to_attachment(nil)
  end

  test '#link_to_attachment returns link to an attachment given attachment' do
    attachment = create(:attachment)
    assert_equal %{<a href="#{attachment.url}">#{File.basename(attachment.filename)}</a>}, link_to_attachment(attachment)
  end

  test "should format into paragraphs" do
    assert_equal "", format_in_paragraphs(nil)
    assert_equal "", format_in_paragraphs("")
    assert_equal "<p>line one</p>", format_in_paragraphs("line one")
    assert_equal "<p>line one\nline two</p>", format_in_paragraphs("line one\nline two")
    assert_equal "<p>line one\r\nline two</p>", format_in_paragraphs("line one\r\nline two")
    assert_equal "<p>line one</p><p>line two</p>", format_in_paragraphs("line one\n\nline two")
    assert_equal "<p>line one</p><p>line two</p>", format_in_paragraphs("line one\r\n\r\nline two")
    assert format_in_paragraphs("").html_safe?
  end

  test "should format with html line breaks and mark the string as html safe" do
    assert_equal "", format_with_html_line_breaks(nil)
    assert_equal "", format_with_html_line_breaks("")
    assert_equal "line 1", format_with_html_line_breaks("line 1")
    assert_equal "line 1<br/>line 2", format_with_html_line_breaks("line 1\nline 2")
    assert_equal "line 1<br/>line 2", format_with_html_line_breaks("line 1\r\nline 2")
    assert_equal "line 1<br/><br/>line 2", format_with_html_line_breaks("line 1\n\nline 2")
    assert_equal "line 1<br/><br/>line 2", format_with_html_line_breaks("line 1\r\n\r\nline 2")
    assert format_with_html_line_breaks("").html_safe?
  end

  test "should raise unless you supply the content of the list item" do
    e = assert_raise(ArgumentError) { render_list_of_ministerial_roles([]) }
    assert_match /please supply the content of the list item/i, e.message
  end

  test "should render a list of ministerial roles" do
    roles = [build(:ministerial_role, name: "Jack"), build(:ministerial_role,  name: "Jill")]
    html = render_list_of_ministerial_roles(roles) { |ministerial_role| "<p>#{ministerial_role.name}</p>" }
    assert_select_in_html(html, 'ul li p', text: "Jack")
    assert_select_in_html(html, 'ul li p', text: "Jill")
  end

  test "should render a object's datetime using the datetime microformat" do
    created_at = Time.zone.now
    object = stub(created_at: created_at)
    html = render_datetime_microformat(object, :created_at) { "human-friendly" }
    assert_select_in_html(html, "abbr.created_at[title='#{created_at.iso8601}']", text: "human-friendly")
  end

  test "should return the main type of the edition" do
    assert_equal "Consultation", human_friendly_edition_type(build(:consultation))
    assert_equal "News article", human_friendly_edition_type(build(:news_article))
    assert_equal "Policy", human_friendly_edition_type(build(:policy))
    assert_equal "Publication", human_friendly_edition_type(build(:publication))
    assert_equal "Speech", human_friendly_edition_type(build(:speech))
  end

  test "home page should be related to home main navigation" do
    assert_equal home_path, current_main_navigation_path(controller: "site", action: "index")
  end

  test "news-related & speech-related pages should be related to news & speeches main navigation" do
    assert_equal announcements_path, current_main_navigation_path(controller: "announcements", action: "index")
    assert_equal announcements_path, current_main_navigation_path(controller: "news_articles", action: "index")
    assert_equal announcements_path, current_main_navigation_path(controller: "news_articles", action: "show")
    assert_equal announcements_path, current_main_navigation_path(controller: "speeches", action: "index")
    assert_equal announcements_path, current_main_navigation_path(controller: "speeches", action: "show")
  end

  test "policy-related pages should be related to topics main navigation" do
    assert_equal topics_path, current_main_navigation_path(controller: "topics", action: "index")
    assert_equal topics_path, current_main_navigation_path(controller: "topics", action: "show")
    assert_equal topics_path, current_main_navigation_path(controller: "policies", action: "index")
    assert_equal topics_path, current_main_navigation_path(controller: "policies", action: "show")
    assert_equal topics_path, current_main_navigation_path(controller: "supporting_pages", action: "index")
    assert_equal topics_path, current_main_navigation_path(controller: "supporting_pages", action: "show")
  end

  test "publication-related pages should be related to publications main navigation" do
    assert_equal publications_path, current_main_navigation_path(controller: "publications", action: "index")
    assert_equal publications_path, current_main_navigation_path(controller: "publications", action: "show")
  end

  test "consultation-related pages should be related to consulatations main navigation" do
    assert_equal consultations_path, current_main_navigation_path(controller: "consultations", action: "index")
    assert_equal consultations_path, current_main_navigation_path(controller: "consultations", action: "open")
    assert_equal consultations_path, current_main_navigation_path(controller: "consultations", action: "closed")
    assert_equal consultations_path, current_main_navigation_path(controller: "consultations", action: "show")
    assert_equal consultations_path, current_main_navigation_path(controller: "consultation_responses", action: "show")
  end

  test "minister-related pages should be related to ministers main navigation" do
    assert_equal ministerial_roles_path, current_main_navigation_path(controller: "ministerial_roles", action: "index")
    assert_equal ministerial_roles_path, current_main_navigation_path(controller: "ministerial_roles", action: "show")
  end

  test "organisation-related pages should be related to organisations main navigation" do
    assert_equal organisations_path, current_main_navigation_path(controller: "organisations", action: "index")
    assert_equal organisations_path, current_main_navigation_path(controller: "organisations", action: "show")
    assert_equal organisations_path, current_main_navigation_path(controller: "organisations", action: "about")
    assert_equal organisations_path, current_main_navigation_path(controller: "organisations", action: "news")
  end

  test "country-related pages should be related to uk and the world main navigation" do
    assert_equal countries_path, current_main_navigation_path(controller: "countries", action: "index")
    assert_equal countries_path, current_main_navigation_path(controller: "countries", action: "show")
    assert_equal countries_path, current_main_navigation_path(controller: "international_priorities", action: "index")
    assert_equal countries_path, current_main_navigation_path(controller: "international_priorities", action: "show")
  end

  test "search result pages should not be related to main navigation" do
    assert_nil current_main_navigation_path(controller: "search", action: "index")
  end

  test "should add current class to link if current page is related to link" do
    stubs(:current_main_navigation_path).returns("/some/path")
    html = main_navigation_link_to("Inner Text", "/some/path", class: "class-1 class-2")
    anchor = Nokogiri::HTML.fragment(html)/"a"
    assert_equal "Inner Text", anchor.inner_text
    assert_equal "/some/path", anchor.attr("href").value
    classes = anchor.attr("class").value.split
    assert classes.include?("current")
    assert classes.include?("class-1")
    assert classes.include?("class-2")
  end

  test "should not add current class to link if current page is not related to link" do
    stubs(:current_main_navigation_path).returns("/some/other/path")
    html = main_navigation_link_to("Inner Text", "/some/path", class: "class-1 class-2")
    anchor = Nokogiri::HTML.fragment(html)/"a"
    assert_equal "Inner Text", anchor.inner_text
    assert_equal "/some/path", anchor.attr("href").value
    classes = anchor.attr("class").value.split
    refute classes.include?("current")
    assert classes.include?("class-1")
    assert classes.include?("class-2")
  end

  test "should group items into four columns in order" do
    items = %w[ a b c d e f g h i j k l ]
    expected = [%w[ a b c ], %w[ d e f ], %w[ g h i ], %w[ j k l ]]
    actual = []
    in_columns(items, 4) do |group|
      actual << group
    end
    assert_equal expected, actual
  end

  test "should group items into four columns for a range of collection sizes" do
    {
      1 => [1, 0, 0, 0],
      2 => [1, 1, 0, 0],
      3 => [1, 1, 1, 0],
      4 => [1, 1, 1, 1],
      5 => [2, 1, 1, 1],
      6 => [2, 2, 1, 1],
      7 => [2, 2, 2, 1],
      8 => [2, 2, 2, 2],
      9 => [3, 2, 2, 2],
    }.each do |num_items, expected|
      actual = []
      in_columns(["x"] * num_items, 4) do |group|
        actual << group.length
      end
      assert_equal expected, actual, "For #{num_items} items"
    end
  end

  test "should just return 'Publications' if there are no topics" do
    assert_equal "Publications", publications_page_title([])
  end

  test "should generate publications page title for one topic" do
    topic = create(:topic, name: "Farming")
    assert_equal "Publications about farming",
      publications_page_title([topic])
  end

  test "should generate publications page title for two topics" do
    topics = [
      "Farming", "Zombie preparedness"
    ].map { |n| create(:topic, name: n) }
    assert_equal "Publications about farming and zombie preparedness",
      publications_page_title(topics)
  end

  test "should generate publications page title for three or more topics" do
    topics = [
      "Farming", "Zombie preparedness", "Cats"
    ].map { |n| create(:topic, name: n) }
    assert_equal "Publications about farming, zombie preparedness and cats",
      publications_page_title(topics)
  end

  private

  def appoint_minister(attributes = {})
    organisation_name = attributes.delete(:organisation)
    organisation = Organisation.find_by_name(organisation_name) || create(:organisation, name: organisation_name)
    role_name = attributes.delete(:role)
    role = organisation.ministerial_roles.find_by_name(role_name) || create(:ministerial_role, name: role_name, organisations: [organisation])
    person = create(:person, forename: attributes.delete(:forename), surname: attributes.delete(:surname))
    create(:role_appointment, attributes.merge(role: role, person: person))
  end

end