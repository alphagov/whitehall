require "test_helper"

class SpeechTest < ActiveSupport::TestCase
  test "should be valid when built from the factory" do
    speech = build(:speech)
    assert speech.valid?
  end
end