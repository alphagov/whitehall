require 'test_helper'

class ConsultationResponseAttachmentTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess

  test 'should accept nested attributes for the attachment' do
    response_attachment = build(:consultation_response_attachment)
    response_attachment.attachment_attributes = {
      title: 'attachment-title',
      file:  fixture_file_upload('greenpaper.pdf')
    }
    response_attachment.save!

    assert_equal 'attachment-title', response_attachment.attachment.title
  end

  test 'should not build an empty attachment if the attributes are blank' do
    response_attachment = build(:consultation_response_attachment)
    response_attachment.attachment_attributes = {}
    response_attachment.save!

    assert_nil response_attachment.attachment
  end
end