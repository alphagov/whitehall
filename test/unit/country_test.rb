require "test_helper"

class CountryTest < ActiveSupport::TestCase
  test "should be valid when built from the factory" do
    country = build(:country)
    assert country.valid?
  end

  test "should be invalid without a name" do
    country = build(:country, name: nil)
    refute country.valid?
  end
end