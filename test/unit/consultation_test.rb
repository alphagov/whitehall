require "test_helper"

class ConsultationTest < ActiveSupport::TestCase
  test "should be valid when built from the factory" do
    consultation = build(:consultation)
    assert consultation.valid?
  end

  test "should not be valid without an opening on date" do
    consultation = build(:consultation, opening_on: nil)
    refute consultation.valid?
  end

  test "should not be valid without an closing on date" do
    consultation = build(:consultation, closing_on: nil)
    refute consultation.valid?
  end
end