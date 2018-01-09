require 'test_helper'

class ClassificationFeaturingTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess

  test "should build an image using nested attributes" do
    classification_featuring = build(:classification_featuring)
    classification_featuring.image_attributes = {
      file: fixture_file_upload('minister-of-funk.960x640.jpg', 'image/jpg')
    }
    classification_featuring.save!

    classification_featuring = ClassificationFeaturing.find(classification_featuring.id)

    assert_match(/minister-of-funk/, classification_featuring.image.file.url)
  end
end
