require "test_helper"

class BulkUploadTest < ActiveSupport::TestCase
  def attachments_params(*pairs)
    {}.tap do |params|
      pairs.each_with_index do |pair, i|
        attachment, data = pair
        params[i.to_s] = attachment.merge(attachment_data_attributes: data)
      end
    end
  end

  # Parameters suitable for posting to #create for attachments with new filenames
  def new_attachments_params
    attachments_params(
      [{ title: "Title 1" }, { file: upload_fixture("whitepaper.pdf") }],
      [{ title: "Title 2" }, { file: upload_fixture("simple.pdf") }],
    )
  end

  def invalid_new_attachments_params
    new_attachments_params.tap { |params| params["0"][:title] = "" }
  end

  test "builds Attachment instances for an array of files" do
    edition = create(:detailed_guide)
    files = %w[simple.pdf whitepaper.pdf].map { |f| upload_fixture(f) }

    bulk_upload = BulkUpload.new(edition)
    bulk_upload.build_attachments_from_files(files)
    assert_equal 2, bulk_upload.attachments.size
    assert_equal "simple.pdf", bulk_upload.attachments[0].filename
    assert_equal "whitepaper.pdf", bulk_upload.attachments[1].filename
  end

  test "loads attachments from the edition if filenames match and adds `new_filename`" do
    edition = create(:publication, :with_file_attachment)
    existing = edition.attachments.first
    edition.attachments << create(:external_attachment, title: "An external attachment", attachable: edition)
    edition.attachments << create(:html_attachment, title: "An HTML attachment", attachable: edition)
    files = ["whitepaper.pdf", existing.filename].map { |name| upload_fixture(name) }
    bulk_upload = BulkUpload.new(edition)
    bulk_upload.build_attachments_from_files(files)
    assert bulk_upload.attachments.first.new_record?, "Attachment should be new record"
    assert_not bulk_upload.attachments.last.new_record?, "Attachment shouldn't be new record"
    assert_equal "#{existing.attachment_data.filename_without_extension}_1.#{existing.file_extension}", bulk_upload.attachments.last.attachment_data.new_filename
  end

  test "always builds new AttachmentData instances from array of files" do
    edition = create(:detailed_guide, :with_file_attachment)
    existing = edition.attachments.first
    files = ["whitepaper.pdf", existing.filename].map { |name| upload_fixture(name) }
    bulk_upload = BulkUpload.new(edition)
    bulk_upload.build_attachments_from_files(files)
    assert(bulk_upload.attachments.all? { |a| a.attachment_data.new_record? })
  end

  test "sets replaced_by on existing AttachmentData when file re-attached" do
    edition = create(:detailed_guide, :with_file_attachment)
    existing = edition.attachments.first
    files = ["whitepaper.pdf", existing.filename].map { |name| upload_fixture(name) }
    bulk_upload = BulkUpload.new(edition)
    bulk_upload.build_attachments_from_files(files)
    new_attachment_data = bulk_upload.attachments.last.attachment_data
    new_attachment_data.attachable = edition
    new_attachment_data.save!
    assert_equal new_attachment_data, existing.attachment_data.reload.replaced_by
  end

  test "sets replaced_by on existing AttachmentData when file re-attached from attachments_attributes" do
    edition = create(:detailed_guide, :with_file_attachment)
    existing = edition.attachments.first
    params = attachments_params(
      [{ id: existing.id, title: "Title" }, { file: upload_fixture(existing.filename), attachable: edition, keep_or_replace: "replace" }],
    )
    bulk_upload = BulkUpload.new(edition)
    bulk_upload.build_attachments_from_params(params)
    bulk_upload.save_attachments
    new_attachment_data = bulk_upload.attachments.first.attachment_data
    assert_equal new_attachment_data, existing.attachment_data.reload.replaced_by
  end

  test "#save_attachments saves new attachments to the end of the edition's existing attachments" do
    edition = create(:detailed_guide, :with_file_attachment)
    attachment = edition.attachments.first
    params = attachments_params(
      [{ title: "Title 1" }, { file: upload_fixture("whitepaper.pdf") }],
      [{ title: "Title 2" }, { file: upload_fixture("simple.pdf") }],
    )

    bulk_upload = BulkUpload.new(edition)
    bulk_upload.build_attachments_from_params(params)

    assert_difference("edition.attachments.count", 2) do
      assert bulk_upload.save_attachments, "should return true"
      assert_equal attachment, edition.reload.attachments[0]
      assert_equal "Title 1", edition.attachments[1].title
      assert_equal "Title 2", edition.attachments[2].title
    end
  end

  test "#save_attachments updates existing attachments if replacement selected" do
    edition = create(:detailed_guide, :with_file_attachment)
    existing = edition.attachments.first
    new_title = "New title for existing attachment"
    params = attachments_params(
      [{ id: existing.id, title: new_title }, { file: upload_fixture(existing.filename), keep_or_replace: "replace" }],
    )

    bulk_upload = BulkUpload.new(edition)
    bulk_upload.build_attachments_from_params(params)

    bulk_upload.save_attachments
    assert_equal 1, edition.attachments.length
    assert_equal new_title, edition.attachments.reload.first.title
  end

  test "#save_attachments creates new attachment if existing attachment found and keep both selected" do
    edition = create(:detailed_guide, :with_file_attachment)
    existing = edition.attachments.first
    new_title = "New title for attachment"
    params = attachments_params(
      [{ id: existing.id, title: new_title }, { file: upload_fixture(existing.filename), keep_or_replace: "keep", new_filename: "new_filename.pdf" }],
    )

    bulk_upload = BulkUpload.new(edition)
    bulk_upload.build_attachments_from_params(params)

    bulk_upload.save_attachments
    assert_equal 2, edition.attachments.reload.length
    assert_equal new_title, edition.attachments.reload.second.title
    assert_equal "new_filename.pdf", edition.attachments.reload.second.attachment_data.filename
  end

  test "#save_attachments does not create new attachment if existing attachment found and cancel selected" do
    edition = create(:detailed_guide, :with_file_attachment)
    existing = edition.attachments.first
    new_title = "New title for attachment"
    params = attachments_params(
      [{ id: existing.id, title: new_title }, { file: upload_fixture(existing.filename), keep_or_replace: "reject", new_filename: "new_filename.pdf" }],
    )

    bulk_upload = BulkUpload.new(edition)
    bulk_upload.build_attachments_from_params(params)

    bulk_upload.save_attachments
    assert_equal 1, edition.attachments.reload.length
    assert_not_equal new_title, edition.attachments.reload.first.title
  end

  test "#save_attachments does not save any attachments if one is invalid" do
    edition = create(:detailed_guide)
    bulk_upload = BulkUpload.new(edition)
    bulk_upload.build_attachments_from_params(invalid_new_attachments_params)
    assert_no_difference("edition.attachments.count") do
      assert_not bulk_upload.save_attachments, "should return false"
    end
  end

  test "#save_attachments adds errors when attachments are invalid" do
    edition = create(:detailed_guide)
    bulk_upload = BulkUpload.new(edition)
    bulk_upload.build_attachments_from_params(invalid_new_attachments_params)
    assert_no_difference("edition.attachments.count") do
      assert_not bulk_upload.save_attachments, "should return false"
    end

    bulk_upload.save_attachments
    assert bulk_upload.errors.any?
  end
end
