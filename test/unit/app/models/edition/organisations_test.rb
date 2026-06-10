require "test_helper"

class Edition::OrganisationsTest < ActiveSupport::TestCase
  test "#destroy removes relationship with organisation" do
    edition = create(:draft_publication, organisations: [create(:organisation)])
    relation = edition.edition_organisations.first
    edition.destroy!
    assert_not EditionOrganisation.exists?(relation.id)
  end

  test "new edition of document will retain lead and supporting organisations and their orderings" do
    organisation1 = create(:organisation)
    organisation2 = create(:organisation)
    organisation3 = create(:organisation)
    publication = create(:published_publication, lead_organisations: [organisation3, organisation1], supporting_organisations: [organisation2])

    new_edition = publication.create_draft(create(:writer))
    new_edition.change_note = "change-note"
    force_publish(new_edition)

    lead_edition_organisations = new_edition.lead_edition_organisations
    assert_equal 2, lead_edition_organisations.size
    assert_equal organisation3, lead_edition_organisations[0].organisation
    assert_equal organisation1, lead_edition_organisations[1].organisation

    supporting_edition_organisations = new_edition.supporting_edition_organisations
    assert_equal 1, supporting_edition_organisations.size
    assert_equal organisation2, supporting_edition_organisations[0].organisation
  end

  test "reducing lead organisations from 2 to 1 (keeping the second) is ok" do
    organisation1 = create(:organisation)
    organisation2 = create(:organisation)
    edition = create(
      :publication,
      create_default_organisation: false,
      lead_organisations: [organisation1, organisation2],
      supporting_organisations: [],
    )
    edition.lead_organisations = [organisation2]
    assert_nothing_raised do
      edition.save!
    end
  end

  test "should remain publishable when linked organisations are invalid" do
    # Build and persist an organisation that will be invalid.
    invalid_org = create(:organisation)
    invalid_org.update_column(:homepage_type, "invalid")
    assert_not invalid_org.valid?, "Homepage type is not included in the list"

    # Create an edition using the invalid organisation as the lead organisation and
    # disable default organisation creation. Persisting the edition mirrors real usage.
    edition = create(
      :publication,
      create_default_organisation: false,
      lead_organisations: [invalid_org],
      supporting_organisations: [],
    )

    # The edition should be valid for publishing before any side-effects.
    assert edition.valid?(:publish), "edition should be valid in publish context before touching organisations"

    # Reading organisation names used to build unsaved translations and make the edition
    # invalid via autosave validations:contentReference[oaicite:0]{index=0}. After overriding those validations,
    # the edition should remain valid even after accessing organisation names.
    edition.organisations.map(&:name)
    assert edition.valid?(:publish), "edition should still be valid in publish context after reading organisation names"
  end

  test "#sorted_organisations returns organisations in alphabetical order" do
    organisation1 = create(:organisation, name: "Ministry of Jazz")
    organisation2 = create(:organisation, name: "Free Jazz Foundation")
    organisation3 = create(:organisation, name: "Jazz Bizniz")
    edition = create(:published_publication, lead_organisations: [organisation3, organisation1], supporting_organisations: [organisation2])

    assert_equal [organisation2, organisation3, organisation1], edition.sorted_organisations
  end

  test "validates lead organisations for presence for non-configurable types" do
    edition = create(:publication)
    edition.lead_organisations = []

    assert_not edition.valid?
    assert edition.errors.include?(:lead_organisation_ids)
  end

  test "does not validate supporting organisations for presence for non-configurable types" do
    edition = create(:publication)
    edition.supporting_organisations = []

    assert edition.valid?
    assert_not edition.errors.include?(:supporting_organisation_ids)
  end

  test "does not validate lead and supporting organisations for presence when configured to not be required on a standard edition" do
    edition = create(:standard_edition, lead_organisations: [], supporting_organisations: [])
    edition.stubs(:organisation_association_enabled?).returns(true)
    edition.stubs(:lead_organisation_association_required?).returns(false)
    edition.stubs(:supporting_organisation_association_required?).returns(false)

    assert edition.valid?
    assert_not edition.errors.include?(:lead_organisation_ids)
    assert_not edition.errors.include?(:supporting_organisation_ids)
  end

  test "validates lead organisations for presence when configured to be required on a standard edition" do
    edition = create(:standard_edition, lead_organisations: [])
    edition.stubs(:organisation_association_enabled?).returns(true)
    edition.stubs(:lead_organisation_association_required?).returns(true)

    assert_not edition.valid?
    assert edition.errors.include?(:lead_organisation_ids)
  end

  test "validates supporting organisations for presence when configured to be required on a standard edition" do
    edition = create(:standard_edition, supporting_organisations: [])
    edition.stubs(:organisation_association_enabled?).returns(true)
    edition.stubs(:supporting_organisation_association_required?).returns(true)

    assert_not edition.valid?
    assert edition.errors.include?(:supporting_organisation_ids)
  end
end
