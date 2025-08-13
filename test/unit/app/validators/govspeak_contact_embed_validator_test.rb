require "test_helper"

class GovspeakContactEmbedValidatorTest < ActiveSupport::TestCase
  def setup
    @valid_contact = create(:contact)
    @invalid_contact_id = "99999"
    @validator = GovspeakContactEmbedValidator.new
  end

  test "validates nil body without errors" do
    record = create_record_with_body(nil)
    @validator.validate(record)
    assert_empty record.errors[:body]
  end

  test "validates empty body without errors" do
    record = create_record_with_body("")
    @validator.validate(record)
    assert_empty record.errors[:body]
  end

  test "validates body with existing contact without errors" do
    record = create_record_with_body("[Contact:#{@valid_contact.id}]")
    @validator.validate(record)
    assert_empty record.errors[:body]
  end

  test "validates body with multiple existing contacts without errors" do
    contact2 = create(:contact)
    record = create_record_with_body("[Contact:#{@valid_contact.id}] and [Contact:#{contact2.id}]")
    @validator.validate(record)
    assert_empty record.errors[:body]
  end

  test "adds error with structured details for non-existent contact" do
    record = create_record_with_body("[Contact:#{@invalid_contact_id}]")
    @validator.validate(record)

    assert_equal 1, record.errors[:body].size
    error_details = record.errors.details[:body].first
    assert_equal :invalid_contact, error_details[:error]
    assert_equal @invalid_contact_id, error_details[:contact_id]
  end

  test "adds multiple errors for multiple invalid contacts" do
    invalid_id_2 = "88888"
    record = create_record_with_body("[Contact:#{@invalid_contact_id}] and [Contact:#{invalid_id_2}]")
    @validator.validate(record)

    assert_equal 2, record.errors[:body].size
    error_details = record.errors.details[:body]
    contact_ids = error_details.map { |detail| detail[:contact_id] }
    assert_includes contact_ids, @invalid_contact_id
    assert_includes contact_ids, invalid_id_2
  end

private

  def create_record_with_body(body)
    OpenStruct.new(body: body, errors: ActiveModel::Errors.new(self))
  end
end
