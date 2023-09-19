require "test_helper"

class DateValidationTest < ActiveSupport::TestCase
  class StubBaseRecord
    include ActiveModel::Model
    include ActiveModel::Validations::Callbacks
    attr_accessor :some_date, :another_date
  end

  class StubModel < StubBaseRecord
    include ActiveRecord::AttributeAssignment
    include DateValidation
    validates :some_date, presence: true
    date_attributes :some_date, :another_date
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

  test "should be invalid when day is missing" do
    model = StubModel.new(some_date: { 1 => 2023, 2 => 1, 3 => nil })
    assert_not model.valid?
  end

  test "should be invalid when not all date attribute parts are numeric" do
    model = StubModel.new(some_date: { 1 => 2023, 2 => "January", 3 => 20 })
    assert_not model.valid?
  end

  # Rails casts the year part of the date to 0, before passing to the attribute setter, if the original year parameter is a non-numeric string.
  # This is not true for other parts of the date. It caused the validator to accept invalid dates such as the test case below.
  test "should be invalid when year part is not numeric" do
    model = StubModel.new
    params = ActionController::Parameters.new({ stub_model: {
      "some_date(3i)" => "1",
      "some_date(2i)" => "1",
      "some_date(1i)" => "test",
    } })
    model.assign_attributes(params.require(:stub_model).permit(:some_date))
    assert_not model.valid?
  end

  test "should not validate presence if date was invalid" do
    model = StubModel.new(some_date: { 1 => 2023, 2 => "January", 3 => 20 })
    assert_not model.valid?
    assert model.errors.where(:some_date, :blank).empty?
  end

  test "should not persist validation state between checks" do
    model = StubModel.new(some_date: { 1 => 2023, 2 => 1, 3 => nil })
    assert_not model.valid?
    model.some_date = { 1 => 2023, 2 => 1, 3 => 1 }
    assert model.valid?
  end

  test "it can validate multiple dates simultaneously" do
    model = StubModel.new(some_date: { 1 => 2023, 2 => 1, 3 => nil }, another_date: { 1 => 2023, 2 => 1, 3 => nil })
    assert_not model.valid?
    assert_not model.errors.where(:some_date, :invalid_date).empty?
    assert_not model.errors.where(:another_date, :invalid_date).empty?
  end

  test "it can handle adding the same attribute twice" do
    model = StubModel.new(some_date: { 1 => 2023, 2 => 9, 3 => 40 })
    model.some_date = { 1 => 2023, 2 => 9, 3 => 50 }
    assert_not model.valid?
    assert_equal 1, model.errors.where(:some_date, :invalid_date).count
  end

  test "it can validate date attributes multiple times" do
    model = StubModel.new(some_date: { 1 => 2023, 2 => 9, 3 => 40 })
    assert_not model.valid?
    assert_not model.valid?
  end
end
