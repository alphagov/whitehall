require "test_helper"

class RelativeDateValidatorTest < ActiveSupport::TestCase
  class StubModel
    include ActiveModel::API
    attr_accessor :some_date
  end

  test "validation is not applied if attribute value is nil" do
    model = StubModel.new(some_date: nil)
    validator = RelativeDateValidator.new(attributes: :some_date, before: -> { Time.zone.local(2022, 1, 1, 1, 3) }, after: -> { Time.zone.local(2022, 1, 1, 1, 1) })
    validator.validate(model)
    assert_empty model.errors
  end

  test "model is valid if datetime is between before and after dates" do
    model = StubModel.new(some_date: Time.zone.local(2022, 1, 1, 1, 2))
    validator = RelativeDateValidator.new(attributes: :some_date, before: -> { Time.zone.local(2022, 1, 1, 1, 3) }, after: -> { Time.zone.local(2022, 1, 1, 1, 1) })
    validator.validate(model)
    assert_empty model.errors
  end

  test "adds an error with the default message if date is later than before date" do
    before = Time.zone.local(2022, 1, 1, 1, 1)
    model = StubModel.new(some_date: Time.zone.local(2022, 1, 1, 1, 2))
    validator = RelativeDateValidator.new(attributes: :some_date, before: -> { before })
    validator.validate(model)
    assert_not_empty model.errors
    assert_equal "must not be later than #{before}", model.errors[:some_date].first
  end

  test "does not add an error if date is equal to before date" do
    model = StubModel.new(some_date: Time.zone.local(2022, 1, 1, 1, 1))
    validator = RelativeDateValidator.new(attributes: :some_date, before: -> { Time.zone.local(2022, 1, 1, 1, 1) })
    validator.validate(model)
    assert_empty model.errors
  end

  test "adds an error with the default message if date is earlier than after date" do
    after = Time.zone.local(2022, 1, 1, 1, 2)
    model = StubModel.new(some_date: Time.zone.local(2022, 1, 1, 1, 1))
    validator = RelativeDateValidator.new(attributes: :some_date, after: -> { after })
    validator.validate(model)
    assert_not_empty model.errors
    assert_equal "must not be earlier than #{after}", model.errors[:some_date].first
  end

  test "does not add an error if date is equal to after date" do
    model = StubModel.new(some_date: Time.zone.local(2022, 1, 1, 1, 1))
    validator = RelativeDateValidator.new(attributes: :some_date, after: -> { Time.zone.local(2022, 1, 1, 1, 1) })
    validator.validate(model)
    assert_empty model.errors
  end

  test "before error message can be overriden" do
    before_message = "should be in the past"
    model = StubModel.new(some_date: Time.zone.local(2022, 1, 1, 1, 2))
    validator = RelativeDateValidator.new(attributes: :some_date, before: -> { Time.zone.local(2022, 1, 1, 1, 1) }, before_message:)
    validator.validate(model)
    assert_equal before_message, model.errors[:some_date].first
  end

  test "after error message can be overriden" do
    after_message = "should be in the future"
    model = StubModel.new(some_date: Time.zone.local(2022, 1, 1, 1, 1))
    validator = RelativeDateValidator.new(attributes: :some_date, after: -> { Time.zone.local(2022, 1, 1, 1, 2) }, after_message:)
    validator.validate(model)
    assert_equal after_message, model.errors[:some_date].first
  end
end
