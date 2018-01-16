require "test_helper"

class Edition::WorldwideOrganisationsTest < ActiveSupport::TestCase
  test "can be associated with worldwide organisations" do
    assert CaseStudy.new.can_be_associated_with_worldwide_organisations?
  end

  test "#destroy removes association with organisations" do
    organisation = create(:worldwide_organisation)
    edition = create(:draft_case_study, worldwide_organisations: [organisation])
    edition.destroy
    refute edition.edition_worldwide_organisations.any?
    assert WorldwideOrganisation.exists?(organisation.id)
  end

  test "new editions carry over worldwide organisations" do
    organisation = create(:worldwide_organisation)
    edition = create(:published_case_study, worldwide_organisations: [organisation])
    new_edition = edition.create_draft(create(:writer))
    new_edition.change_note = 'change-note'
    force_publish(new_edition)

    assert_equal [organisation], new_edition.worldwide_organisations
  end
end
