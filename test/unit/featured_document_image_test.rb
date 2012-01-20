require 'test_helper'

class FeaturedDocumentImageTest < ActiveSupport::TestCase
  test 'should be valid when built from the factory' do
    image = build(:featured_document_image)
    assert image.valid?
  end

  test 'should be invalid without an image' do
    image = build(:featured_document_image, image: nil)
    refute image.valid?
  end
end
