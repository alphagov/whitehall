require 'test_helper'

class EditionOrganisationImageDataTest < ActiveSupport::TestCase
  test 'should be invalid without a file' do
    image_data = build(:edition_organisation_image_data, file: nil)
    refute image_data.valid?
  end

  test 'should be invalid if image is not 960x640px' do
    image_data = build(:edition_organisation_image_data, file: File.open(Rails.root.join('test/fixtures/horrible-image.64x96.jpg')))
    refute image_data.valid?
  end

  test 'should be valid if legacy image is not 960x640px' do
    image_data = build(:edition_organisation_image_data, file: File.open(Rails.root.join('test/fixtures/horrible-image.64x96.jpg')))
    image_data.save(validate: false)
    assert image_data.reload.valid?
  end
end
