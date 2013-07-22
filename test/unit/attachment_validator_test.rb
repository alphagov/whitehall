require 'test_helper'

class AttachmentValidatorTest < ActiveSupport::TestCase
  setup do
    @validator = AttachmentValidator.new(attributes: {})
  end

  def assert_error_message(expectation, errors)
    assert errors.any? { |message| message =~ expectation },
        "expected error messages to contain #{expectation}"
  end

  test 'command papers cannot have a number whilst marked as unnumbered' do
    attachment = build(:attachment, command_paper_number: '1234', unnumbered_command_paper: true)
    @validator.validate(attachment)
    assert_error_message /^cannot be set on an unnumbered paper/, attachment.errors[:command_paper_number]
  end

  test 'must provide house of commons paper number if parliamentary session set' do
    attachment = build(:attachment, parliamentary_session: '2013-14')
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

  test 'house of commons papers cannot have a number while unnumbered' do
    attachment = build(:attachment, hoc_paper_number: '1234', unnumbered_hoc_paper: true)
    @validator.validate(attachment)
    assert_error_message /^cannot be set on an unnumbered paper/, attachment.errors[:hoc_paper_number]
  end

  test 'house of commons papers cannot have a parliamentary session while unnumbered' do
    attachment = build(:attachment, parliamentary_session: '2010-11', unnumbered_hoc_paper: true)
    @validator.validate(attachment)
    assert_error_message /^cannot be set on an unnumbered paper/, attachment.errors[:parliamentary_session]
  end

  test 'unnumbered papers cannot be both "command" and "house of commons" at the same time' do
    attachment = build(:attachment, unnumbered_command_paper: true, unnumbered_hoc_paper: true)
    @validator.validate(attachment)
    assert_error_message /^cannot be set on an unnumbered Command Paper/, attachment.errors[:unnumbered_hoc_paper]

    attachment = build(:attachment, unnumbered_command_paper: true, hoc_paper_number: '1234', parliamentary_session: '2010-11')
    @validator.validate(attachment)
    assert_error_message /^cannot be set on a Command Paper/, attachment.errors[:hoc_paper_number]
    assert_error_message /^cannot be set on a Command Paper/, attachment.errors[:parliamentary_session]

    attachment = build(:attachment, unnumbered_hoc_paper: true, command_paper_number: '1234')
    @validator.validate(attachment)
    assert_error_message /^cannot be set on a House of Commons paper/, attachment.errors[:command_paper_number]
  end
end
