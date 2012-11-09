require 'test_helper'

class EditionOrganisationTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess

  test "should be invalid without an edition" do
    edition_organisation = build(:edition_organisation, edition: nil)
    refute edition_organisation.valid?
    assert edition_organisation.errors[:edition].present?
  end

  test "should be invalid without an organisation" do
    edition_organisation = build(:edition_organisation, organisation: nil)
    refute edition_organisation.valid?
    assert edition_organisation.errors[:organisation].present?
  end

  test "should be invalid if the edition has been marked as featured but no image has been uploaded" do
    edition_organisation = build(:featured_edition_organisation, image: false)
    refute edition_organisation.valid?
    assert edition_organisation.errors[:image].present?
  end

  test "should be invalid if the edition has been marked as featured but no alt text has been specified" do
    edition_organisation = build(:featured_edition_organisation, alt_text: nil)
    refute edition_organisation.valid?
    assert edition_organisation.errors[:alt_text].present?
  end

  test "should build an image using nested attributes" do
    edition_organisation = build(:edition_organisation)
    edition_organisation.image_attributes = {
      file: fixture_file_upload('minister-of-funk.960x640.jpg')
    }
    edition_organisation.save!

    edition_organisation = EditionOrganisation.find(edition_organisation.id)

    assert_match /minister-of-funk/, edition_organisation.image.file.url
  end

  test "should not build an image if the nested attributes are empty" do
    edition_organisation = build(:edition_organisation)
    edition_organisation.image_attributes = {}
    edition_organisation.save!

    edition_organisation = EditionOrganisation.find(edition_organisation.id)

    assert_nil edition_organisation.image
  end

  test "should indicate that image is ready if image is not quarantined" do
    clean_image = stub("clean-image", virus_checked?: true)
    edition_organisation = build(:edition_organisation)
    edition_organisation.stubs(:image).returns(clean_image)
    assert edition_organisation.image_ready?
  end

  test "should indicate that image is not ready if image is still quarantined" do
    quarantined_image = stub("quarantined-image", virus_checked?: false)
    edition_organisation = build(:edition_organisation)
    edition_organisation.stubs(:image).returns(quarantined_image)
    refute edition_organisation.image_ready?
  end
end