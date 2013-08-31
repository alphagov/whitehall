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

  test "should be current when created" do
    topic = build(:classification)
    assert_equal "current", topic.state
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

  test "#latest should return specified number of associated publised editions except world location news articles in reverse chronological order" do
    topic = create(:topic)
    other_topic = create(:topic)
    expected_order = [
      create(:published_policy, topics: [topic], first_published_at: 1.day.ago),
      create(:published_news_article, topics: [topic], first_published_at: 1.week.ago),
      create(:published_publication, topics: [topic], first_published_at: 2.weeks.ago),
      create(:published_speech, topics: [topic], first_published_at: 3.weeks.ago),
      create(:published_policy, topics: [topic], first_published_at: 4.weeks.ago)
    ]
    create(:draft_speech, topics: [topic], first_published_at: 2.days.ago)
    create(:published_speech, topics: [other_topic], first_published_at: 2.days.ago)
    create(:published_world_location_news_article, topics: [topic], first_published_at: 2.days.ago)

    assert_equal expected_order, topic.latest(10)
    assert_equal expected_order[0..1], topic.latest(2)
  end
end