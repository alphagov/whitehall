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
    attachable = create(:policy_group, attachments: [build(:file_attachment, file: file_fixture('whitepaper.pdf'))])
    duplicate  = build(:file_attachment, file: file_fixture('whitepaper.pdf'), attachable: attachable)

    refute duplicate.valid?
    assert_match %r(This policy group already has a file called "whitepaper.pdf"), duplicate.errors[:base].first
  end

  test "unique filename check does not explode if file is not present" do
    attachable = create(:policy_group, attachments: [build(:file_attachment)])
    attachment = build(:file_attachment, attachable: attachable, file: nil)

    refute attachment.valid?
    assert_match %r(can't be blank), attachment.errors[:"attachment_data.file"].first
  end

  test "does not destroy attachment_data when more attachments are associated" do
    saved_attachment = create(:file_attachment)
    attachment_data = saved_attachment.attachment_data
    other_attachment = create(:file_attachment, attachment_data: attachment_data)

    attachment_data.expects(:destroy).never
    saved_attachment.destroy
  end

  test "destroys attachment_data when no attachments are associated" do
    saved_attachment = create(:file_attachment)
    attachment_data = saved_attachment.attachment_data

    attachment_data.expects(:destroy)
    saved_attachment.destroy
  end

  test "update with empty nested attachment data attributes still works" do
    attachment = create(:file_attachment)

    params = {
      'title' => 'Filename',
      'attachment_data_attributes' => {
        'file_cache' => '', 'to_replace_id' => attachment.attachment_data.id
      }
    }
    attachment.reload

    assert attachment.update_attributes(params), attachment.errors.full_messages.to_sentence
    assert_equal 'Filename', attachment.title
  end
end
