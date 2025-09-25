require "test_helper"

class FileAttachmentTest < ActiveSupport::TestCase
  def attachment
    @attachment ||= build(:file_attachment)
  end

  def assert_delegated(attachment, method)
    attachment.attachment_data.expects(method).returns(method.to_s)
    assert_equal method.to_s, attachment.send(method)
  end

  test "asks data for file specific information" do
    assert_delegated attachment, :url
    assert_delegated attachment, :content_type
    assert_delegated attachment, :pdf?
    assert_delegated attachment, :file_extension
    assert_delegated attachment, :file_size
    assert_delegated attachment, :number_of_pages
    assert_delegated attachment, :file
    assert_delegated attachment, :filename
  end

  test "html? is false" do
    assert_not attachment.html?
  end

  test "should be invalid if an attachment already exists on the attachable with the same filename" do
    attachable = create(:policy_group, attachments: [build(:file_attachment, file: file_fixture("whitepaper.pdf"))])
    duplicate  = build(:file_attachment, file: file_fixture("whitepaper.pdf"), attachable:)

    assert_not duplicate.valid?(:user_input)
    assert_match %r{with name "whitepaper.pdf" already attached to document}, duplicate.attachment_data.errors[:file].first
  end

  test "unique filename check does not explode if file is not present" do
    attachable = create(:policy_group, attachments: [build(:file_attachment)])
    attachment = build(:file_attachment, attachable:, file: nil)

    assert_not attachment.valid?
    assert_match %r{cannot be blank}, attachment.errors[:"attachment_data.file"].first
  end

  test "update with empty nested attachment data attributes still works" do
    attachment = create(:file_attachment)

    params = {
      "title" => "Filename",
      "attachment_data_attributes" => {
        "file_cache" => "", "to_replace_id" => attachment.attachment_data.id
      },
    }
    attachment.reload

    assert attachment.update(params), attachment.errors.full_messages.to_sentence
    assert_equal "Filename", attachment.title
  end

  test "filename changed returns true when updated with a file with a new name" do
    attachment = create(:file_attachment)

    assert_not attachment.filename_changed?
    attachment.attachment_data.file = {}
    assert attachment.filename_changed?
  end

  test "#assets returns assets list if all_asset_variants_uploaded?" do
    attachment = create(:csv_attachment, attachable: create(:edition))

    assert_equal [{ "asset_manager_id": attachment.attachment_data.assets.first.asset_manager_id, "filename": attachment.attachment_data.assets.first.filename }], attachment.publishing_api_details_for_format[:assets]
  end

  test "CSV attachments attached to editions can be previewed" do
    csv_on_edition = create(:csv_attachment, attachable: create(:edition))
    assert csv_on_edition.previewable?
  end

  test "non-CSV attachments are not previewable" do
    non_csv_on_edition = create(:file_attachment, attachable: create(:edition))
    assert_not non_csv_on_edition.previewable?
  end

  test "CSV attachments attached to non-editions are not previewable" do
    csv_on_policy_group = create(:csv_attachment, attachable: create(:policy_group))
    assert_not csv_on_policy_group.previewable?
  end

  test "component params for File attachment" do
    file = File.open("test/fixtures/sample.docx")
    attachment = create(:file_attachment, { file: })
    expect_params = {
      type: "file",
      id: "sample.docx", # embeddable in Govspeak as [Attachment:sample.docx]
      title: attachment.title,
      url: attachment.url,
      content_type: "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
      filename: attachment.filename,
      file_size: attachment.file_size,
    }
    assert_equal expect_params, attachment.publishing_component_params
  end

  test "component params for PDF attachment" do
    file = File.open("test/fixtures/two-pages.pdf")
    attachment = create(:file_attachment, { file: })
    expect_params = {
      type: "file",
      id: attachment.filename,
      title: attachment.title,
      url: attachment.url,
      content_type: "application/pdf",
      filename: attachment.filename,
      file_size: attachment.file_size,
      number_of_pages: 2,
    }
    assert_equal expect_params, attachment.publishing_component_params
  end

  test "component params for File attachment with reference fields" do
    file = File.open("test/fixtures/sample.docx")
    attachment = create(:file_attachment, {
      file:,
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
    assert_equal expect_params, attachment.publishing_component_params
  end

  test "component params for File attachment with unnumbered reference fields" do
    file = File.open("test/fixtures/sample.docx")
    attachment = create(:file_attachment, {
      file:,
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
    assert_equal expect_params, attachment.publishing_component_params
  end

  test "component params only have alternative_format_contact_email when attachment is inaccessible" do
    file = File.open("test/fixtures/sample.docx")
    inaccessible_attachment = create(:file_attachment, { file:, accessible: false })
    inaccessible = inaccessible_attachment.publishing_component_params

    accessible = create(:file_attachment, { file:, accessible: true }).publishing_component_params

    assert inaccessible[:alternative_format_contact_email].eql? inaccessible_attachment.alternative_format_contact_email
    assert_not accessible.key? :alternative_format_contact_email
  end

  test "attachment_component_params for previewable CSV" do
    attachment = create(:csv_attachment, attachable: create(:edition))
    expect_params = {
      type: "file",
      id: attachment.filename,
      title: attachment.title,
      url: attachment.url,
      content_type: "text/csv",
      filename: attachment.filename,
      file_size: attachment.file_size,
      preview_url: "/csv-preview/asset_manager_id/sample.csv",
    }
    assert_equal expect_params, attachment.publishing_component_params
  end
end
