require "test_helper"

class Edition::ValidationTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess

  test "should be invalid without a title" do
    edition = build(:edition, title: nil)
    refute edition.valid?
  end

  test "should be invalid without a body" do
    edition = build(:edition, body: nil)
    refute edition.valid?
  end

  test "should be invalid without an creator" do
    edition = build(:edition, creator: nil)
    refute edition.valid?
  end

  test "should be invalid without a document" do
    edition = build(:edition)
    edition.stubs(:document).returns(nil)
    refute edition.valid?
  end

  test "should be invalid when published without published_at" do
    edition = build(:published_edition, published_at: nil)
    refute edition.valid?
  end

  test "should be invalid when published without first_published_at" do
    edition = build(:published_edition, first_published_at: nil)
    refute edition.valid?
  end

  test "should be invalid if document has existing draft editions" do
    draft_edition = create(:draft_edition)
    edition = build(:edition, document: draft_edition.document.reload)
    refute edition.valid?
  end

  test "should be invalid if document has existing submitted editions" do
    submitted_edition = create(:submitted_edition)
    edition = build(:edition, document: submitted_edition.document.reload)
    refute edition.valid?
  end

  test "should be invalid if document has existing editions that need work" do
    rejected_edition = create(:rejected_edition)
    edition = build(:edition, document: rejected_edition.document.reload)
    refute edition.valid?
  end

  test "should be invalid when published if document has existing published editions" do
    published_edition = create(:published_edition)
    edition = build(:published_policy, document: published_edition.document.reload)
    refute edition.valid?
  end

  test "should be invalid when it has no organisations" do
    edition = build(:edition, create_default_organisation: false, lead_organisations: [], supporting_organisations: [])
    refute edition.valid?
  end

  test "should be invalid when it has only supporting organisations" do
    edition = build(:edition, create_default_organisation: false, lead_organisations: [], supporting_organisations: [build(:organisation)])
    refute edition.valid?
  end

  test "should be valid when it has a lead organisation, but no supporting organisation" do
    edition = build(:edition, create_default_organisation: false, lead_organisations: [build(:organisation)], supporting_organisations: [])
    assert edition.valid?
  end

  test 'should be invalid when it duplicates lead organisations on create' do
    o1 = create(:organisation)
    edition = build(:edition, create_default_organisation: false,
                              lead_organisations: [o1, o1])
    refute edition.valid?
  end

  test 'should be invalid when it duplicates lead organisations on save' do
    o1 = create(:organisation)
    edition = create(:edition, create_default_organisation: false,
                               lead_organisations: [o1])
    edition.lead_edition_organisations.build(organisation: o1)
    refute edition.valid?
  end

  test 'should be invalid when it duplicates organisations via lead and supporting on create' do
    o1 = create(:organisation)
    edition = build(:edition, create_default_organisation: false,
                              lead_organisations: [o1],
                              supporting_organisations: [o1])
    refute edition.valid?
  end
  test 'should be invalid when it duplicates organisations via lead and supporting on save' do
    o1 = create(:organisation)
    edition = create(:edition, create_default_organisation: false,
                               lead_organisations: [o1])
    edition.supporting_edition_organisations.build(organisation: o1)
    refute edition.valid?
  end

  test 'should be invalid when it duplicates organisations via edition organisations directly on create' do
    o1 = create(:organisation)
    edition = build(:edition, create_default_organisation: false,
                              edition_organisations: [build(:edition_organisation, organisation: o1, lead: true),
                                                      build(:edition_organisation, organisation: o1, lead: false)])
    refute edition.valid?
  end

  test 'should be invalid when it duplicates organisations via edition organisations directly on save' do
    o1 = create(:organisation)
    edition = create(:edition, create_default_organisation: false,
                               edition_organisations: [build(:edition_organisation, organisation: o1, lead: true)])
    edition.edition_organisations.build(organisation: o1, lead: false)
    refute edition.valid?
  end

  test 'should be invalid when it duplicates support organisations on create' do
    o1 = create(:organisation)
    o2 = create(:organisation)
    edition = build(:edition, create_default_organisation: false,
                              lead_organisations: [o1],
                              supporting_organisations: [o2, o2])
    refute edition.valid?
  end

  test 'should be invalid when it duplicates support organisations on save' do
    o1 = create(:organisation)
    o2 = create(:organisation)
    edition = create(:edition, create_default_organisation: false,
                               lead_organisations: [o1],
                               supporting_organisations: [o2])
    edition.supporting_edition_organisations.build(organisation: o2)
    refute edition.valid?
  end
end
