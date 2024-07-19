require "test_helper"

class PublishingApi::EmbassiesIndexPresenterTest < ActiveSupport::TestCase
  setup do
    @presenter = PublishingApi::EmbassiesIndexPresenter.new
  end

  test "returns the content_id of the embassies index page" do
    assert_equal PublishingApi::EmbassiesIndexPresenter::EMBASSIES_INDEX_CONTENT_ID, @presenter.content_id
  end

  test "includes common properties in the generated document" do
    presented_page = @presenter.content

    expected = {
      base_path: "/world/embassies",
      document_type: "embassies_index",
      locale: "en",
      publishing_app: Whitehall::PublishingApp::WHITEHALL,
      redirects: [],
      rendering_app: Whitehall::RenderingApp::COLLECTIONS_FRONTEND,
      routes: [{ path: "/world/embassies", type: "exact" }],
      schema_name: "embassies_index",
      title: I18n.t("organisation.embassies.find_an_embassy_title"),
      update_type: "minor",
    }
    assert_hash_includes presented_page, expected
  end

  test "includes /world as the parent in the links" do
    expected = { parent: [PublishingApi::EmbassiesIndexPresenter::WORLD_INDEX_CONTENT_ID] }
    assert_hash_includes @presenter.links, expected
  end

  test "generates a valid document for world locations with no embassies" do
    create(:world_location)

    assert_valid_embassies_index_document
  end

  test "generates a valid document for world locations with local embassies" do
    world_location = build(:world_location)
    organisation = create(:worldwide_organisation, world_locations: [world_location])
    contact = create(:contact_with_country, country: world_location, locality: "locality")
    create(:worldwide_office,
           contact:,
           worldwide_organisation: organisation,
           worldwide_office_type: WorldwideOfficeType::EMBASSY_OFFICE_TYPES.first)

    assert_valid_embassies_index_document
  end

  test "generates a valid document for world locations with remote embassies" do
    world_location = build(:world_location)
    other_location = create(:world_location)
    organisation = create(:worldwide_organisation, world_locations: [world_location])
    contact = create(:contact_with_country, country: other_location)
    create(:worldwide_office,
           contact:,
           worldwide_organisation: organisation,
           worldwide_office_type: WorldwideOfficeType::EMBASSY_OFFICE_TYPES.first)

    assert_valid_embassies_index_document
  end

  def assert_valid_embassies_index_document
    presented_page = @presenter.content

    validator = GovukSchemas::Validator.new(
      presented_page[:schema_name],
      "publisher",
      presented_page,
    )
    assert validator.valid?, validator.error_message
  end
end
