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

  test "should be filterable by translations of associated editions" do
    world_location = create(:world_location)
    translated_edition = create(:draft_policy, translated_into: [:es])
    untranslated_edition = create(:draft_policy)
    association_for_translated_edition = create(:edition_world_location, edition: translated_edition, world_location: world_location)
    association_for_untranslated_edition = create(:edition_world_location, edition: untranslated_edition, world_location: world_location)

    assert_equal [association_for_translated_edition], EditionWorldLocation.with_translations(:es)
  end
end
