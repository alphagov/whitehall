require "test_helper"

class Edition::WorldwideOrganisationTest < ActiveSupport::TestCase
  class EditionWithWorldwideOrganisations < Edition
    include ::Edition::WorldwideOrganisations
  end

  class EditionRequiringWorldwideOrganisations < Edition
    include ::Edition::WorldwideOrganisations

    def worldwide_organisation_association_required?
      true
    end
  end

  include ActionDispatch::TestProcess

  def valid_edition_attributes
    {
      title: "edition-title",
      body: "edition-body",
      summary: "edition-summary",
      creator: create(:user),
      previously_published: false,
    }
  end

  def worldwide_organisations
    @worldwide_organisations ||= [
      create(:worldwide_organisation),
      create(:worldwide_organisation),
    ]
  end

  setup do
    @edition = EditionWithWorldwideOrganisations.create!(valid_edition_attributes.merge(worldwide_organisations:))
  end

  test "edition can be created with worldwide organisations" do
    assert_equal worldwide_organisations, @edition.worldwide_organisations
  end

  test "edition does not require worldwide organisations" do
    assert EditionWithWorldwideOrganisations.create!(valid_edition_attributes).valid?
  end

  test "copies the data sets over to a create draft" do
    case_study = create(:published_case_study, worldwide_organisations:)

    assert_equal worldwide_organisations, case_study.create_draft(create(:user)).worldwide_organisations
  end

  test "copies the data sets over to a create draft, for standard editions" do
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type"))
    standard_edition = create(:published_standard_edition, worldwide_organisations:)
    draft = standard_edition.create_draft(create(:user))

    assert_equal worldwide_organisations.map(&:id).sort, draft.worldwide_organisations.map(&:id).sort
  end

  test "returns published worldwide organisations" do
    published = create(:published_worldwide_organisation)
    draft = create(:draft_worldwide_organisation)

    edition = EditionWithWorldwideOrganisations.create!(valid_edition_attributes.merge(worldwide_organisations: [published, draft]))

    assert_equal [published], edition.published_worldwide_organisations
  end

  test "validates presence of at least one worldwide organisation if worldwide organisations are required" do
    edition = EditionRequiringWorldwideOrganisations.build(valid_edition_attributes)
    assert_not edition.valid?
    assert edition.errors.include?(:worldwide_organisation_document_ids)
  end
end
