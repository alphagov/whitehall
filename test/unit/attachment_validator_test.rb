require 'test_helper'

class AttachmentValidatorTest < ActiveSupport::TestCase
  setup do
    @validator = AttachmentValidator.new(attributes: {})
  end

  def assert_error_message(expectation, errors)
    assert errors.any? { |message| message =~ expectation }
  end

  test 'must provide house of commons paper number if parliamentary session set' do
    attachment = build(:attachment, parliamentary_session: '2013/14')
    @validator.validate(attachment)
    assert_error_message /^is required when/, attachment.errors[:hoc_paper_number]
  end

  test 'must provide parliamentary session if house of commons number set' do
    attachment = build(:attachment, hoc_paper_number: '1234')
    @validator.validate(attachment)
    assert_error_message /^is required when/, attachment.errors[:parliamentary_session]
  end
end
