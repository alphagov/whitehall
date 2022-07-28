require "test_helper"

class Edition::WorldLocationsTest < ActiveSupport::TestCase
  test "#destroy should also remove the relationship" do
    edition = create(:draft_publication, world_locations: [create(:world_location)])
    relation = edition.edition_world_locations.first
    edition.document.update!(latest_edition_id: nil, live_edition_id: nil)
    edition.destroy!
    assert_not EditionWorldLocation.find_by(id: relation.id)
  end
end
