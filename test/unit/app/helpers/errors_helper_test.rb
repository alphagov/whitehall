require "test_helper"

class ErrorsHelperTest < ActionView::TestCase
  setup do
    @object_with_no_errors = ErrorTestObject.new("title", Time.zone.today)
    @object_with_errors = ErrorTestObject.new(nil, nil)
    @object_with_unrelated_errors = ErrorTestObject.new("title", nil)
    @object_with_errors.validate
    @object_with_unrelated_errors.validate
    @flash = ActionDispatch::Flash::FlashHash.new
  end

  test "#errors_for_input returns nil when there are no error messages" do
    assert_nil errors_for_input(@object_with_no_errors.errors, :title)
  end

  test "#errors_for_input returns errors for the attribute passed in" do
    assert_equal errors_for_input(@object_with_errors.errors, :title), "Title cannot be blank"
  end

  test "#errors_for_input formats the error message when there are multiple errors on a field" do
    assert_equal errors_for_input(@object_with_errors.errors, :date), "Date cannot be blank<br>Date is invalid"
  end

  test "#errors_for_input does not return an empty string when object has unrelated error" do
    assert_nil errors_for_input(@object_with_unrelated_errors.errors, :title)
  end

  test "#errors_for returns nil when there are no error messages" do
    assert_nil errors_for(@object_with_no_errors.errors, :title)
  end

  test "#errors_for returns errors for the attribute passed in" do
    assert_equal errors_for(@object_with_errors.errors, :title), [{ text: "Title cannot be blank" }]
  end

  test "#errors_for formats the error message when there are multiple errors on a field" do
    assert_equal errors_for(@object_with_errors.errors, :date), [{ text: "Date cannot be blank" }, { text: "Date is invalid" }]
  end

  test "#errors_for does not return an empty string when object has unrelated error" do
    assert_nil errors_for(@object_with_unrelated_errors.errors, :title)
  end

  test "#errors_from_flash returns nil if flash has no errors" do
    assert_nil errors_from_flash(@flash)
  end

  test "#errors_from_flash returns formatted items" do
    @flash[:my_attribute] = "My message"

    expected_output = [
      {
        href: "#my_attribute",
        text: "My message",
      },
    ]
    assert_equal expected_output, errors_from_flash(@flash)
  end

  class ErrorTestObject
    include ActiveModel::Model
    attr_accessor :title, :date

    validates :title, :date, presence: true
    validate :date_is_a_date

    def initialize(title, date)
      @title = title
      @date = date
    end

    def date_is_a_date
      errors.add(:date, :invalid) unless date.is_a?(Date)
    end
  end
end
