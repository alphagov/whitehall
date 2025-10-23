require "test_helper"

class WorldwideOrganisationsTest < ActiveSupport::TestCase
  test "it presents the selected worldwide organisations" do
    worldwide_organisations = create_list(:worldwide_organisation, 2)
    edition = build(:draft_standard_edition)
    edition.edition_worldwide_organisations.build([{ document: worldwide_organisations.first.document }, { document: worldwide_organisations.last.document }])

    worldwide_organisations_association = ConfigurableAssociations::WorldwideOrganisations.new(edition.edition_worldwide_organisations, edition.errors)
    expected_links = {
      worldwide_organisations: worldwide_organisations.map(&:content_id),
    }

    assert_equal expected_links, worldwide_organisations_association.links
  end
end

class WorldWideOrganisationsRenderingTest < ActionView::TestCase
  test "it renders the worldwide organisations form control" do
    worldwide_organisations = [create(:worldwide_organisation, title: "WWO 2"), create(:worldwide_organisation, title: "WWO 1")]
    edition = build(:draft_standard_edition)
    edition.edition_worldwide_organisations.build([{ document: worldwide_organisations.first.document }, { document: worldwide_organisations.last.document }])

    render ConfigurableAssociations::WorldwideOrganisations.new(edition.edition_worldwide_organisations, edition.errors)

    assert_dom "label", text: "Worldwide organisations"
    worldwide_organisations.each do |worldwide_organisation|
      assert_dom "option", text: worldwide_organisation.name
    end
  end
end
