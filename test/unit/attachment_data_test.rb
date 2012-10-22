require 'test_helper'

class AttachmentDataTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess

  setup do
    AttachmentUploader.enable_processing = true
  end

  teardown do
    AttachmentUploader.enable_processing = false
  end

  test 'should be invalid without a file' do
    attachment = build(:attachment_data, file: nil)
    refute attachment.valid?
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

  test "should set page count for PDF on create" do
    two_pages_pdf = fixture_file_upload('two-pages.pdf')
    attachment = create(:attachment_data, file: two_pages_pdf)
    attachment.reload
    assert_equal 2, attachment.number_of_pages
  end

  test "should set page count for PDF on update" do
    two_pages_pdf = fixture_file_upload('two-pages.pdf')
    three_pages_pdf = fixture_file_upload('three-pages.pdf')
    attachment = create(:attachment_data, file: two_pages_pdf)
    attachment.update_attributes!(file: three_pages_pdf)
    attachment.reload
    assert_equal 3, attachment.number_of_pages
  end

  test "should save attachment even if parsing the PDF raises an exception" do
    greenpaper_pdf = fixture_file_upload('greenpaper.pdf')
    PDF::Reader.stubs(:new).raises
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
end
