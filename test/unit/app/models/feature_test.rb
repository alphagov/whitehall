require "test_helper"

class FeatureTest < ActiveSupport::TestCase
  test "invalid without document" do
    assert_not build(:feature, document: nil).valid?
  end

  test "invalid without image on create" do
    assert_not build(:feature, image: nil).valid?
  end

  test "started_at set by default on creation" do
    feature = Feature.create!(
      image: build(:featured_image_data),
      feature_list: create(:feature_list),
      document: create(:document),
      alt_text: "foo",
    )

    assert_equal Time.zone.now, feature.started_at
  end

  test ".current lists selects features where ended_at is nil" do
    current = create(:feature, started_at: 2.days.ago, ended_at: nil)
    ended = create(:feature, started_at: 2.days.ago, ended_at: 1.day.ago)
    assert_equal [current], Feature.current
    assert_same_elements [current, ended], Feature.all
  end

  test "#end! sets the ended_at timestamp and saves the model" do
    feature = create(:feature, ended_at: nil)

    assert feature.end!
    assert_equal Time.zone.now, feature.reload.ended_at
  end

  test "#end! sets the ended_at timestamp and saves the model even if it otherwise fails to validate" do
    feature = create(:feature, ended_at: nil)
    feature.started_at = nil

    assert_nothing_raised do
      feature.end!
    end
  end
end
