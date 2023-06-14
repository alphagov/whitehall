require "test_helper"

class AttachmentsHelperTest < ActionView::TestCase
  test "CSV attachments attached to editions can be previewed" do
    csv_on_edition = create(:csv_attachment, attachable: create(:edition))
    assert previewable?(csv_on_edition)
  end

  test "non-CSV attachments are not previewable" do
    non_csv_on_edition = create(:file_attachment, attachable: create(:edition))
    assert_not previewable?(non_csv_on_edition)
  end

  test "CSV attachments attached to non-editions are not previewable" do
    csv_on_policy_group = create(:csv_attachment, attachable: create(:policy_group))
    assert_not previewable?(csv_on_policy_group)
  end

  test "block_attachments renders an array of rendered attachments" do
    alternative_format_contact_email = "test@example.com"
    attachments = [
      create(:html_attachment),
      create(:external_attachment),
      create(:file_attachment, accessible: false),
    ]

    rendered_attachments = block_attachments(attachments, alternative_format_contact_email)

    rendered_attachments.each.with_index do |rendered, index|
      attachment = attachments[index]
      assert_select_within_html(rendered, ".gem-c-attachment")
      assert_select_within_html(rendered, ".gem-c-attachment__title a", text: attachment.title) do |link|
        assert_equal attachment.url, link.attr("href").to_s
      end
      assert_select_within_html(rendered, "a", text: alternative_format_contact_email) if index == 2
    end
  end

  test "component params for HTML attachment" do
    attachment = create(:html_attachment)
    expect_params = {
      type: "html",
      title: attachment.title,
      url: attachment.url,
    }
    assert_equal expect_params, attachment_component_params(attachment)
  end

  test "component params for External attachment" do
    attachment = create(:external_attachment)
    expect_params = {
      type: "external",
      title: attachment.title,
      url: attachment.url,
    }
    assert_equal expect_params, attachment_component_params(attachment)
  end

  test "component params for File attachment" do
    attachment = file_attachment("sample.docx")
    expect_params = {
      type: "file",
      id: "sample.docx", # embeddable in Govspeak as [Attachment:sample.docx]
      title: attachment.title,
      url: attachment.url,
      content_type: "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
      filename: attachment.filename,
      file_size: attachment.file_size,
    }
    assert_equal expect_params, attachment_component_params(attachment)
  end

  test "component params for PDF attachment" do
    attachment = file_attachment("two-pages.pdf")
    expect_params = {
      type: "file",
      id: attachment.filename,
      title: attachment.title,
      url: attachment.url,
      content_type: "application/pdf",
      filename: attachment.filename,
      file_size: attachment.file_size,
      thumbnail_url: attachment.file.thumbnail.url,
      number_of_pages: 2,
    }
    assert_equal expect_params, attachment_component_params(attachment)
  end

  test "component params for previewable CSV attachment" do
    attachment = file_attachment("sample.csv", attachable: create(:edition))
    expect_params = {
      type: "file",
      id: attachment.filename,
      title: attachment.title,
      url: attachment.url,
      content_type: "text/csv",
      filename: attachment.filename,
      file_size: attachment.file_size,
      preview_url: preview_path_for_attachment(attachment),
    }
    assert_equal expect_params, attachment_component_params(attachment)
  end

  test "component params for File attachment with reference fields" do
    attachment = file_attachment("sample.docx", {
      isbn: "0261102737",
      unique_reference: "something unique",
      command_paper_number: "12345",
      hoc_paper_number: "98765",
      parliamentary_session: "2018-19",
    })
    expect_params = {
      type: "file",
      id: attachment.filename,
      title: attachment.title,
      url: attachment.url,
      content_type: "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
      filename: attachment.filename,
      file_size: attachment.file_size,
      isbn: attachment.isbn,
      unique_reference: attachment.unique_reference,
      command_paper_number: attachment.command_paper_number,
      hoc_paper_number: attachment.hoc_paper_number,
      parliamentary_session: "2018-19",
    }
    assert_equal expect_params, attachment_component_params(attachment)
  end

  test "component params for File attachment with unnumbered reference fields" do
    attachment = file_attachment("sample.docx", {
      unnumbered_command_paper: true,
      unnumbered_hoc_paper: true,
    })
    expect_params = {
      type: "file",
      id: attachment.filename,
      title: attachment.title,
      url: attachment.url,
      content_type: "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
      filename: attachment.filename,
      file_size: attachment.file_size,
      unnumbered_command_paper: true,
      unnumbered_hoc_paper: true,
    }
    assert_equal expect_params, attachment_component_params(attachment)
  end

  test "component params only have alternative_format_contact_email when attachment is inaccessible" do
    alternative_format_contact_email = "test@example.com"

    inaccessible = attachment_component_params(
      file_attachment("sample.docx", accessible: false),
      alternative_format_contact_email:,
    )

    accessible = attachment_component_params(
      file_attachment("sample.docx", accessible: true),
      alternative_format_contact_email:,
    )

    assert inaccessible[:alternative_format_contact_email].eql? alternative_format_contact_email
    assert_not accessible.key? :alternative_format_contact_email
  end

  def file_attachment(file_name, params = {})
    file = File.open(Rails.root.join("test/fixtures", file_name))
    create(:file_attachment, params.merge({ file: }))
  end
end
