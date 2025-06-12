require "test_helper"

class Edition::GovspeakContactEmbedValidatorTest < ActiveSupport::TestCase
  test "should be valid if the input is nil" do
    validator = DataHygiene::GovspeakContactEmbedValidator.new(nil)
    assert_equal [], validator.errors
  end

  test "should be valid if the input contains a Contact that exists" do
    contact = create(:contact)
    validator = DataHygiene::GovspeakContactEmbedValidator.new("[Contact:#{contact.id}]")
    assert_equal [], validator.errors
  end

  test "should be invalid if the input contains a Contact that doesn't exist" do
    bad_id = "9999999999999"
    validator = DataHygiene::GovspeakContactEmbedValidator.new("[Contact:#{bad_id}]")
    expected_error = { contact_id: bad_id.to_i, message: "Contact ID #{bad_id} doesn't exist" }
    assert_equal [expected_error], validator.errors
  end
end
