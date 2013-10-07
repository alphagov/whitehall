require "test_helper"

class Edition::WorldwideOrganisationsTest < ActiveSupport::TestCase

  test "can be associated with worldwide organisations" do
    assert WorldwidePriority.new.can_be_associated_with_worldwide_organisations?
  end

  test "#destroy removes association with organisations" do
    organisation = create(:worldwide_organisation)
    edition = create(:draft_worldwide_priority, worldwide_organisations: [organisation])
    edition.destroy
    refute edition.edition_worldwide_organisations.any?
    assert WorldwideOrganisation.exists?(organisation)
  end

  test "new editions carry over worldwide organisations" do
    organisation = create(:worldwide_organisation)
    priority = create(:published_worldwide_priority, worldwide_organisations: [organisation])
    new_edition = priority.create_draft(create(:policy_writer))
    new_edition.change_note = 'change-note'
    new_edition.perform_force_publish

    assert_equal [organisation], new_edition.worldwide_organisations
  end
end
