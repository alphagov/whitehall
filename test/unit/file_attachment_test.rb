require "test_helper"

class FileAttachmentTest < ActiveSupport::TestCase

  def attachment
    @attachment ||= build(:file_attachment)
  end

  def assert_delegated attachment, method
     attachment.attachment_data.expects(method).returns(method.to_s)
     assert_equal method.to_s, attachment.send(method)
  end

  test "asks data for file specific information" do
    assert_delegated attachment, :url
    assert_delegated attachment, :content_type
    assert_delegated attachment, :pdf?
    assert_delegated attachment, :extracted_text
    assert_delegated attachment, :file_extension
    assert_delegated attachment, :file_size
    assert_delegated attachment, :number_of_pages
    assert_delegated attachment, :file
    assert_delegated attachment, :filename
  end

  test "html? is false" do
    refute attachment.html?
  end

  test "should be invalid if an attachment already exists on the attachable with the same filename" do
    attachable = create(:policy_advisory_group, attachments: [build(:file_attachment, file: file_fixture('whitepaper.pdf'))])
    duplicate  = build(:file_attachment,  file: file_fixture('whitepaper.pdf'), attachable: attachable)

    refute duplicate.valid?
    assert_match %r(This policy advisory group already has a file called "whitepaper.pdf"), duplicate.errors[:base].first
  end

  test "does not destroy attachment_data when more attachments are associated" do
    attachment_data = attachment.attachment_data
    other_attachment = create(:file_attachment, attachment_data: attachment_data)

    attachment_data.expects(:destroy).never
    attachment.destroy
  end

  test "destroys attachment_data when no attachments are associated" do
    attachment_data = attachment.attachment_data

    attachment_data.expects(:destroy)
    attachment.destroy
  end
end
