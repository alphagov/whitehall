require "test_helper"

class DateValidationTest < ActiveSupport::TestCase
  class StubBaseRecord
    include ActiveModel::Model
    attr_accessor :some_date
  end

  class StubModel < StubBaseRecord
    include DateValidation
    date_attributes :some_date
  end

  test "should be valid when date attribute is a valid date" do
    model = StubModel.new(some_date: { 1 => 2023, 2 => 9, 3 => 10, 4 => 0, 5 => 0 })
    assert model.valid?
  end

  test "should be invalid when date attribute is an invalid date" do
    model = StubModel.new(some_date: { 1 => 2023, 2 => 9, 3 => 40 })
    assert_not model.valid?
  end

  test "should be invalid when date attribute is partially completed" do
    model = StubModel.new(some_date: { 1 => 2023, 2 => nil, 3 => 9 })
    assert_not model.valid?
  end

  test "should be invalid when not all date attribute parts are numeric" do
    model = StubModel.new(some_date: { 1 => 2023, 2 => "January", 3 => 20 })
    assert_not model.valid?
  end
end
