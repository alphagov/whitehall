require "test_helper"

class OrganisationsTest < ActiveSupport::TestCase
  test "it presents the selected organisations and primary publishing organisation links" do
    organisations = create_list(:organisation, 3)
    edition = build(:draft_standard_edition)
    edition.edition_organisations.build([{ organisation: organisations.first, lead: true, lead_ordering: 0 }, { organisation: organisations.last, lead: false }])

    organisations_association = ConfigurableAssociations::Organisations.new(edition.edition_organisations, edition.errors)
    expected_links = {
      organisations: [organisations.first.content_id, organisations.last.content_id],
      primary_publishing_organisation: [organisations.first.content_id],
    }
    assert_equal expected_links, organisations_association.links
  end

  test "it presents the first lead organisation as the primary publishing organisation" do
    organisations = create_list(:organisation, 3)
    edition = build(:draft_standard_edition)
    edition.edition_organisations.build([{ organisation: organisations.first, lead: true, lead_ordering: 1 }, { organisation: organisations.last, lead: true, lead_ordering: 0 }])

    organisations_association = ConfigurableAssociations::Organisations.new(edition.edition_organisations, edition.errors)
    assert_equal [organisations.last.content_id], organisations_association.links[:primary_publishing_organisation]
  end
end

class OrganisationsRenderingTest < ActionView::TestCase
  test "it renders the lead organisations form control" do
    edition = build(:draft_standard_edition, :with_organisations)
    organisations_association = ConfigurableAssociations::Organisations.new(edition.edition_organisations, edition.errors)
    organisations = create_list(:organisation, 3) + edition.organisations
    render organisations_association
    assert_dom "legend", text: "Lead organisations"
    0.upto(3) do |index|
      if index.zero?
        assert_dom "label", text: "Lead organisation 1 (required)"
      else
        assert_dom "label", text: "Lead organisation #{index + 1}"
      end
    end
    organisations.each do |organisation|
      assert_dom "option", text: organisation.name
    end
  end

  test "it renders lead organisation options in alphabetical order" do
    create(:organisation, name: "MOD")
    create(:organisation, name: "DWP")
    create(:organisation, name: "HMRC")
    edition = build(:draft_standard_edition, edition_organisations: [])
    organisations_association = ConfigurableAssociations::Organisations.new(edition.edition_organisations, edition.errors)
    render organisations_association
    assert_dom "select#edition_lead_organisation_ids_1 option:nth-child(2)", text: "DWP"
    assert_dom "select#edition_lead_organisation_ids_1 option:nth-child(3)", text: "HMRC"
    assert_dom "select#edition_lead_organisation_ids_1 option:nth-child(4)", text: "MOD"
  end

  test "it renders the supporting organisations form control" do
    edition = build(:draft_standard_edition, :with_organisations)
    organisations_association = ConfigurableAssociations::Organisations.new(edition.edition_organisations, edition.errors)
    render organisations_association
    assert_dom "label", text: "Supporting organisations"
  end

  test "it renders supporting organisation options in alphabetical order" do
    create(:organisation, name: "MOD")
    create(:organisation, name: "DWP")
    create(:organisation, name: "HMRC")
    edition = build(:draft_standard_edition, edition_organisations: [])
    organisations_association = ConfigurableAssociations::Organisations.new(edition.edition_organisations, edition.errors)
    render organisations_association
    assert_dom "select#edition_supporting_organisation_ids option:nth-child(2)", text: "DWP"
    assert_dom "select#edition_supporting_organisation_ids option:nth-child(3)", text: "HMRC"
    assert_dom "select#edition_supporting_organisation_ids option:nth-child(4)", text: "MOD"
  end

  test "it renders the lead organisation form control with pre-selected options" do
    organisations = create_list(:organisation, 3)
    edition = build(:draft_standard_edition)
    edition.edition_organisations.build([{ organisation: organisations.first, lead: true, lead_ordering: 0 }, { organisation: organisations.last, lead: true, lead_ordering: 1 }])

    organisations_association = ConfigurableAssociations::Organisations.new(edition.edition_organisations, edition.errors)
    render organisations_association
    assert_dom "option[selected]", text: organisations.first.name
    assert_not_dom "option[selected]", text: organisations.second.name
    assert_dom "option[selected]", text: organisations.last.name
  end

  test "it renders the supporting organisation form control with pre-selected options" do
    organisations = create_list(:organisation, 3)
    edition = build(:draft_standard_edition)
    edition.edition_organisations.build([{ organisation: organisations.first, lead: false }, { organisation: organisations.last, lead: false }])

    organisations_association = ConfigurableAssociations::Organisations.new(edition.edition_organisations, edition.errors)
    render organisations_association
    assert_dom "select#edition_supporting_organisation_ids option[selected]", text: organisations.first.name
    assert_not_dom "select#edition_supporting_organisation_ids option[selected]", text: organisations.second.name
    assert_dom "select#edition_supporting_organisation_ids option[selected]", text: organisations.last.name
  end

  test "it displays errors for lead organisations if there are any" do
    edition = build(:draft_standard_edition)
    edition.errors.add(:lead_organisations, "Some error goes here")
    organisations_association = ConfigurableAssociations::Organisations.new(edition.edition_organisations, edition.errors)
    render organisations_association
    assert_dom ".govuk-form-group--error"
    assert_dom ".govuk-error-message", text: "Error: Lead organisations Some error goes here"
  end
end
