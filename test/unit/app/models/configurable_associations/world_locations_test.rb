require "test_helper"

class WorldLocationsTest < ActiveSupport::TestCase
  test "it presents the selected world location links" do
    world_locations = create_list(:world_location, 3, active: true)
    edition = build(:draft_standard_edition, { world_locations: [world_locations.first, world_locations.last] })

    world_locations_association = ConfigurableAssociations::WorldLocations.new(edition.world_locations, edition.errors)
    expected_links = {
      world_locations: [world_locations.first.content_id, world_locations.last.content_id],
    }
    assert_equal expected_links, world_locations_association.links
  end
end

class WorldLocationsRenderingTest < ActionView::TestCase
  test "it renders world locations form control" do
    world_locations = create_list(:world_location, 2, active: true)
    edition = build(:draft_standard_edition)
    world_locations_association = ConfigurableAssociations::WorldLocations.new(edition.world_locations, edition.errors)
    render world_locations_association
    assert_dom "label", text: "World locations"
    world_locations.each do |world_location|
      assert_dom "option", text: world_location.name
    end
  end

  test "it renders world locations form control with pre-selected options" do
    world_locations = create_list(:world_location, 2, active: true)
    edition = build(:draft_standard_edition, { world_locations: [world_locations.first] })

    world_locations_association = ConfigurableAssociations::WorldLocations.new(edition.world_locations, edition.errors)
    render world_locations_association
    assert_dom "option[selected]", text: world_locations.first.name
    assert_not_dom "option[selected]", text: world_locations.last.name
  end

  test "it only renders active world locations as options" do
    active_world_locations = create_list(:world_location, 2, active: true)
    inactive_world_locations = create_list(:world_location, 2, active: false)
    edition = build(:draft_standard_edition)
    world_locations_association = ConfigurableAssociations::WorldLocations.new(edition.world_locations, edition.errors)
    render world_locations_association
    assert_dom "label", text: "World locations"
    active_world_locations.each do |world_location|
      assert_dom "option", text: world_location.name
    end
    inactive_world_locations.each do |world_location|
      assert_not_dom "option", text: world_location.name
    end
  end

  test "it renders world locations in alphabetical order" do
    create(:world_location, name: "Zimbabwe", active: true)
    create(:world_location, name: "Albania", active: true)
    create(:world_location, name: "France", active: true)
    edition = build(:draft_standard_edition)
    world_locations_association = ConfigurableAssociations::WorldLocations.new(edition.world_locations, edition.errors)
    render world_locations_association
    assert_dom "option:nth-child(1)", text: "Albania"
    assert_dom "option:nth-child(2)", text: "France"
    assert_dom "option:nth-child(3)", text: "Zimbabwe"
  end

  test "it displays errors if there are any" do
    world_location = create(:world_location, active: true)
    edition = build(:draft_standard_edition, { world_locations: [world_location] })
    edition.errors.add(:world_locations, "Some error goes here")
    world_locations_association = ConfigurableAssociations::WorldLocations.new(edition.world_locations, edition.errors)
    render world_locations_association
    assert_dom ".govuk-form-group--error"
    assert_dom ".govuk-error-message", text: "Error: World locations Some error goes here"
  end
end
