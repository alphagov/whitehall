require "test_helper"

class TopicalEventFeaturingTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess

  test "should build an image using nested attributes" do
    topical_event_featuring = build(:topical_event_featuring)
    topical_event_featuring.image_attributes = {
      file: upload_fixture("minister-of-funk.960x640.jpg", "image/jpg"),
    }
    topical_event_featuring.save!

    topical_event_featuring = TopicalEventFeaturing.find(topical_event_featuring.id)

    assert_match(/minister-of-funk/, topical_event_featuring.image.file.url)
  end

  test "republishes a linked Topical Event when the feature is changed" do
    topical_event = create(:topical_event, :active)
    feature = create(:topical_event_featuring, topical_event: topical_event)

    Whitehall::PublishingApi.expects(:republish_async).with(topical_event).once
    feature.update!(alt_text: "some updated text")
  end

  test "republishes a linked Topical Event when the feature is deleted" do
    topical_event = create(:topical_event, :active)
    feature = create(:topical_event_featuring, topical_event: topical_event)

    Whitehall::PublishingApi.expects(:republish_async).with(topical_event).once
    feature.destroy!
  end
end
