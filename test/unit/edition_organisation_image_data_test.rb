require 'test_helper'

class EditionOrganisationImageDataTest < ActiveSupport::TestCase
  test 'should be invalid without a file' do
    image_data = build(:edition_organisation_image_data, file: nil)
    refute image_data.valid?
  end
end