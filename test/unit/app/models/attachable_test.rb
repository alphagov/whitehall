require "test_helper"

class AttachableTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess

  test "allows attachment" do
    assert build(:publication).allows_attachments?
  end

  test "allows different attachment types" do
    attachable = Publication.new
    assert attachable.allows_attachment_type?("file")
    assert attachable.allows_attachment_type?("external")
    assert attachable.allows_attachment_type?("html")
    assert_not attachable.allows_attachment_type?("unknown")
  end

  test "new attachments are put to the end of the list" do
    publication = create(
      :publication,
      :with_file_attachment,
      attachments: [
        attachment1 = build(:file_attachment, ordering: 0),
        attachment2 = build(:file_attachment, ordering: 1, file: file_fixture("whitepaper.pdf")),
      ],
    )

    attachment3 = FileAttachment.new(title: "Title", attachment_data: build(:attachment_data, file: file_fixture("sample.rtf"), attachable: publication))
    publication.attachments << attachment3

    assert_equal [attachment1, attachment2, attachment3], publication.attachments.reload
  end

  test "creating a new attachable thing with multiple attachments sets the correct ordering" do
    publication = build(
      :publication,
      :with_file_attachment,
      attachments: [
        attachment1 = build(:file_attachment),
        attachment2 = build(:file_attachment, file: file_fixture("whitepaper.pdf")),
      ],
    )

    publication.save!
    assert_equal [attachment1, attachment2], publication.attachments
    assert_equal 0, attachment1.ordering
    assert_equal 1, attachment2.ordering
  end

  test "should be invalid if an edition has an attachment but no alternative format provider" do
    attachment = build(:file_attachment)
    publication = build(:publication, attachments: [attachment], alternative_format_provider: nil)
    assert_not publication.valid?
  end

  test "should be invalid if an edition has an attachment but alternative format provider has no email address set" do
    attachment = build(:file_attachment)
    organisation = build(:organisation, alternative_format_contact_email: nil)
    publication = build(:publication, attachments: [attachment], alternative_format_provider: organisation)
    assert_not publication.valid?
  end

  test "should be valid without alternative format provider if no attachments" do
    publication = build(:publication, attachments: [])
    assert publication.valid?
  end

  def build_edition_with_three_attachments
    edition = create(:publication)

    edition.attachments << @sample_csv = create(:file_attachment, file: upload_fixture("sample-from-excel.csv", "text/csv"), attachable: edition)
    edition.attachments << @greenpaper_pdf = create(:file_attachment, file: upload_fixture("greenpaper.pdf", "application/pdf"), attachable: edition)
    edition.attachments << @two_pages_pdf = create(:file_attachment, file: upload_fixture("two-pages.pdf"), attachable: edition)

    edition
  end

  test "#reorder_attachments should update the ordering of its attachments" do
    attachable = create(:consultation)
    a, b, c = 3.times.map { create(:file_attachment, attachable:) }

    attachable.reload.reorder_attachments([b.id, a.id, c.id])

    assert_equal [b, a, c], attachable.reload.attachments
  end

  test "#reorder_attachments should handle existing negative orderings" do
    attachable = create(:consultation)
    a = create(:file_attachment, attachable:, ordering: -1)
    b = create(:file_attachment, attachable:, ordering: 0, file: file_fixture("whitepaper.pdf"))
    c = create(:file_attachment, attachable:, ordering: 1, file: file_fixture("simple.pdf"))

    attachable.reload.reorder_attachments([b.id, a.id, c.id])

    assert_equal [b, a, c], attachable.reload.attachments
  end

  test "#reorder_attachments handles deleted attachments that had high ordering values" do
    attachable = create(:consultation)
    a = create(:file_attachment, attachable:, ordering: 0)
    b = create(:file_attachment, attachable:, ordering: 1)
    create(:file_attachment, attachable:, ordering: 2, deleted: true)

    attachable.reload.reorder_attachments([b.id, a.id])

    assert_equal [b, a], attachable.reload.attachments
  end

  test "#reorder_attachments handles deleted attachments that had low ordering values" do
    attachable = create(:consultation)
    create(:file_attachment, attachable:, ordering: 0, deleted: true)
    create(:file_attachment, attachable:, ordering: 1, deleted: true)
    create(:file_attachment, attachable:, ordering: 2, deleted: true)
    a = create(:file_attachment, attachable:, ordering: 3)
    b = create(:file_attachment, attachable:, ordering: 4)

    attachable.reload.reorder_attachments([b.id, a.id])

    assert_equal [b, a], attachable.reload.attachments
  end

  test "has html_attachments association to fetch only HtmlAttachments" do
    attachment1 = build(:file_attachment, ordering: 0)
    attachment2 = build(:html_attachment, title: "Test HTML attachment", ordering: 1)
    attachment3 = build(:html_attachment, title: "Title", body: "Testing")

    publication = create(
      :publication,
      :with_file_attachment,
      attachments: [attachment1, attachment2],
    )

    publication.attachments << attachment3

    assert_equal [attachment2, attachment3], publication.html_attachments.reload
  end

  test "attachment association excludes soft-deleted Attachments" do
    publication = create(
      :publication,
      :with_file_attachment,
      attachments: [
        attachment1 = build(:file_attachment),
        build(:html_attachment, title: "HTML attachment", deleted: true),
      ],
    )

    assert_equal [attachment1], publication.attachments.reload
  end

  test "html_attachment association excludes soft-deleted HtmlAttachments" do
    publication = create(
      :publication,
      attachments: [
        attachment1 = build(:html_attachment, title: "Test HTML attachment"),
        build(:html_attachment, title: "Another HTML attachment", deleted: true),
      ],
    )

    assert_equal [attachment1], publication.html_attachments.reload
  end

  test "#has_command_paper? is true if an attachment is a command paper" do
    pub = build(:publication)
    pub.stubs(:attachments).returns([
      OpenStruct.new(is_command_paper?: false),
    ])
    assert_not pub.has_command_paper?

    pub.stubs(:attachments).returns([
      OpenStruct.new(is_command_paper?: false),
      OpenStruct.new(is_command_paper?: true),
    ])
    assert pub.has_command_paper?
  end

  test "#has_act_paper? is true if an attachment is an act paper" do
    pub = build(:publication)
    pub.stubs(:attachments).returns([
      OpenStruct.new(is_act_paper?: false),
    ])
    assert_not pub.has_act_paper?

    pub.stubs(:attachments).returns([
      OpenStruct.new(is_act_paper?: false),
      OpenStruct.new(is_act_paper?: true),
    ])
    assert pub.has_act_paper?
  end

  test "re-editioned editions deep-clones attachments" do
    file_attachment = build(:file_attachment, ordering: 0)
    html_attachment = build(:html_attachment, ordering: 1)
    publication = create(
      :published_publication,
      :with_alternative_format_provider,
      attachments: [file_attachment, html_attachment],
    )

    draft = publication.create_draft(create(:writer))

    assert_equal 2, draft.attachments.size

    attachment1 = draft.attachments[0]
    assert attachment1.persisted?
    assert file_attachment.id != attachment1.id
    assert_equal file_attachment.attachment_data, attachment1.attachment_data
    assert_equal file_attachment.title, attachment1.title

    attachment2 = draft.attachments[1]
    assert attachment2.persisted?
    assert html_attachment.id != attachment2.id
    assert_equal html_attachment.govspeak_content.body, attachment2.govspeak_content.body
    assert_equal html_attachment.title, attachment2.title
  end

  test "re-editioned editions persists invalid attachments" do
    file_attachment = build(:file_attachment, command_paper_number: "invalid")
    file_attachment.save!(validate: false)
    publication = create(
      :published_publication,
      :with_alternative_format_provider,
      attachments: [file_attachment],
    )

    draft = publication.create_draft(create(:writer))

    assert_equal 1, draft.reload.attachments.size
    assert draft.attachments[0].persisted?
  end

  test "#delete_all_attachments soft-deletes any attachments that the edition has" do
    publication = create(:draft_publication)

    publication.attachments << attachment1 = build(:file_attachment)
    publication.attachments << attachment2 = build(:html_attachment)

    publication.delete_all_attachments

    assert Attachment.find(attachment1.id).deleted?
    assert Attachment.find(attachment2.id).deleted?
  end

  test "#deleted_html_attachments returns associated HTML attachments that have been deleted" do
    publication = create(
      :draft_publication,
      attachments: [
        attachment1 = build(:html_attachment, title: "First"),
        attachment2 = build(:html_attachment, title: "Second"),
      ],
    )

    attachment1.destroy!
    attachment2.destroy!

    assert_equal [attachment1, attachment2], publication.deleted_html_attachments
  end

  test "#deleted_html_attachments doesn't return undeleted attachments" do
    publication = create(
      :draft_publication,
      attachments: [
        build(:html_attachment, title: "First"),
      ],
    )

    assert_empty publication.deleted_html_attachments
  end

  test "#deleted_attachments returns associated attachments that have been deleted" do
    publication = create(
      :draft_publication,
      :with_file_attachment,
      attachments: [
        attachment1 = build(:file_attachment, title: "First"),
        attachment2 = build(:html_attachment, title: "Second"),
      ],
    )

    publication.delete_all_attachments

    assert_equal [attachment1, attachment2], publication.deleted_attachments
  end

  test "#deleted_attachments doesn't return undeleted attachments" do
    publication = create(
      :draft_publication,
      :with_file_attachment,
      attachments: [
        build(:html_attachment),
        build(:file_attachment),
      ],
    )

    assert_empty publication.deleted_attachments
  end

  test "#changed_attachments returns an array of attachments that have been changed in this edition" do
    csv_file = File.open(Rails.root.join("test/fixtures/sample.csv"))
    docx_file = File.open(Rails.root.join("test/fixtures/sample.docx"))
    pdf_file = File.open(Rails.root.join("test/fixtures/simple.pdf"))
    rtf_file = File.open(Rails.root.join("test/fixtures/sample.rtf"))
    another_pdf_file = File.open(Rails.root.join("test/fixtures/whitepaper.pdf"))

    publication = create(:draft_publication, :with_file_attachment,
                         attachments: [
                           build(:file_attachment, file: csv_file),
                           build(:html_attachment),
                           changed_file = build(:file_attachment, file: docx_file),
                           changed_title = build(:file_attachment, file: pdf_file),
                           changed_html = build(:html_attachment),
                           deleted_html = build(:html_attachment),
                         ])

    # Allow the Edition creation 'grace period' to pass
    Timecop.travel Attachable::EDITION_CREATE_GRACE_PERIOD.from_now + 1.second

    # Create some new attachments
    publication.attachments << new_file = build(:file_attachment, file: another_pdf_file)
    publication.attachments << new_html = build(:html_attachment)

    # Replace the file on an attachment
    changed_file.update!(attachment_data: build(:attachment_data, file: rtf_file, attachable: publication))

    # Change title of an attachment
    changed_title.update!(title: "This attachment's title has been changed")

    # Change body of a HTML attachment
    changed_html.govspeak_content.update!(body: "This HTML attachment's body has been changed")

    # Delete an attachment
    deleted_html.destroy!

    # Ensure there are no duplicates
    changed_ids = publication.changed_attachments.map { |attachment| attachment.attachment.id }
    assert_equal changed_ids.uniq, changed_ids

    # Check the changed attachments are correct
    created_attachments = publication.changed_attachments.select { |attachment| attachment.status == :created }
    updated_attachments = publication.changed_attachments.select { |attachment| attachment.status == :updated }
    deleted_attachments = publication.changed_attachments.select { |attachment| attachment.status == :deleted }

    assert_equal([new_file, new_html], created_attachments.map(&:attachment))
    assert_equal([changed_file, changed_title, changed_html], updated_attachments.map(&:attachment))
    assert_equal([deleted_html], deleted_attachments.map(&:attachment))
  end

  test "#attachables returns array including itself" do
    attachable_edition = build(:edition)
    assert attachable_edition.allows_attachments?
    assert_equal [attachable_edition], attachable_edition.attachables
  end

  test "#attachments_uploaded_to_asset_manager? returns false if any of the assets are not ready" do
    file_attachment_with_all_assets = build(:file_attachment)
    file_attachment_with_missing_assets = build(:file_attachment_with_no_assets)
    attachable_edition = build(:edition)
    attachable_edition.attachments = [file_attachment_with_all_assets, file_attachment_with_missing_assets]

    assert_not attachable_edition.attachments_uploaded_to_asset_manager?
  end

  test "attachments_ready_for_publishing filters out file attachments with missing assets" do
    file_attachment_with_all_assets = build(:file_attachment)
    file_attachment_with_missing_assets = build(:file_attachment_with_no_assets)
    external_attachment = build(:external_attachment)

    publication = build(
      :publication,
      attachments: [
        file_attachment_with_all_assets,
        file_attachment_with_missing_assets,
        external_attachment,
      ],
    )

    assert_equal publication.attachments.length - 1, publication.attachments_ready_for_publishing.length
  end
end
