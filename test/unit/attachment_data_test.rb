require "test_helper"

class AttachmentDataTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess

  setup do
    AttachmentUploader.enable_processing = true
  end

  teardown do
    AttachmentUploader.enable_processing = false
  end

  test "should be invalid without a file" do
    attachment = build(:attachment_data, file: nil)
    assert_not attachment.valid?
  end

  test "is invalid with an empty file" do
    empty_file = upload_fixture("empty_file.txt", "text/plain")
    attachment = build(:attachment_data, file: empty_file)
    assert_not attachment.valid?
    assert_match %r{empty file}, attachment.errors[:file].first
  end

  test "returns its attachable's auth_bypass_id when it has one" do
    auth_bypass_id = "86385d6a-f918-4c93-96bf-087218a48ced"
    attachable = CaseStudy.new(auth_bypass_id: auth_bypass_id)
    attachment = build(:attachment_data, attachable: attachable)

    assert_equal [auth_bypass_id], attachment.auth_bypass_ids
  end

  test "should return filename even after reloading" do
    attachment = create(:attachment_data)
    assert_not_nil attachment.filename
    assert_equal attachment.filename, AttachmentData.find(attachment.id).filename
  end

  test "should save content type and file size on create" do
    greenpaper_pdf = upload_fixture("greenpaper.pdf", "application/pdf")
    attachment = create(:attachment_data, file: greenpaper_pdf)
    attachment.reload
    assert_equal "greenpaper.pdf", attachment.filename
    assert_equal "application/pdf", attachment.content_type
    assert_equal greenpaper_pdf.size, attachment.file_size
  end

  test "should save content type and file size on update" do
    greenpaper_pdf = upload_fixture("greenpaper.pdf", "application/pdf")
    whitepaper_pdf = upload_fixture("whitepaper.pdf", "application/pdf")
    attachment = create(:attachment_data, file: greenpaper_pdf)
    attachment.update!(file: whitepaper_pdf)
    attachment.reload
    assert_equal "whitepaper.pdf", attachment.filename
    assert_equal "application/pdf", attachment.content_type
    assert_equal whitepaper_pdf.size, attachment.file_size
  end

  test "should set content type based on file extension when browser supplies octet-stream content type" do
    greenpaper_pdf = upload_fixture("greenpaper.pdf", "application/octet-stream")
    attachment = create(:attachment_data, file: greenpaper_pdf)
    attachment.reload
    assert_equal "application/pdf", attachment.content_type
  end

  test "should set content type based on file extension when browser supplies no content type" do
    greenpaper_pdf = upload_fixture("greenpaper.pdf", nil)
    attachment = create(:attachment_data, file: greenpaper_pdf)
    attachment.reload
    assert_equal "application/pdf", attachment.content_type
  end

  test "should allow file in the indexable whitelist to be indexed" do
    greenpaper_pdf = upload_fixture("greenpaper.pdf", nil)
    attachment = create(:attachment_data, file: greenpaper_pdf)
    attachment.reload
    assert_equal true, attachment.indexable?
  end

  test "should set page count for PDF on create" do
    two_pages_pdf = upload_fixture("two-pages.pdf")
    attachment = create(:attachment_data, file: two_pages_pdf)
    attachment.reload
    assert_equal 2, attachment.number_of_pages
  end

  test "should set page count for PDFs which have a space in their names" do
    pdf_with_spaces_in_the_name = upload_fixture("pdf with spaces in the name.pdf")
    attachment = create(:attachment_data, file: pdf_with_spaces_in_the_name)
    attachment.reload
    assert_equal 1, attachment.number_of_pages
  end

  test "should set page count for PDF on update" do
    two_pages_pdf = upload_fixture("two-pages.pdf")
    three_pages_pdf = upload_fixture("three-pages.pdf")
    attachment = create(:attachment_data, file: two_pages_pdf)
    attachment.update!(file: three_pages_pdf)
    attachment.reload
    assert_equal 3, attachment.number_of_pages
  end

  test "should set number of pages to nil if pdf-reader cannot count the number of pages" do
    greenpage_pdf = upload_fixture("greenpaper.pdf")

    errors = %w[PDF::Reader::MalformedPDFError PDF::Reader::UnsupportedFeatureError OpenSSL::Cipher::CipherError]
    errors.each do |err|
      PDF::Reader.any_instance.stubs(:page_count).raises(err.constantize)
      attachment = create(:attachment_data, file: greenpage_pdf)
      attachment.reload
      assert_nil attachment.number_of_pages
    end
  end

  test "should allow CSV file types as attachments" do
    sample_from_excel_csv = upload_fixture("sample-from-excel.csv")
    attachment = create(:attachment_data, file: sample_from_excel_csv)
    attachment.reload
    assert_equal "text/csv", attachment.content_type
  end

  test "should not set page count for non-PDF" do
    sample_from_excel_csv = upload_fixture("sample-from-excel.csv")
    attachment = create(:attachment_data, file: sample_from_excel_csv)
    attachment.reload
    assert_nil attachment.number_of_pages
  end

  test "should be a PDF if underlying content type is application/pdf" do
    greenpaper_pdf = upload_fixture("greenpaper.pdf", "application/pdf")
    attachment = create(:attachment_data, file: greenpaper_pdf)
    attachment.reload
    assert attachment.pdf?
  end

  test "should not be a PDF if underlying content type is not application/pdf" do
    sample_csv = upload_fixture("sample-from-excel.csv", "text/csv")
    attachment = create(:attachment_data, file: sample_csv)
    attachment.reload
    assert_not attachment.pdf?
  end

  test "should return the url to a PNG for PDF thumbnails" do
    greenpaper_pdf = upload_fixture("greenpaper.pdf", "application/pdf")
    attachment = create(:attachment_data, file: greenpaper_pdf)
    attachment.reload
    assert attachment.url(:thumbnail).ends_with?("thumbnail_greenpaper.pdf.png"), "unexpected url ending: #{attachment.url(:thumbnail)}"
  end

  test "should successfully create PNG thumbnail from the file_cache after a validation failure" do
    greenpaper_pdf = upload_fixture("greenpaper.pdf", "application/pdf")
    attachment = build(:attachment_data, file: greenpaper_pdf)

    Services.asset_manager.stubs(:create_whitehall_asset)
    Services.asset_manager.expects(:create_whitehall_asset).with do |value|
      if value[:file].path.ends_with?(".png")
        type = `file -b --mime-type "#{value[:file].path}"`
        assert_equal "image/png", type.strip
      end
    end

    second_attempt_attachment = build(:attachment_data, file: nil, file_cache: attachment.file_cache)
    assert second_attempt_attachment.save

    AssetManagerCreateWhitehallAssetWorker.drain
  end

  test "should return nil file extension when no uploader present" do
    attachment = build(:attachment_data)
    attachment.stubs(file: nil)
    assert_nil attachment.file_extension
  end

  test "should return nil file extension when uploader url not present" do
    attachment = build(:attachment_data)
    attachment.stubs(file: stub("uploader", url: nil))
    assert_nil attachment.file_extension
  end

  test "should return file extension if URL present but file empty" do
    attachment = build(:attachment_data)
    attachment.stubs(file: stub("uploader", empty?: true, url: "greenpaper.pdf"))
    assert_equal "pdf", attachment.file_extension
  end

  test "should return file extension if file present" do
    greenpaper_pdf = upload_fixture("greenpaper.pdf", "application/pdf")
    attachment = build(:attachment_data, file: greenpaper_pdf)
    assert_equal "pdf", attachment.file_extension
  end

  test "#filename_without_extension returns the filename minus the extension" do
    greenpaper_pdf = upload_fixture("greenpaper.pdf", "application/pdf")
    attachment = build(:attachment_data, file: greenpaper_pdf)
    assert_equal "greenpaper", attachment.filename_without_extension
  end

  test "should ensure instances know when they've been replaced by a new instance" do
    to_be_replaced = create(:attachment_data)
    replace_with = build(:attachment_data)
    replace_with.to_replace_id = to_be_replaced.id
    replace_with.save!
    assert_equal replace_with, to_be_replaced.reload.replaced_by
  end

  test "replace_with! won't let you replace an instance with itself" do
    self_referential = create(:attachment_data)
    assert_raise(ActiveRecord::RecordInvalid) do
      self_referential.replace_with!(self_referential)
    end
  end

  test "order attachments by attachable ID" do
    attachment_data = create(:attachment_data)
    edition1 = create(:edition)
    edition2 = create(:edition)
    attachment1 = build(:file_attachment, attachable: edition2)
    attachment2 = build(:file_attachment, attachable: edition1)
    attachment_data.attachments << attachment1
    attachment_data.attachments << attachment2

    assert_equal [attachment2, attachment1], attachment_data.attachments.to_a
  end

  test "#access_limited? is falsey if there is no last attachable" do
    attachment_data = build(:attachment_data)
    attachment_data.stubs(:attachments).returns([])
    assert_not attachment_data.access_limited?
  end

  test "#access_limited? delegates to the last attachable" do
    attachable = stub("attachable", access_limited?: "access-limited")
    attachment_data = build(:attachment_data)
    attachment_data.stubs(:last_attachable).returns(attachable)
    assert_equal "access-limited", attachment_data.access_limited?
  end

  test "#access_limited_object returns nil if there is no last attachable" do
    attachment_data = build(:attachment_data)
    attachment_data.stubs(:attachments).returns([])
    assert_nil attachment_data.access_limited_object
  end

  test "#access_limited_object delegates to the last attachable" do
    attachable = stub("attachable", access_limited_object: "access-limited-object")
    attachment_data = build(:attachment_data)
    attachment_data.stubs(:last_attachable).returns(attachable)
    assert_equal "access-limited-object", attachment_data.access_limited_object
  end

  test "#last_publicly_visible_attachment returns publicly visible attachable" do
    attachable = build(:edition)
    attachable.stubs(:publicly_visible?).returns(true)
    attachment = build(:file_attachment, attachable: attachable)
    attachment_data = build(:attachment_data)
    attachment_data.stubs(:attachments).returns([attachment])

    assert_equal attachment, attachment_data.last_publicly_visible_attachment
  end

  test "#last_publicly_visible_attachment returns latest publicly visible attachable" do
    earliest_attachable = build(:edition)
    earliest_attachable.stubs(:publicly_visible?).returns(true)
    latest_attachable = build(:edition)
    latest_attachable.stubs(:publicly_visible?).returns(true)
    earliest_attachment = build(:file_attachment, attachable: earliest_attachable)
    latest_attachment = build(:file_attachment, attachable: latest_attachable)
    attachment_data = build(:attachment_data)
    attachment_data.stubs(:attachments).returns([earliest_attachment, latest_attachment])

    assert_equal latest_attachment, attachment_data.last_publicly_visible_attachment
  end

  test "#last_publicly_visible_attachment returns nil if there are no publicly visible attachables" do
    attachable = build(:edition)
    attachable.stubs(:publicly_visible?).returns(false)
    attachment = build(:file_attachment, attachable: attachable)
    attachment_data = build(:attachment_data)
    attachment_data.stubs(:attachments).returns([attachment])

    assert_nil attachment_data.last_publicly_visible_attachment
  end

  test "#last_publicly_visible_attachment returns nil if there are no attachables" do
    attachment = build(:file_attachment, attachable: nil)
    attachment_data = build(:attachment_data)
    attachment_data.stubs(:attachments).returns([attachment])

    assert_nil attachment_data.last_publicly_visible_attachment
  end

  test "#last_attachment returns attachment for latest attachable" do
    earliest_attachable = build(:edition)
    latest_attachable = build(:edition)
    earliest_attachment = build(:file_attachment, attachable: earliest_attachable)
    latest_attachment = build(:file_attachment, attachable: latest_attachable)
    attachment_data = build(:attachment_data)
    attachment_data.stubs(:attachments).returns([earliest_attachment, latest_attachment])

    assert_equal latest_attachment, attachment_data.last_attachment
  end

  test "#last_attachment ignores attachments without attachable" do
    earliest_attachable = build(:edition)
    earliest_attachment = build(:file_attachment, attachable: earliest_attachable)
    latest_attachment = build(:file_attachment, attachable: nil)
    attachment_data = build(:attachment_data)
    attachment_data.stubs(:attachments).returns([earliest_attachment, latest_attachment])

    assert_equal earliest_attachment, attachment_data.last_attachment
  end

  test "#last_attachment returns null attachment if no attachments" do
    attachment_data = build(:attachment_data)
    attachment_data.stubs(:attachments).returns([])

    assert_instance_of Attachment::Null, attachment_data.last_attachment
  end

  test "#deleted? returns true if attachment is deleted" do
    attachable = build(:edition)
    attachable.stubs(:publicly_visible?).returns(false)
    deleted_attachment = build(:file_attachment, attachable: attachable, deleted: true)
    attachment_data = build(:attachment_data)
    attachment_data.stubs(:attachments).returns([deleted_attachment])

    assert attachment_data.deleted?
  end

  test "#deleted? returns false if attachment is not deleted" do
    attachable = build(:edition)
    attachable.stubs(:publicly_visible?).returns(false)
    deleted_attachment = build(:file_attachment, attachable: attachable, deleted: false)
    attachment_data = build(:attachment_data)
    attachment_data.stubs(:attachments).returns([deleted_attachment])

    assert_not attachment_data.deleted?
  end

  test "#deleted? returns true if attachment is deleted even if attachable is nil" do
    deleted_attachment = build(:file_attachment, attachable: nil, deleted: true)
    attachment_data = build(:attachment_data)
    attachment_data.stubs(:attachments).returns([deleted_attachment])

    assert attachment_data.deleted?
  end

  test "#deleted? returns false if attachment is not deleted even if attachable is nil" do
    deleted_attachment = build(:file_attachment, attachable: nil, deleted: false)
    attachment_data = build(:attachment_data)
    attachment_data.stubs(:attachments).returns([deleted_attachment])

    assert_not attachment_data.deleted?
  end
end
