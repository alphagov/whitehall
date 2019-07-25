require "test_helper"

class Edition::ValidationTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess

  test "should be invalid without a title" do
    edition = build(:edition, title: nil)
    assert_not edition.valid?
  end

  test "should be invalid without a body" do
    edition = build(:edition, body: nil)
    assert_not edition.valid?
  end

  test "should be invalid without an creator" do
    edition = build(:edition, creator: nil)
    assert_not edition.valid?
  end

  test "should be invalid without a document" do
    edition = build(:edition)
    edition.stubs(:document).returns(nil)
    assert_not edition.valid?
  end

  test "should be invalid when published without major_change_published_at" do
    edition = build(:published_edition, major_change_published_at: nil)
    assert_not edition.valid?
  end

  test "should be invalid if document has existing draft editions" do
    draft_edition = create(:draft_edition)
    edition = build(:edition, document: draft_edition.document.reload)
    assert_not edition.valid?
  end

  test "should be invalid if document has existing submitted editions" do
    submitted_edition = create(:submitted_edition)
    edition = build(:edition, document: submitted_edition.document.reload)
    assert_not edition.valid?
  end

  test "should be invalid if document has existing editions that need work" do
    rejected_edition = create(:rejected_edition)
    edition = build(:edition, document: rejected_edition.document.reload)
    assert_not edition.valid?
  end

  test "should be invalid when it has no organisations" do
    edition = build(:publication, create_default_organisation: false, lead_organisations: [], supporting_organisations: [])
    assert_not edition.valid?
  end

  test "should be invalid when it has only supporting organisations" do
    edition = build(:publication, create_default_organisation: false, lead_organisations: [], supporting_organisations: [build(:organisation)])
    assert_not edition.valid?
  end

  test "should be valid when it has a lead organisation, but no supporting organisation" do
    edition = build(:publication, create_default_organisation: false, lead_organisations: [build(:organisation)], supporting_organisations: [])
    assert edition.valid?
  end

  test 'should be invalid when it duplicates lead organisations on create' do
    organisation_1 = create(:organisation)
    edition = build(:publication, create_default_organisation: false,
                              lead_organisations: [organisation_1, organisation_1])
    assert_not edition.valid?
  end

  test 'should be invalid when it duplicates lead organisations on save' do
    organisation_1 = create(:organisation)
    edition = create(:publication, create_default_organisation: false,
                               lead_organisations: [organisation_1])
    edition.lead_organisations = [organisation_1, organisation_1]
    assert_not edition.valid?
  end

  test 'should be invalid when it duplicates organisations via lead and supporting on create' do
    organisation_1 = create(:organisation)
    edition = build(:publication, create_default_organisation: false,
                              lead_organisations: [organisation_1],
                              supporting_organisations: [organisation_1])
    assert_not edition.valid?
  end

  test 'should be invalid when it duplicates organisations via lead and supporting on save' do
    organisation_1 = create(:organisation)
    edition = create(:publication, create_default_organisation: false,
                               lead_organisations: [organisation_1])
    edition.lead_organisations = [organisation_1]
    edition.supporting_organisations = [organisation_1]
    assert_not edition.valid?
  end

  test 'should be invalid when it duplicates organisations via edition organisations directly on create' do
    organisation_1 = create(:organisation)
    edition = build(:publication, create_default_organisation: false,
                              edition_organisations: [build(:edition_organisation, organisation: organisation_1, lead: true),
                                                      build(:edition_organisation, organisation: organisation_1, lead: false)])
    assert_not edition.valid?
  end

  test 'should be invalid when it duplicates organisations via edition organisations directly on save' do
    organisation_1 = create(:organisation)
    edition = create(:publication, create_default_organisation: false,
                               edition_organisations: [build(:edition_organisation, organisation: organisation_1, lead: true)])
    edition.edition_organisations.build(organisation: organisation_1, lead: false)
    assert_not edition.valid?
  end

  test 'should be invalid when it duplicates support organisations on create' do
    organisation_1 = create(:organisation)
    organisation_2 = create(:organisation)
    edition = build(:publication, create_default_organisation: false,
                              lead_organisations: [organisation_1],
                              supporting_organisations: [organisation_2, organisation_2])
    assert_not edition.valid?
  end

  test 'should be invalid when it duplicates support organisations on save' do
    organisation_1 = create(:organisation)
    organisation_2 = create(:organisation)
    edition = create(:publication, create_default_organisation: false,
                               lead_organisations: [organisation_1],
                               supporting_organisations: [organisation_2])
    edition.supporting_organisations = [organisation_2, organisation_2]
    assert_not edition.valid?
  end

  test 'should be valid when it swaps a lead and support organisation on save' do
    organisation_1 = create(:organisation)
    organisation_2 = create(:organisation)
    edition = create(:publication, create_default_organisation: false,
                               lead_organisations: [organisation_1],
                               supporting_organisations: [organisation_2])
    edition.lead_organisations = [organisation_2]
    edition.supporting_organisations = [organisation_1]
    assert edition.valid?
  end

  test 'should be valid when it removes one lead and replaces it with the other on save' do
    organisation_1 = create(:organisation)
    organisation_2 = create(:organisation)
    edition = create(:publication, create_default_organisation: false,
                               lead_organisations: [organisation_1, organisation_2],
                               supporting_organisations: [])
    edition.lead_organisations = [organisation_2]
    assert edition.valid?
  end

  test 'should be valid when it removes a lead to make it supporting, and swaps the other lead\'s position on save' do
    organisation_1 = create(:organisation)
    organisation_2 = create(:organisation)
    edition = create(:publication, create_default_organisation: false,
                               lead_organisations: [organisation_1, organisation_2],
                               supporting_organisations: [],
                               organisations: [])
    edition.lead_organisations = [organisation_2]
    edition.supporting_organisations = [organisation_1]
    assert edition.valid?
  end
end
