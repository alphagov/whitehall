require "test_helper"

class PublishingApi::EmbassiesIndexPresenterTest < ActiveSupport::TestCase
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
    presenter = PublishingApi::EmbassiesIndexPresenter.new
    presented_page = presenter.content

    validator = GovukSchemas::Validator.new(
      presented_page[:schema_name],
      "publisher",
      presented_page,
    )
    assert validator.valid?, validator.error_message
  end
end
