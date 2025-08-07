require "test_helper"

class ApplicationHelperTest < ActionView::TestCase
  include ERB::Util
  include Rails.application.routes.url_helpers

  delegate :request, to: :controller

  test "#link_to_attachment returns nil when attachment is nil" do
    assert_nil link_to_attachment(nil)
  end

  test "#link_to_attachment returns a link to external attachment" do
    attachment = build(:external_attachment)
    assert_equal %(<a href="#{attachment.url}">#{attachment.external_url}</a>), link_to_attachment(attachment)
  end

  test "#link_to_attachment returns link to file attachment if attachment has all asset variants" do
    attachment = build(:file_attachment)
    assert_equal %(<a href="#{attachment.url}">#{attachment.filename}</a>), link_to_attachment(attachment)
  end

  test "#link_to_attachment returns a span element if file attachment has no assets" do
    attachment = build(:file_attachment_with_no_assets)
    assert_equal %(<span>#{attachment.filename}</span>), link_to_attachment(attachment)
  end

  test "#link_to_attachment_data returns a link if file attachment has all asset variants" do
    attachment_data = build(:attachment_data)
    assert_equal %(<a class="govuk-link" href="#{attachment_data.url}">#{attachment_data.filename}</a>), link_to_attachment_data(attachment_data)
  end

  test "#link_to_attachment_data returns a span if attachment has no assets" do
    attachment_data = build(:attachment_data_with_no_assets)
    assert_equal %(<span>#{attachment_data.filename}</span>), link_to_attachment_data(attachment_data)
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

  test "add_indefinite_article prepends word with 'an' when a word starts with a vowel" do
    %w[
      apple
      egg
      igloo
      office
      unlikely
    ].each do |word|
      assert_equal add_indefinite_article(word), "an #{word}"
    end
  end

  test "add_indefinite_article prepends word with 'a' when a word does not start with a vowel" do
    %w[
      bike
      car
      dog
      flag
      goat
    ].each do |word|
      assert_equal add_indefinite_article(word), "a #{word}"
    end
  end

  test "collect_filtered_validation_errors prioritizes specific over generic errors and handles multiple records" do
    record_with_mixed_errors = create_record_with_errors(
      create_error(:body, "Contact ID 123 doesn't exist"),
      create_error(:attachments, "is invalid"),
    )

    result = collect_filtered_validation_errors(record_with_mixed_errors)
    assert_includes result, "Body Contact ID 123 doesn't exist"
    assert_not_includes result, "Attachments is invalid"

    record1 = create_record_with_errors(create_error(:body, "Contact ID 999999 doesn't exist"))
    record2 = create_record_with_errors(
      create_error(:attachments, "is invalid"),
      create_error(:govspeak_content, "Contact ID 888888 doesn't exist"),
    )
    record3 = create_record_with_errors(create_error(:body, "Contact ID 999999 doesn't exist"))

    result_multiple = collect_filtered_validation_errors([record1, record2, record3])

    assert_includes result_multiple, "Body Contact ID 999999 doesn't exist"
    assert_includes result_multiple, "Govspeak content Contact ID 888888 doesn't exist"
    assert_not_includes result_multiple, "Attachments is invalid"
    assert_equal 2, result_multiple.length
  end

  test "collect_edition_and_attachment_error_sources gathers all error sources" do
    edition = mock("edition")
    html_attachment = mock("html_attachment")
    file_attachment = mock("file_attachment")

    edition.expects(:respond_to?).with(:html_attachments).returns(true)
    edition.expects(:respond_to?).with(:file_attachments).returns(true)
    edition.expects(:html_attachments).returns([html_attachment])
    edition.expects(:file_attachments).returns([file_attachment])

    result = collect_edition_and_attachment_error_sources(edition)

    assert_equal [edition, html_attachment, file_attachment], result

    edition_without_file_attachments = mock("edition_without_file_attachments")
    edition_without_file_attachments.expects(:respond_to?).with(:html_attachments).returns(true)
    edition_without_file_attachments.expects(:respond_to?).with(:file_attachments).returns(false)
    edition_without_file_attachments.expects(:html_attachments).returns([html_attachment])

    result_partial = collect_edition_and_attachment_error_sources(edition_without_file_attachments)

    assert_equal [edition_without_file_attachments, html_attachment], result_partial
  end

  test "collect_filtered_validation_errors shows all errors when no specific ones exist and preserves specific attachment errors" do
    record_generic = create_record_with_errors(
      create_error(:attachments, "is invalid"),
      create_error(:html_attachments, "is invalid"),
    )

    result_generic = collect_filtered_validation_errors(record_generic)
    assert_includes result_generic, "Attachments is invalid"
    assert_includes result_generic, "Html attachments is invalid"

    record_specific = create_record_with_errors(
      create_error(:attachments, "must have finished uploading"),
    )

    result_specific = collect_filtered_validation_errors(record_specific)
    assert_includes result_specific, "Attachments must have finished uploading"
  end

private

  def create_error(attribute, message)
    error = mock("error_#{attribute}_#{message.gsub(/\W/, '_')}")
    error.stubs(:attribute).returns(attribute)
    error.stubs(:message).returns(message)

    humanized_attribute = case attribute.to_s
                          when "html_attachments" then "Html attachments"
                          when "govspeak_content" then "Govspeak content"
                          else
                            attribute.to_s.humanize
                          end

    error.stubs(:full_message).returns("#{humanized_attribute} #{message}")
    error
  end

  def create_record_with_errors(*errors)
    record = mock("record_with_#{errors.length}_errors")
    record.stubs(:errors).returns(errors)
    record
  end

  def appoint_minister(attributes = {})
    organisation_name = attributes.delete(:organisation)
    organisation = Organisation.find_by(name: organisation_name) || create(:organisation, name: organisation_name)
    role_name = attributes.delete(:role)
    role = organisation.ministerial_roles.find_by(name: role_name) || create(:ministerial_role, name: role_name, organisations: [organisation])
    person = create(:person, forename: attributes.delete(:forename), surname: attributes.delete(:surname))
    create(:role_appointment, attributes.merge(role:, person:))
  end
end
