require 'test_helper'

class AttachmentTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess

  test 'should be valid when built from the factory' do
    attachment = build(:attachment)
    assert attachment.valid?
  end

  test 'should be invalid without a file' do
    attachment = build(:attachment, file: nil)
    refute attachment.valid?
  end

  test 'should return filename even after reloading' do
    attachment = create(:attachment)
    refute_nil attachment.filename
    assert_equal attachment.filename, Attachment.find(attachment.id).filename
  end

  test "does not destroy self when destroy_if_unassociated is called if more documents are associated" do
    attachment = create(:attachment)
    create(:document_attachment, attachment: attachment)

    attachment.expects(:destroy).never
    attachment.destroy_if_unassociated
  end

  test "destroys self when destroy_if_unassociated is called if no documents are associated" do
    attachment = create(:attachment)
    attachment.expects(:destroy)
    attachment.destroy_if_unassociated
  end

  test "should save content type and file size on create" do
    greenpaper_pdf = fixture_file_upload('greenpaper.pdf', 'application/pdf')
    attachment = create(:attachment, file: greenpaper_pdf)
    attachment.reload
    assert_equal "greenpaper.pdf", attachment.filename
    assert_equal "application/pdf", attachment.content_type
    assert_equal greenpaper_pdf.size, attachment.file_size
  end

  test "should save content type and file size on update" do
    greenpaper_pdf = fixture_file_upload('greenpaper.pdf', 'application/pdf')
    whitepaper_pdf = fixture_file_upload('whitepaper.pdf', 'application/pdf')
    attachment = create(:attachment, file: greenpaper_pdf)
    attachment.update_attributes!(file: whitepaper_pdf)
    attachment.reload
    assert_equal "whitepaper.pdf", attachment.filename
    assert_equal "application/pdf", attachment.content_type
    assert_equal whitepaper_pdf.size, attachment.file_size
  end

  test "should set content type based on file extension when browser supplies octet-stream content type" do
    greenpaper_pdf = fixture_file_upload('greenpaper.pdf', 'application/octet-stream')
    attachment = create(:attachment, file: greenpaper_pdf)
    attachment.reload
    assert_equal "application/pdf", attachment.content_type
  end

  test "should set content type based on file extension when browser supplies no content type" do
    greenpaper_pdf = fixture_file_upload('greenpaper.pdf', nil)
    attachment = create(:attachment, file: greenpaper_pdf)
    attachment.reload
    assert_equal "application/pdf", attachment.content_type
  end

  test "should set page count on create" do
    two_pages_pdf = fixture_file_upload('two-pages.pdf')
    attachment = create(:attachment, file: two_pages_pdf)
    attachment.reload
    assert_equal 2, attachment.number_of_pages
  end

  test "should set page count on update" do
    two_pages_pdf = fixture_file_upload('two-pages.pdf')
    three_pages_pdf = fixture_file_upload('three-pages.pdf')
    attachment = create(:attachment, file: two_pages_pdf)
    attachment.update_attributes!(file: three_pages_pdf)
    attachment.reload
    assert_equal 3, attachment.number_of_pages
  end

  test "should save attachment even if parsing the PDF raises an exception" do
    greenpaper_pdf = fixture_file_upload('greenpaper.pdf')
    PDF::Reader.stubs(:new).raises
    assert_nothing_raised { create(:attachment, file: greenpaper_pdf) }
  end
end