require "test_helper"

class EmbassyTest < ActiveSupport::TestCase
  setup do
    @location = create(:world_location, :with_worldwide_organisations, name: "Narnia")
    @organisation = @location.worldwide_organisations.first

    @organisation.main_office = create(
      :worldwide_office,
      title: "British Embassy Narnia",
      worldwide_organisation: @organisation,
      worldwide_office_type: WorldwideOfficeType::Embassy,
      contact: create(:contact, street_address: "The woods", country: @location),
    )
  end

  test "it delegates to the world location" do
    embassy = Embassy.new(@location)
    assert_equal "Narnia", embassy.name
  end

  test "remote_services_office and remote_services_country" do
    legoland = create(:world_location, name: "Legoland")

    toytown = create(:world_location, :with_worldwide_organisations, name: "Narnia")
    toytown_org = toytown.worldwide_organisations.first
    toytown_org.main_office = nil
    contact = create(
      :contact,
      title: "British Embassy Legoland",
      street_address: "1 Brick Lane",
      country: legoland,
    )
    toytown_org.offices << create(
      :worldwide_office,
      title: "British Consular Services Legoland",
      contact:,
      worldwide_organisation: toytown_org,
      worldwide_office_type: WorldwideOfficeType::Embassy,
    )

    location = Embassy.new(toytown)

    assert_equal "Legoland", location.remote_services_country.name
  end

  test '#can_assist_british_nationals? returns true if the world location is a special case' do
    location_name = 'Central African Republic'
    location = build(:world_location, name: location_name)
    embassy = Embassy.new(location)

    assert Embassy::SPECIAL_CASES.has_key?(location_name)
    assert embassy.can_assist_british_nationals?
  end

  test '#can_assist_british_nationals? returns true if the world location has at least one embassy office' do
    location = create(:world_location)
    organisation = create(:worldwide_organisation, world_locations: [location])
    office = create(:worldwide_office,
                    worldwide_organisation: organisation,
                    worldwide_office_type: WorldwideOfficeType::EMBASSY_OFFICE_TYPES.first
                   )
    embassy = Embassy.new(location)

    assert embassy.can_assist_british_nationals?
  end

  test '#can_assist_british_nationals? returns false if the world location is not a special case and it does not have any embassy offices' do
    location = build(:world_location)
    embassy = Embassy.new(location)

    refute embassy.can_assist_british_nationals?
  end
end
