require "test_helper"

class FeatureTest < ActiveSupport::TestCase
  test "invalid without document" do
    refute build(:feature, document: nil).valid?
  end

  test "invalid without image on create" do
    refute build(:feature, image: nil).valid?
  end

  test "valid without image on update" do
    # This is to work around the fact that carrierwave will consider the image invalid
    # because the file will have been moved to the 'clean' folder by the virus scanner
    # and therefore not in the location that it expects
    feature = create(:feature)
    feature.image = nil
    assert feature.valid?
  end

  test "started_at set by default on creation" do
    feature = Feature.create(image: image_fixture_file, feature_list: create(:feature_list), document: create(:document))
    assert_equal Time.zone.now, feature.started_at
  end

  test ".current lists selects features where ended_at is nil" do
    current = create(:feature, started_at: 2.days.ago, ended_at: nil)
    ended = create(:feature, started_at: 2.days.ago, ended_at: 1.day.ago)
    assert_equal [current], Feature.current
    assert_same_elements [current, ended], Feature.all
  end

  test '#end! sets the ended_at timestamp and saves the model' do
    feature = create(:feature, ended_at: nil)

    assert feature.end!
    assert_equal Time.zone.now, feature.reload.ended_at
  end
end