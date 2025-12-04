require "test_helper"

class DurationValidatorTest < ActiveSupport::TestCase
  setup do
    @validator = DurationValidator.new({
      start: "start_date",
      end: "end_date",
      within: "P1Y",
    })
  end

  class DurationValidatorTestClass
    include ActiveModel::API
    attr_accessor :start_date, :end_date
  end

  test "duration is valid when start and end dates are nil" do
    model = DurationValidatorTestClass.new
    @validator.validate(model)

    assert model.errors.empty?
  end

  test "duration is invalid when end date is before start date" do
    model = DurationValidatorTestClass.new
    model.start_date = Date.parse("2024-01-02")
    model.end_date = Date.parse("2024-01-01")
    @validator.validate(model)

    assert_equal ["End date must be between 2024-01-02 and 2025-01-02"], model.errors.full_messages
  end

  test "duration is invalid when start date is empty and end date is populated" do
    model = DurationValidatorTestClass.new
    model.end_date = Date.parse("2024-01-01")
    @validator.validate(model)

    assert_equal ["Start date must be provided if End date is present"], model.errors.full_messages
  end

  test "duration is valid when end date is after start date" do
    model = DurationValidatorTestClass.new
    model.start_date = Date.parse("2024-01-01")
    model.end_date = Date.parse("2024-01-02")
    @validator.validate(model)

    assert model.errors.empty?
  end

  test "duration does not exceed limit" do
    model = DurationValidatorTestClass.new
    model.start_date = Date.parse("2024-01-01")
    model.end_date = Date.parse("2025-01-02")
    @validator.validate(model)

    assert_equal model.errors.full_messages, ["End date must be between 2024-01-01 and 2025-01-01"]
  end

  test "duration is valid if only start date is provided, as to allow for open ended events" do
    model = DurationValidatorTestClass.new
    model.start_date = Date.parse("2025-01-01")
    @validator.validate(model)

    assert_empty model.errors.full_messages
  end
end
