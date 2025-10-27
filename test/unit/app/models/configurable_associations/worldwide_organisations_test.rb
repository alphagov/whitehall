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

  test "it renders the worldwide organisation form control with selected options" do
    edition_worldwide_organisations = [
      create(:worldwide_organisation, title: "WWO 2", translated_into: [:fr]),
      create(:worldwide_organisation, title: "WWO 1", translated_into: [:cy]),
    ]
    not_selected_worldwide_organisation = create(:worldwide_organisation, title: "WWO not selected")
    edition = build(:draft_standard_edition)
    edition.edition_worldwide_organisations.build([{ document: edition_worldwide_organisations.first.document }, { document: edition_worldwide_organisations.last.document }])

    render ConfigurableAssociations::WorldwideOrganisations.new(edition.edition_worldwide_organisations, edition.errors)

    assert_dom "#edition_worldwide_organisations option", text: not_selected_worldwide_organisation.name, count: 1
    assert_dom "#edition_worldwide_organisations option[selected]", text: not_selected_worldwide_organisation.name, count: 0
    edition_worldwide_organisations.each do |worldwide_organisation|
      assert_dom "#edition_worldwide_organisations option[selected]", text: worldwide_organisation.name, count: 1
    end
  end

  test "it renders worldwide organisation options in alphabetical order" do
    create(:worldwide_organisation, title: "WWO 2")
    create(:worldwide_organisation, title: "WWO 1")
    create(:worldwide_organisation, title: "WWO 3")
    edition = build(:draft_standard_edition, edition_worldwide_organisations: [])

    render ConfigurableAssociations::WorldwideOrganisations.new(edition.edition_worldwide_organisations, edition.errors)

    assert_dom "select#edition_worldwide_organisations option:nth-child(2)", text: "WWO 1"
    assert_dom "select#edition_worldwide_organisations option:nth-child(3)", text: "WWO 2"
    assert_dom "select#edition_worldwide_organisations option:nth-child(4)", text: "WWO 3"
  end

  test "it displays errors for worldwide organisations if there are any" do
    edition = build(:draft_standard_edition)
    edition.errors.add(:worldwide_organisations, "Some error goes here")
    worldwide_organisations_association = ConfigurableAssociations::WorldwideOrganisations.new(edition.edition_worldwide_organisations, edition.errors)
    render worldwide_organisations_association
    assert_dom ".govuk-form-group--error"
    assert_dom ".govuk-error-message", text: "Error: Worldwide organisations Some error goes here"
  end
end
