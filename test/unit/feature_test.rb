require "test_helper"

class FeatureTest < ActiveSupport::TestCase
  test "invalid without document" do
    refute build(:feature, document: nil).valid?
  end

  test "started_at set by default on creation" do
    feature = Feature.create(image: image_fixture, feature_list: create(:feature_list), document: create(:document))
    assert_equal Time.zone.now, feature.started_at
  end

  test ".current lists selects features where ended_at is nil" do
    current = create(:feature, started_at: 2.days.ago, ended_at: nil)
    ended = create(:feature, started_at: 2.days.ago, ended_at: 1.day.ago)
    assert_equal [current], Feature.current
    assert_same_elements [current, ended], Feature.all
  end

  def image_fixture
    File.open(Rails.root.join("test/fixtures/minister-of-funk.960x640.jpg"))
  end
end