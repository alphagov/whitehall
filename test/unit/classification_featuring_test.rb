require "test_helper"

class ClassificationFeaturingTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess

  test "should build an image using nested attributes" do
    classification_featuring = build(:classification_featuring)
    classification_featuring.image_attributes = {
      file: upload_fixture("minister-of-funk.960x640.jpg", "image/jpg"),
    }
    classification_featuring.save!

    classification_featuring = ClassificationFeaturing.find(classification_featuring.id)

    assert_match(/minister-of-funk/, classification_featuring.image.file.url)
  end

  test "republishes a linked Topical Event when the feature is changed" do
    topical_event = create(:topical_event, :active)
    feature = create(:classification_featuring, topical_event: topical_event)

    Whitehall::PublishingApi.expects(:republish_async).with(topical_event).once
    feature.update!(alt_text: "some updated text")
  end

  test "republishes a linked Topical Event when the feature is deleted" do
    topical_event = create(:topical_event, :active)
    feature = create(:classification_featuring, topical_event: topical_event)

    Whitehall::PublishingApi.expects(:republish_async).with(topical_event).once
    feature.destroy!
  end
end
