require 'test_helper'

class RecentDateValidatorTest < ActiveSupport::TestCase
  setup do
    @validator = RecentDateValidator.new(attributes: [:published_on])
  end

  test "adds an error if date is less than 1900" do
    response = validate(Response.new(published_on: Date.parse('1800-01-01')))
    refute response.errors[:published_on].empty?
  end

  test "allows dates greater than 1900" do
    response = validate(Response.new(published_on: Date.parse('1901-01-01')))
    assert response.errors[:published_on].empty?
  end

private

  def validate(record)
    @validator.validate(record)
    record
  end
end
