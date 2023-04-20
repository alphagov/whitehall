require "test_helper"

class EmbassyTest < ActiveSupport::TestCase
  test "it delegates to the world location" do
    location = create(:world_location, :with_worldwide_organisations, name: "Narnia")
    embassy = Embassy.new(location)
    assert_equal "Narnia", embassy.name
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

  test '#remote_office returns special case data where world location is a special case' do
    location_name = 'Central African Republic'
    location = build(:world_location, name: location_name)
    embassy = Embassy.new(location)

    assert Embassy::SPECIAL_CASES.has_key?(location_name)

    expected = Embassy::RemoteOffice.new(
      name: "Foreign, Commonwealth and Development Office",
      location: "the UK",
      path: "/government/organisations/foreign-commonwealth-development-office",
    )
    assert_equal expected, embassy.remote_office
  end

  test '#remote_office returns details of remote office where world location is not a special case' do
    location = create(:world_location, name: 'location-1')
    organisation = create(:worldwide_organisation,
                          world_locations: [location],
                          name: 'org-name',
                          slug: 'org-slug')
    other_location = create(:world_location, name: 'location-2')
    contact = create(:contact, street_address: 'street-address', country: other_location)
    office = create(:worldwide_office,
                    contact: contact,
                    worldwide_organisation: organisation,
                    worldwide_office_type: WorldwideOfficeType::EMBASSY_OFFICE_TYPES.first,
                   )
    embassy = Embassy.new(location)

    expected = Embassy::RemoteOffice.new(
      name: "org-name",
      location: other_location,
      path: "/world/organisations/org-slug",
    )
    assert_equal expected, embassy.remote_office
  end

  test '#remote_office returns nil when the world location is not a special case nor does it have all of its offices outside of the world location' do
    location = create(:world_location, name: 'location-1')
    organisation = create(:worldwide_organisation,
                          world_locations: [location],
                          name: 'org-name',
                          slug: 'org-slug')
    contact = create(:contact, street_address: 'street-address', country: location)
    office = create(:worldwide_office,
                    contact: contact,
                    worldwide_organisation: organisation,
                    worldwide_office_type: WorldwideOfficeType::EMBASSY_OFFICE_TYPES.first,
                  )
    embassy = Embassy.new(location)

    assert_nil embassy.remote_office
  end
end
