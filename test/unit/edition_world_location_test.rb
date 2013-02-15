require 'test_helper'

class EditionWorldLocationTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess

  test "should be invalid without an edition" do
    edition_world_location = build(:edition_world_location, edition: nil)
    refute edition_world_location.valid?
    assert edition_world_location.errors[:edition].present?
  end

  test "should be invalid without an world_location" do
    edition_world_location = build(:edition_world_location, world_location: nil)
    refute edition_world_location.valid?
    assert edition_world_location.errors[:world_location].present?
  end

  test "should be invalid if the edition has been marked as featured but no image has been uploaded" do
    edition_world_location = build(:featured_edition_world_location, image: false)
    refute edition_world_location.valid?
    assert edition_world_location.errors[:image].present?
  end

  test "should be invalid if the edition has been marked as featured but no alt text has been specified" do
    edition_world_location = build(:featured_edition_world_location, alt_text: nil)
    refute edition_world_location.valid?
    assert edition_world_location.errors[:alt_text].present?
  end

  test "should build an image using nested attributes" do
    edition_world_location = build(:edition_world_location)
    edition_world_location.image_attributes = {
      file: fixture_file_upload('minister-of-funk.960x640.jpg')
    }
    edition_world_location.save!

    edition_world_location = EditionWorldLocation.find(edition_world_location.id)

    assert_match /minister-of-funk/, edition_world_location.image.file.url
  end

  test "should not build an image if the nested attributes are empty" do
    edition_world_location = build(:edition_world_location)
    edition_world_location.image_attributes = {}
    edition_world_location.save!

    edition_world_location = EditionWorldLocation.find(edition_world_location.id)

    assert_nil edition_world_location.image
  end

  test "should be filterable by translations of associated editions" do
    world_location = create(:world_location)
    translated_edition = create(:draft_policy, translated_into: [:es])
    untranslated_edition = create(:draft_policy)
    association_for_translated_edition = create(:edition_world_location, edition: translated_edition, world_location: world_location)
    association_for_untranslated_edition = create(:edition_world_location, edition: untranslated_edition, world_location: world_location)

    assert_equal [association_for_translated_edition], EditionWorldLocation.with_translations(:es)
  end
end
