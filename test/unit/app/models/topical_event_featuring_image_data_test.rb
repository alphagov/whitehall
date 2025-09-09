require "test_helper"

class TopicalEventFeaturingImageDataTest < ActiveSupport::TestCase
  test "rejects SVG logo uploads" do
    svg_image = File.open(Rails.root.join("test/fixtures/images/test-svg.svg"))
    image_data = build(:topical_event_featuring_image_data, file: svg_image)

    assert_not image_data.valid?
    assert_includes image_data.errors.map(&:full_message), "File is of not allowed type \"svg\", allowed types: jpg, jpeg, gif, png"
  end

  test "rejects non-image file uploads" do
    non_image_file = File.open(Rails.root.join("test/fixtures/folders.zip"))
    topical_event_featuring_image_data = build(:topical_event_featuring_image_data, file: non_image_file)

    assert_not topical_event_featuring_image_data.valid?
    assert_includes topical_event_featuring_image_data.errors.map(&:full_message), "File is of not allowed type \"zip\", allowed types: jpg, jpeg, gif, png"
  end

  test "accepts valid image uploads" do
    jpg_image = File.open(Rails.root.join("test/fixtures/big-cheese.960x640.jpg"))
    topical_event_featuring_image_data = build(:topical_event_featuring_image_data, file: jpg_image)

    assert topical_event_featuring_image_data
    assert_empty topical_event_featuring_image_data.errors
  end

  test "#asset_uploaded? returns true if original asset present" do
    topical_event_featuring_image_data = build(:topical_event_featuring_image_data)

    assert topical_event_featuring_image_data.asset_uploaded?
  end

  test "#asset_uploaded? returns false if original asset is missing" do
    topical_event_featuring_image_data = build(:topical_event_featuring_image_data)
    topical_event_featuring_image_data.assets = []

    assert_not topical_event_featuring_image_data.asset_uploaded?
  end

  test "should republish topical event when assets are ready" do
    topical_event = create(:topical_event)
    topical_event_featuring = topical_event.feature(image: build(:topical_event_featuring_image_data))

    Whitehall::PublishingApi.expects(:republish_async).with(topical_event).once

    topical_event_featuring.image.republish_on_assets_ready
  end
end
