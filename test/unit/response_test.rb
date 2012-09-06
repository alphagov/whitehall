require 'test_helper'

class ResponseTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess

  test 'should accept nested attributes for the consultation response attachments' do
    response = build(:response)
    response.consultation_response_attachments_attributes = {
      '0' => {
        attachment_attributes: {
          title: 'attachment-title',
          file:  fixture_file_upload('greenpaper.pdf')
        }
      }
    }
    response.save!

    assert_equal 1, response.consultation_response_attachments.length
  end

  test 'should not build an empty consultation response attachment if the attributes are blank' do
    response = build(:response)
    response.consultation_response_attachments_attributes = {
      '0' => {
        attachment_attributes: {
          title: '',
          file: ''
        }
      }
    }
    response.save!

    assert_equal 0, response.consultation_response_attachments.length
  end

  test 'should destroy consultation response attachments when the response is destroyed' do
    response = create(:response)
    response_attachment = response.consultation_response_attachments.create!

    response.destroy

    assert_nil ConsultationResponseAttachment.find_by_id(response_attachment.id)
  end
end