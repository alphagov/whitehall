require "test_helper"

class GovspeakContactEmbedValidatorTest < ActiveSupport::TestCase
  test "should be valid if the input is nil" do
    test_model = Edition.new(body: nil)

    GovspeakContactEmbedValidator.new.validate(test_model)

    assert_equal 0, test_model.errors.size
    assert_equal [], test_model.errors[:body]
  end

  test "should be valid if the input contains a Contact that exists" do
    contact = create(:contact)
    test_model = Edition.new(body: "[Contact:#{contact.id}]")

    GovspeakContactEmbedValidator.new.validate(test_model)

    assert_equal 0, test_model.errors.size
    assert_equal [], test_model.errors[:body]
  end

  test "should be invalid if the input contains a Contact that doesn't exist" do
    bad_id = "9999999999999"
    test_model = Edition.new(body: "[Contact:#{bad_id}]")

    GovspeakContactEmbedValidator.new.validate(test_model)

    assert_equal 1, test_model.errors.size
    assert_equal [
      "Contact ID #{bad_id} doesn't exist",
    ], test_model.errors.map(&:type)
  end
end
