require 'test_helper'

class ResponseTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess

  test 'should accept nested attributes for the consultation response attachments' do
    response = build(:response)
    response.consultation_response_attachments_attributes = {
      '0' => {
        attachment_attributes: {
          title: 'attachment-title',
          attachment_data_attributes: {
            file:  fixture_file_upload('greenpaper.pdf')
          }
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

  test 'should not build an empty consultation response attachment if the only non-blank attribute is the accessible flag' do
    response = build(:response)
    response.consultation_response_attachments_attributes = {
      '0' => {
        attachment_attributes: {
          accessible: '0'
        }
      }
    }
    response.save!

    assert_equal 0, response.consultation_response_attachments.length
  end

  test 'should allow the consultation response attachment join model to be deleted through nested attributes' do
    response = create(:response)
    attachment = create(:attachment)
    response_attachment = create(:consultation_response_attachment, response: response, attachment: attachment)

    response.update_attributes(consultation_response_attachments_attributes: {
      id: response_attachment.id,
      _destroy: '1'
    })

    assert response.reload.consultation_response_attachments.empty?
  end

  test 'should destroy consultation response attachments when the response is destroyed' do
    response = create(:response)
    response_attachment = response.consultation_response_attachments.create!

    response.destroy

    assert_nil ConsultationResponseAttachment.find_by_id(response_attachment.id)
  end

  test "should not be published if there are no attachments" do
    refute build(:response).published?
  end

  test "should be published if there is at least one attachment" do
    response = create(:response)
    response.attachments.create! title: 'attachment-title', attachment_data: create(:attachment_data, file: fixture_file_upload('greenpaper.pdf'))

    response.save
    assert response.reload.published?
  end

  test "should use the date that the earliest response attachment was created as the date the response was published" do
    response = create(:response)
    attachment = create(:attachment)
    latest_response_attachment = response.consultation_response_attachments.create!(attachment: attachment, created_at: 1.day.ago)
    earliest_response_attachment = response.consultation_response_attachments.create!(attachment: attachment, created_at: 1.month.ago)

    response.save
    assert_equal earliest_response_attachment.created_at.to_date, response.reload.published_on
  end

  test "should return nil if the response isn't published" do
    response = create(:response)
    response.stubs(:published?).returns(false)

    assert_equal nil, response.published_on
  end

  test "should return the published_on date if set and the response is published" do
    published_date = Date.parse('2012-03-03')
    response = create(:response, published_on: published_date)
    response.stubs(:published?).returns(true)
    assert_equal published_date, response.published_on
  end

  test "should return the alternative_format_contact_email of the consultation" do
    organisation = create(:organisation_with_alternative_format_contact_email)
    consultation = create(:consultation, alternative_format_provider: organisation)
    response = consultation.create_response!

    assert_equal organisation.alternative_format_contact_email, response.alternative_format_contact_email
  end
end
