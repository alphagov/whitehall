require 'test_helper'

class AttachmentValidatorTest < ActiveSupport::TestCase
  setup do
    @validator = AttachmentValidator.new(attributes: {})
  end

  def assert_error_message(expectation, errors)
    assert errors.any? { |message| message =~ expectation },
        "expected error messages to contain #{expectation}"
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

  test 'house of commons paper numbers starting with non-numeric characters are invalid' do
    attachment = build(:attachment, hoc_paper_number: 'abcd')
    @validator.validate(attachment)
    assert_error_message /^must start with a number/, attachment.errors[:hoc_paper_number]
  end

  test 'house of commons paper numbers starting with an integer are valid' do
    attachment = build(:attachment, hoc_paper_number: '1234-i')
    @validator.validate(attachment)
    assert attachment.errors[:hoc_paper_number].empty?, 'expected no error'
  end
end
