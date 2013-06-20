require 'test_helper'

class ClassificationTest < ActiveSupport::TestCase
  should_protect_against_xss_and_content_attacks_on :name, :description

  test "should default to the 'current' state" do
    topic = Classification.new
    assert topic.current?
  end

  test 'should be invalid without a name' do
    topic = build(:classification, name: nil)
    refute topic.valid?
  end

  test "should be invalid without a state" do
    topic = build(:classification, state: nil)
    refute topic.valid?
  end

  test "should be invalid with an unsupported state" do
    topic = build(:classification, state: "foobar")
    refute topic.valid?
  end

  test 'should be invalid without a unique name' do
    existing_topic = create(:classification)
    new_topic = build(:classification, name: existing_topic.name)
    refute new_topic.valid?
  end

  test 'should be invalid without a description' do
    topic = build(:classification, description: nil)
    refute topic.valid?
  end
end