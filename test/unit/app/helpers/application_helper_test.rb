require "test_helper"

class ApplicationHelperTest < ActionView::TestCase
  include ERB::Util
  include Rails.application.routes.url_helpers

  # Exposes request object to helper in tests
  delegate :request, to: :controller

  test "#link_to_attachment returns nil when attachment is nil" do
    assert_nil link_to_attachment(nil)
  end

  test "#link_to_attachment returns link to an attachment given attachment" do
    attachment = create(:file_attachment)
    assert_equal %(<a href="#{attachment.url}">#{File.basename(attachment.filename)}</a>), link_to_attachment(attachment)
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

  test "should render a object's datetime using the datetime microformat" do
    created_at = Time.zone.now
    object = stub(created_at:)
    html = render_datetime_microformat(object, :created_at) { "human-friendly" }
    assert_select_within_html(html, "time.created_at[datetime='#{created_at.iso8601}']", text: "human-friendly")
  end

  test "correctly identifies external links" do
    assert is_external?("http://www.facebook.com/something"), "wrong host"
    assert_not is_external?("/something"), "no host"
    assert_not is_external?(Whitehall.public_root), "good host"
    assert_not is_external?("#{Whitehall.public_root}/something"), "good host with path"
  end

private

  def appoint_minister(attributes = {})
    organisation_name = attributes.delete(:organisation)
    organisation = Organisation.find_by(name: organisation_name) || create(:organisation, name: organisation_name)
    role_name = attributes.delete(:role)
    role = organisation.ministerial_roles.find_by(name: role_name) || create(:ministerial_role, name: role_name, organisations: [organisation])
    person = create(:person, forename: attributes.delete(:forename), surname: attributes.delete(:surname))
    create(:role_appointment, attributes.merge(role:, person:))
  end
end
