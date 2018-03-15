require 'test_helper'

class ResponseTest < ActiveSupport::TestCase
  test "responses without a summary are only valid if they have attachments" do
    response = build(:consultation_outcome, summary: nil)
    refute response.valid?

    response.attachments << build(:file_attachment)
    assert response.valid?, response.errors.full_messages.inspect
  end

  test "should return the alternative_format_contact_email of the consultation" do
    consultation = build(:consultation)
    consultation.stubs(alternative_format_contact_email: 'alternative format contact email')
    response = build(:consultation_outcome, consultation: consultation)

    assert_equal consultation.alternative_format_contact_email, response.alternative_format_contact_email
  end

  test 'is publicly visible if its consultation is publicly visible' do
    consultation = build(:consultation)
    consultation.stubs(:publicly_visible?).returns(true)
    response = build(:consultation_outcome, consultation: consultation)

    assert response.publicly_visible?
  end

  test 'is not publicly visible if its consultation is not publicly visible' do
    consultation = build(:consultation)
    consultation.stubs(:publicly_visible?).returns(false)
    response = build(:consultation_outcome, consultation: consultation)

    refute response.publicly_visible?
  end

  test 'is not publicly visible if its consultation is nil' do
    response = build(:consultation_outcome, consultation: nil)

    refute response.publicly_visible?
  end

  test 'is unpublished if its consultation is unpublished' do
    consultation = build(:consultation)
    consultation.stubs(:unpublished?).returns(true)
    response = build(:consultation_outcome, consultation: consultation)

    assert response.unpublished?
  end

  test 'is not unpublished if its consultation is not unpublished' do
    consultation = build(:consultation)
    consultation.stubs(:unpublished?).returns(false)
    response = build(:consultation_outcome, consultation: consultation)

    refute response.unpublished?
  end

  test 'is not unpublished if its consultation is nil' do
    response = build(:consultation_outcome, consultation: nil)

    refute response.unpublished?
  end

  test 'returns unpublished edition from its consultation' do
    consultation = build(:consultation)
    consultation.stubs(:unpublished_edition).returns(consultation)
    response = build(:consultation_outcome, consultation: consultation)

    assert_equal consultation, response.unpublished_edition
  end

  test 'returns no unpublished edition if its consultation is nil' do
    response = build(:consultation_outcome, consultation: nil)

    assert_nil response.unpublished_edition
  end

  test 'is accessible to user if consultation is accessible to user' do
    user = build(:user)
    consultation = build(:consultation)
    consultation.stubs(:accessible_to?).with(user).returns(true)
    response = build(:consultation_outcome, consultation: consultation)

    assert response.accessible_to?(user)
  end

  test 'is not accessible to user if consultation is not accessible to user' do
    user = build(:user)
    consultation = build(:consultation)
    consultation.stubs(:accessible_to?).with(user).returns(false)
    response = build(:consultation_outcome, consultation: consultation)

    refute response.accessible_to?(user)
  end

  test 'is not accessible to user if consultation is nil' do
    user = build(:user)
    response = build(:consultation_outcome, consultation: nil)

    refute response.accessible_to?(user)
  end

  test 'is access limited if its consultation is access limited' do
    consultation = build(:consultation)
    consultation.stubs(:access_limited?).returns(true)
    response = build(:consultation_outcome, consultation: consultation)

    assert response.access_limited?
  end

  test 'is not access limited if its consultation is not access limited' do
    consultation = build(:consultation)
    consultation.stubs(:access_limited?).returns(false)
    response = build(:consultation_outcome, consultation: consultation)

    refute response.access_limited?
  end

  test 'is not access limited if its consultation is nil' do
    response = build(:consultation_outcome, consultation: nil)

    refute response.access_limited?
  end

  test 'returns consultation as its access limited object' do
    consultation = build(:consultation)
    response = build(:consultation_outcome, consultation: consultation)

    assert_equal consultation, response.access_limited_object
  end

  test 'returns no access limited object if its consultation is nil' do
    response = build(:consultation_outcome, consultation: nil)

    assert_nil response.access_limited_object
  end

  test 'returns consultation organisations as its organisations' do
    organisations = create_list(:organisation, 2)
    consultation = create(:consultation, organisations: organisations)
    response = build(:consultation_outcome, consultation: consultation)

    assert_equal organisations, response.organisations
  end

  test 'returns no organisations if consultation is nil' do
    response = build(:consultation_outcome, consultation: nil)

    assert_equal [], response.organisations
  end
end
