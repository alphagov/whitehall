# encoding: UTF-8

require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase
  include ERB::Util
  include Rails.application.routes.url_helpers

  # Exposes request object to helper in tests
  def request
    controller.request
  end

  test "#policies_finder_path escapes provided query params" do
    assert_equal "/government/policies?organisations%5B%5D=slug",
      policies_finder_path(organisations: ['slug'])

    assert_equal "/government/policies?organisations%5B%5D=slug1&organisations%5B%5D=slug2",
      policies_finder_path(organisations: ['slug1', 'slug2'])

    assert_equal "/government/policies?keywords=word&organisations%5B%5D=slug1",
      policies_finder_path(keywords: 'word', organisations: ['slug1'])
  end

  test '#link_to_attachment returns nil when attachment is nil' do
    assert_nil link_to_attachment(nil)
  end

  test '#link_to_attachment returns link to an attachment given attachment' do
    attachment = create(:file_attachment)
    assert_equal %{<a href="#{attachment.url}">#{File.basename(attachment.filename)}</a>}, link_to_attachment(attachment)
  end

  test '#link_to_attachment truncates filename if :truncate is true' do
    attachment = create(:file_attachment, file: File.open(Rails.root.join('test', 'fixtures', 'consultation_uploader_test_sample.csv')))
    assert_equal %{<a href="#{attachment.url}">consultation_uploader_test_...</a>}, link_to_attachment(attachment, truncate: true)
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

  test "should format with html line breaks, escape special chars and mark the string as html safe" do
    assert_equal "", format_with_html_line_breaks(nil)
    assert_equal "", format_with_html_line_breaks("")
    assert_equal "line 1", format_with_html_line_breaks("line 1")
    assert_equal "line 1", format_with_html_line_breaks("line 1\n")
    assert_equal "line 1", format_with_html_line_breaks("line 1\r\n")
    assert_equal "line 1<br/>line 2", format_with_html_line_breaks("line 1\nline 2")
    assert_equal "line 1<br/>line 2", format_with_html_line_breaks("line 1\r\nline 2")
    assert_equal "line 1<br/><br/>line 2", format_with_html_line_breaks("line 1\n\nline 2")
    assert_equal "line 1<br/><br/>line 2", format_with_html_line_breaks("line 1\r\n\r\nline 2")
    assert_equal "&lt;script&gt;&amp;", format_with_html_line_breaks("<script>&")
    assert format_with_html_line_breaks("").html_safe?
  end

  test "should raise unless you supply the content of the list item" do
    e = assert_raise(ArgumentError) { render_list_of_ministerial_roles([]) }
    assert_match /please supply the content of the list item/i, e.message
  end

  test "should render a list of ministerial roles" do
    roles = [build(:ministerial_role, name: "Jack"), build(:ministerial_role,  name: "Jill")]
    html = render_list_of_ministerial_roles(roles) { |ministerial_role| "<p>#{ministerial_role.name}</p>" }
    assert_select_within_html(html, 'ul li p', text: "Jack")
    assert_select_within_html(html, 'ul li p', text: "Jill")
  end

  test "should render a object's datetime using the datetime microformat" do
    created_at = Time.zone.now
    object = stub(created_at: created_at)
    html = render_datetime_microformat(object, :created_at) { "human-friendly" }
    assert_select_within_html(html, "time.created_at[datetime='#{created_at.iso8601}']", text: "human-friendly")
  end

  test "home page should be related to home main navigation" do
    assert_equal root_path, current_main_navigation_path(controller: "site", action: "index")
  end

  test "news-related & speech-related pages should be related to news & speeches main navigation" do
    assert_equal announcements_path, current_main_navigation_path(controller: "announcements", action: "index")
    assert_equal announcements_path, current_main_navigation_path(controller: "news_articles", action: "index")
    assert_equal announcements_path, current_main_navigation_path(controller: "news_articles", action: "show")
    assert_equal announcements_path, current_main_navigation_path(controller: "speeches", action: "index")
    assert_equal announcements_path, current_main_navigation_path(controller: "speeches", action: "show")
  end

  test "topic-related pages should be related to topics main navigation" do
    assert_equal topics_path, current_main_navigation_path(controller: "topics", action: "index")
    assert_equal topics_path, current_main_navigation_path(controller: "topics", action: "show")
  end

  test "publication-related pages should be related to publications main navigation" do
    assert_equal publications_path, current_main_navigation_path(controller: "publications", action: "index")
    assert_equal publications_path, current_main_navigation_path(controller: "publications", action: "show")
  end

  test "statistics-related publication filter should be related to statistics main navigation" do
    assert_equal publications_path(publication_filter_option: 'statistics'), current_main_navigation_path(controller: "publications", action: "index", publication_filter_option: 'statistics')
  end

  test "consultation-related pages should be related to consulatations main navigation" do
    expected = publications_path(publication_filter_option: 'consultations')
    assert_equal expected, current_main_navigation_path(controller: "consultations", action: "index")
    assert_equal expected, current_main_navigation_path(controller: "consultations", action: "open")
    assert_equal expected, current_main_navigation_path(controller: "consultations", action: "closed")
    assert_equal expected, current_main_navigation_path(controller: "consultations", action: "show")
    assert_equal expected, current_main_navigation_path(controller: "consultation_responses", action: "show")
    assert_equal expected, current_main_navigation_path(controller: "publications", action: "index", publication_filter_option: 'consultations')
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

  test "world location pages should be related to uk and the world main navigation" do
    assert_equal world_locations_path(locale: :en), current_main_navigation_path(controller: "world_locations", action: "index")
    assert_equal world_locations_path(locale: :en), current_main_navigation_path(controller: "world_locations", action: "show")
  end

  test "world locations index is forced to English locale in main navigation" do
    assert_equal world_locations_path(locale: :en), current_main_navigation_path(controller: "world_locations", action: "index", locale: :dk)
  end

  test "search result pages should not be related to main navigation" do
    assert_nil current_main_navigation_path(controller: "search", action: "index")
  end

  test "should add current class to link if current page is related to link" do
    stubs(:current_main_navigation_path).returns("/some/path")
    html = main_navigation_link_to("Inner Text", "/some/path", class: "class-1 class-2")
    anchor = Nokogiri::HTML.fragment(html) / "a"
    assert_equal "Inner Text", anchor.inner_text
    assert_equal "/some/path", anchor.attr("href").value
    classes = anchor.attr("class").value.split
    assert classes.include?("active")
    assert classes.include?("class-1")
    assert classes.include?("class-2")
  end

  test "should not add current class to link if current page is not related to link" do
    stubs(:current_main_navigation_path).returns("/some/other/path")
    html = main_navigation_link_to("Inner Text", "/some/path", class: "class-1 class-2")
    anchor = Nokogiri::HTML.fragment(html) / "a"
    assert_equal "Inner Text", anchor.inner_text
    assert_equal "/some/path", anchor.attr("href").value
    classes = anchor.attr("class").value.split
    refute classes.include?("active")
    assert classes.include?("class-1")
    assert classes.include?("class-2")
  end

  test "correctly identifies external links" do
    assert is_external?('http://www.facebook.com/something'), 'wrong host'
    refute is_external?('/something'), 'no host'
    refute is_external?(Whitehall.public_root), 'good host'
    refute is_external?("#{Whitehall.public_root}/something"), 'good host with path'
  end

  test "full_width_tabs should render tabs" do
    request.stubs(:path).returns("/stationary")

    rendered = Nokogiri::HTML::DocumentFragment.parse(full_width_tabs [
      { label: "Guitar tabs", link_to: "/hipster-guitars" },
      { label: "Document tabs", link_to: "/stationary" }
    ]).children.first

    assert_equal "nav", rendered.name
    assert_equal "activity-navigation", rendered[:class]
    links = rendered.css "li a"
    assert_equal "Guitar tabs", links[0].text
    assert_equal "/hipster-guitars", links[0][:href]
    refute links[0][:class].to_s.include? "current"
    assert_equal "Document tabs", links[1].text
    assert_equal "/stationary", links[1][:href]
    assert links[1][:class].to_s.include? "current"
  end

  test "full_width_tabs supports :current_when" do
    rendered = Nokogiri::HTML::DocumentFragment.parse(full_width_tabs [
      { label: "Guitar tabs", link_to: "/hipster-guitars", current_when: false },
      { label: "Document tabs", link_to: "/stationary", current_when: true }
    ]).children.first

    refute rendered.at_xpath(".//a[.='Guitar tabs']")[:class].to_s.include? 'current'
    assert rendered.at_xpath(".//a[.='Document tabs']")[:class].to_s.include? 'current'
  end

  private

  def appoint_minister(attributes = {})
    organisation_name = attributes.delete(:organisation)
    organisation = Organisation.find_by(name: organisation_name) || create(:organisation, name: organisation_name)
    role_name = attributes.delete(:role)
    role = organisation.ministerial_roles.find_by(name: role_name) || create(:ministerial_role, name: role_name, organisations: [organisation])
    person = create(:person, forename: attributes.delete(:forename), surname: attributes.delete(:surname))
    create(:role_appointment, attributes.merge(role: role, person: person))
  end

end
