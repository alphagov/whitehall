require 'test_helper'

class SpeechTypeTest < ActiveSupport::TestCase
  test "should be valid when built from the factory" do
    speech_type = build(:speech_type)
    assert speech_type.valid?
  end
  
  test "should be invalid without a name" do
    speech_type = build(:speech_type, name: nil)
    refute speech_type.valid?
  end
end