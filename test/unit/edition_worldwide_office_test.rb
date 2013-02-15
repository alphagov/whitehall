require 'test_helper'

class EditionWorldwideOfficeTest < ActiveSupport::TestCase
  test "should be invalid without an edition" do
    edition_worldwide_office = build(:edition_worldwide_office, edition: nil)
    refute edition_worldwide_office.valid?
    assert edition_worldwide_office.errors[:edition].present?
  end

  test "should be invalid without an office" do
    edition_worldwide_office = build(:edition_worldwide_office, worldwide_office: nil)
    refute edition_worldwide_office.valid?
    assert edition_worldwide_office.errors[:worldwide_office].present?
  end
end
