require 'test_helper'

class AttachmentDataTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess

  setup do
    AttachmentUploader.enable_processing = true
    @notifier = stub_everything('notifier')
    Whitehall.stubs(:attachment_data_notifier).returns(@notifier)
  end

  teardown do
    AttachmentUploader.enable_processing = false
  end

  test 'should be invalid without a file' do
    attachment = build(:attachment_data, file: nil)
    refute attachment.valid?
  end

  test 'is invalid with an empty file' do
    empty_file = fixture_file_upload('empty_file.txt', 'text/plain')
    attachment = build(:attachment_data, file: empty_file)
    refute attachment.valid?
    assert_match %r[empty file], attachment.errors[:file].first
  end

  test 'is still valid whilst file is being virus-scanned' do
    attachment_data = create(:attachment_data)
    assert_equal :pending, attachment_data.reload.virus_status
    assert AttachmentData.find(attachment_data.id).valid?
  end

  test 'should return filename even after reloading' do
    attachment = create(:attachment_data)
    refute_nil attachment.filename
    assert_equal attachment.filename, AttachmentData.find(attachment.id).filename
  end

  test "should save content type and file size on create" do
    greenpaper_pdf = fixture_file_upload('greenpaper.pdf', 'application/pdf')
    attachment = create(:attachment_data, file: greenpaper_pdf)
    attachment.reload
    assert_equal "greenpaper.pdf", attachment.filename
    assert_equal "application/pdf", attachment.content_type
    assert_equal greenpaper_pdf.size, attachment.file_size
  end

  test "should save content type and file size on update" do
    greenpaper_pdf = fixture_file_upload('greenpaper.pdf', 'application/pdf')
    whitepaper_pdf = fixture_file_upload('whitepaper.pdf', 'application/pdf')
    attachment = create(:attachment_data, file: greenpaper_pdf)
    attachment.update_attributes!(file: whitepaper_pdf)
    attachment.reload
    assert_equal "whitepaper.pdf", attachment.filename
    assert_equal "application/pdf", attachment.content_type
    assert_equal whitepaper_pdf.size, attachment.file_size
  end

  test "should set content type based on file extension when browser supplies octet-stream content type" do
    greenpaper_pdf = fixture_file_upload('greenpaper.pdf', 'application/octet-stream')
    attachment = create(:attachment_data, file: greenpaper_pdf)
    attachment.reload
    assert_equal "application/pdf", attachment.content_type
  end

  test "should set content type based on file extension when browser supplies no content type" do
    greenpaper_pdf = fixture_file_upload('greenpaper.pdf', nil)
    attachment = create(:attachment_data, file: greenpaper_pdf)
    attachment.reload
    assert_equal "application/pdf", attachment.content_type
  end

  test "should allow file in the indexable whitelist to be indexed" do
    greenpaper_pdf = fixture_file_upload('greenpaper.pdf', nil)
    attachment = create(:attachment_data, file: greenpaper_pdf)
    attachment.reload
    assert_equal true, attachment.indexable?
  end

  test "should set page count for PDF on create" do
    two_pages_pdf = fixture_file_upload('two-pages.pdf')
    attachment = create(:attachment_data, file: two_pages_pdf)
    attachment.reload
    assert_equal 2, attachment.number_of_pages
  end

  test "should set page count for PDFs which have a space in their names" do
    pdf_with_spaces_in_the_name = fixture_file_upload('pdf with spaces in the name.pdf')
    attachment = create(:attachment_data, file: pdf_with_spaces_in_the_name)
    attachment.reload
    assert_equal 1, attachment.number_of_pages
  end

  test "should set page count for PDF on update" do
    two_pages_pdf = fixture_file_upload('two-pages.pdf')
    three_pages_pdf = fixture_file_upload('three-pages.pdf')
    attachment = create(:attachment_data, file: two_pages_pdf)
    attachment.update_attributes!(file: three_pages_pdf)
    attachment.reload
    assert_equal 3, attachment.number_of_pages
  end

  test "should save attachment even if unable to count the number of pages" do
    greenpaper_pdf = fixture_file_upload('greenpaper.pdf')
    AttachmentData.any_instance.stubs(:`).raises
    assert_nothing_raised { create(:attachment_data, file: greenpaper_pdf) }
  end

  test "should allow CSV file types as attachments" do
    sample_from_excel_csv = fixture_file_upload('sample-from-excel.csv')
    attachment = create(:attachment_data, file: sample_from_excel_csv)
    attachment.reload
    assert_equal "text/csv", attachment.content_type
  end

  test "should not set page count for non-PDF" do
    sample_from_excel_csv = fixture_file_upload('sample-from-excel.csv')
    attachment = create(:attachment_data, file: sample_from_excel_csv)
    attachment.reload
    assert_nil attachment.number_of_pages
  end

  test "should be a PDF if underlying content type is application/pdf" do
    greenpaper_pdf = fixture_file_upload('greenpaper.pdf', 'application/pdf')
    attachment = create(:attachment_data, file: greenpaper_pdf)
    attachment.reload
    assert attachment.pdf?
  end

  test "should not be a PDF if underlying content type is not application/pdf" do
    sample_csv = fixture_file_upload('sample-from-excel.csv', 'text/csv')
    attachment = create(:attachment_data, file: sample_csv)
    attachment.reload
    refute attachment.pdf?
  end

  test "should return the url to a PNG for PDF thumbnails" do
    greenpaper_pdf = fixture_file_upload('greenpaper.pdf', 'application/pdf')
    attachment = create(:attachment_data, file: greenpaper_pdf)
    attachment.reload
    assert attachment.url(:thumbnail).ends_with?("thumbnail_greenpaper.pdf.png"), "unexpected url ending: #{attachment.url(:thumbnail)}"
  end

  test "should successfully create PNG thumbnail from the file_cache after a validation failure" do
    greenpaper_pdf = fixture_file_upload('greenpaper.pdf', 'application/pdf')
    attachment = build(:attachment_data, file: greenpaper_pdf)
    second_attempt_attachment = build(:attachment_data, file: nil, file_cache: attachment.file_cache)
    assert second_attempt_attachment.save
    type = `file -b --mime-type "#{second_attempt_attachment.file.thumbnail.path}"`
    assert_equal "image/png", type.strip
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
    greenpaper_pdf = fixture_file_upload('greenpaper.pdf', 'application/pdf')
    attachment = build(:attachment_data, file: greenpaper_pdf)
    assert_equal "pdf", attachment.file_extension
  end

  test '#filename_without_extension returns the filename minus the extension' do
    greenpaper_pdf = fixture_file_upload('greenpaper.pdf', 'application/pdf')
    attachment = build(:attachment_data, file: greenpaper_pdf)
    assert_equal "greenpaper", attachment.filename_without_extension
  end

  test "should return virus status as pending when in incoming folder" do
    test_pdf = fixture_file_upload('simple.pdf', 'application/pdf')
    attachment = create(:attachment_data, file: test_pdf)
    assert_equal :pending, attachment.virus_status
  end

  test "should return virus status as failed when in infected folder" do
    test_pdf = fixture_file_upload('simple.pdf', 'application/pdf')
    attachment = create(:attachment_data, file: test_pdf)
    VirusScanHelpers.simulate_virus_scan_infected(attachment.file)
    assert_equal :infected, attachment.virus_status
  end

  test "should return virus status as clean when in the clean folder" do
    test_pdf = fixture_file_upload('simple.pdf', 'application/pdf')
    attachment = create(:attachment_data, file: test_pdf)
    VirusScanHelpers.simulate_virus_scan(attachment.file)
    assert_equal :clean, attachment.virus_status
  end

  test "should ensure instances know when they've been replaced by a new instance" do
    to_be_replaced = create(:attachment_data)
    replace_with = build(:attachment_data)
    replace_with.to_replace_id = to_be_replaced.id
    replace_with.save
    assert_equal replace_with, to_be_replaced.reload.replaced_by
  end

  test "replace_with! won't let you replace an instance with itself" do
    self_referential = create(:attachment_data)
    assert_raise(ActiveRecord::RecordInvalid) do
      self_referential.replace_with!(self_referential)
    end
  end

  test 'replace_with! will walk the chain and set our replacees to be replaced_by our replacer' do
    to_be_replaced = create(:attachment_data)
    replaced = create(:attachment_data, replaced_by: to_be_replaced)
    replacer = create(:attachment_data)

    to_be_replaced.replace_with!(replacer)
    assert_equal replacer, to_be_replaced.replaced_by
    assert_equal replacer, replaced.reload.replaced_by
  end

  test 'replace_with! published a replace event to the attachment data notifier' do
    attachment_data = create(:attachment_data)
    replacement = create(:attachment_data)

    @notifier.expects(:publish).with('replace', attachment_data)

    attachment_data.replace_with!(replacement)
  end

  test 'order attachments by attachable ID' do
    attachment_data = create(:attachment_data)
    edition_1 = create(:edition)
    edition_2 = create(:edition)
    attachment_1 = build(:file_attachment, attachable: edition_2)
    attachment_2 = build(:file_attachment, attachable: edition_1)
    attachment_data.attachments << attachment_1
    attachment_data.attachments << attachment_2

    assert_equal [attachment_2, attachment_1], attachment_data.attachments.to_a
  end

  test '#access_limited? is falsey if there is no last attachable' do
    attachment_data = build(:attachment_data)
    attachment_data.stubs(:attachments).returns([])
    refute attachment_data.access_limited?
  end

  test '#access_limited? delegates to the last attachable' do
    attachable = stub('attachable', access_limited?: 'access-limited')
    attachment_data = build(:attachment_data)
    attachment_data.stubs(:last_attachable).returns(attachable)
    assert_equal 'access-limited', attachment_data.access_limited?
  end

  test '#access_limited_object returns nil if there is no last attachable' do
    attachment_data = build(:attachment_data)
    attachment_data.stubs(:attachments).returns([])
    assert_nil attachment_data.access_limited_object
  end

  test '#access_limited_object delegates to the last attachable' do
    attachable = stub('attachable', access_limited_object: 'access-limited-object')
    attachment_data = build(:attachment_data)
    attachment_data.stubs(:last_attachable).returns(attachable)
    assert_equal 'access-limited-object', attachment_data.access_limited_object
  end

  test '#last_publicly_visible_attachment returns publicly visible attachable' do
    attachable = build(:edition)
    attachable.stubs(:publicly_visible?).returns(true)
    attachment = build(:file_attachment, attachable: attachable)
    attachment_data = build(:attachment_data)
    attachment_data.stubs(:attachments).returns([attachment])

    assert_equal attachment, attachment_data.last_publicly_visible_attachment
  end

  test '#last_publicly_visible_attachment returns latest publicly visible attachable' do
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

  test '#last_publicly_visible_attachment returns nil if there are no publicly visible attachables' do
    attachable = build(:edition)
    attachable.stubs(:publicly_visible?).returns(false)
    attachment = build(:file_attachment, attachable: attachable)
    attachment_data = build(:attachment_data)
    attachment_data.stubs(:attachments).returns([attachment])

    assert_nil attachment_data.last_publicly_visible_attachment
  end

  test '#last_publicly_visible_attachment returns nil if there are no attachables' do
    attachment = build(:file_attachment, attachable: nil)
    attachment_data = build(:attachment_data)
    attachment_data.stubs(:attachments).returns([attachment])

    assert_nil attachment_data.last_publicly_visible_attachment
  end

  test '#last_attachment returns attachment for latest attachable' do
    earliest_attachable = build(:edition)
    latest_attachable = build(:edition)
    earliest_attachment = build(:file_attachment, attachable: earliest_attachable)
    latest_attachment = build(:file_attachment, attachable: latest_attachable)
    attachment_data = build(:attachment_data)
    attachment_data.stubs(:attachments).returns([earliest_attachment, latest_attachment])

    assert_equal latest_attachment, attachment_data.last_attachment
  end

  test '#last_attachment ignores attachments without attachable' do
    earliest_attachable = build(:edition)
    earliest_attachment = build(:file_attachment, attachable: earliest_attachable)
    latest_attachment = build(:file_attachment, attachable: nil)
    attachment_data = build(:attachment_data)
    attachment_data.stubs(:attachments).returns([earliest_attachment, latest_attachment])

    assert_equal earliest_attachment, attachment_data.last_attachment
  end

  test '#last_attachment returns null attachment if no attachments' do
    attachment_data = build(:attachment_data)
    attachment_data.stubs(:attachments).returns([])

    assert_instance_of Attachment::Null, attachment_data.last_attachment
  end

  test '#deleted? returns true if attachment is deleted' do
    attachable = build(:edition)
    attachable.stubs(:publicly_visible?).returns(false)
    deleted_attachment = build(:file_attachment, attachable: attachable, deleted: true)
    attachment_data = build(:attachment_data)
    attachment_data.stubs(:attachments).returns([deleted_attachment])

    assert attachment_data.deleted?
  end

  test '#deleted? returns false if attachment is not deleted' do
    attachable = build(:edition)
    attachable.stubs(:publicly_visible?).returns(false)
    deleted_attachment = build(:file_attachment, attachable: attachable, deleted: false)
    attachment_data = build(:attachment_data)
    attachment_data.stubs(:attachments).returns([deleted_attachment])

    refute attachment_data.deleted?
  end

  test '#deleted? returns true if attachment is deleted even if attachable is nil' do
    deleted_attachment = build(:file_attachment, attachable: nil, deleted: true)
    attachment_data = build(:attachment_data)
    attachment_data.stubs(:attachments).returns([deleted_attachment])

    assert attachment_data.deleted?
  end

  test '#deleted? returns false if attachment is not deleted even if attachable is nil' do
    deleted_attachment = build(:file_attachment, attachable: nil, deleted: false)
    attachment_data = build(:attachment_data)
    attachment_data.stubs(:attachments).returns([deleted_attachment])

    refute attachment_data.deleted?
  end
end
