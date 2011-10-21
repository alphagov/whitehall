require "test_helper"

class SpeechTest < ActiveSupport::TestCase
  test "should be valid when built from the factory" do
    speech = build(:speech)
    assert speech.valid?
  end

  test "should be invalid without a role_appointment" do
    speech = build(:speech, role_appointment: nil)
    refute speech.valid?
  end

  test "should be invalid without a delivered_on" do
    speech = build(:speech, delivered_on: nil)
    refute speech.valid?
  end

  test "should be invalid without a location" do
    speech = build(:speech, location: nil)
    refute speech.valid?
  end
end