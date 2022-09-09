require "test_helper"

class ErrorsHelperTest < ActionView::TestCase
  setup do
    @object_with_no_errors = ErrorTestObject.new("title", Time.zone.today)
    @object_with_errors = ErrorTestObject.new(nil, nil)
    @object_with_errors.validate
  end

  test "#error_for_input returns nil when there are no error messages" do
    assert_nil errors_for_input(@object_with_no_errors.errors, :title)
  end

  test "#error_for_input returns errors for the attribute passed in" do
    assert_equal errors_for_input(@object_with_errors.errors, :title), "Title can't be blank"
  end

  test "#error_for_input formats the error message when there are multiple errors on a field" do
    assert_equal errors_for_input(@object_with_errors.errors, :date), "Date can't be blank\nDate is invalid"
  end

  test "#error_for returns nil when there are no error messages" do
    assert_nil errors_for(@object_with_no_errors.errors, :title)
  end

  test "#error_for returns errors for the attribute passed in" do
    assert_equal errors_for(@object_with_errors.errors, :title), [{ text: "Title can't be blank" }]
  end

  test "#error_for formats the error message when there are multiple errors on a field" do
    assert_equal errors_for(@object_with_errors.errors, :date), [{ text: "Date can't be blank" }, { text: "Date is invalid" }]
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
