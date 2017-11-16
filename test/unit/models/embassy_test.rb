require 'test_helper'

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

  test "#offices returns the organisation's embassy" do
    embassy = Embassy.new(@location)
    assert_equal [@organisation.main_office], embassy.offices
  end

  test "#offices returns an empty array if there is no embassy" do
    location = create(:world_location, :with_worldwide_organisations, name: "Legoland")

    embassy = Embassy.new(location)
    assert [], embassy.offices
  end

  test "#offices treats other types of offices as embassies" do
    embassy = Embassy.new(@location)
    t = WorldwideOfficeType

    @organisation.main_office.update!(worldwide_office_type: t::BritishTradeACulturalOffice)
    assert [@organisation.main_office], embassy.offices

    @organisation.main_office.update!(worldwide_office_type: t::Consulate)
    assert [@organisation.main_office], embassy.offices

    @organisation.main_office.update!(worldwide_office_type: t::HighCommission)
    assert [@organisation.main_office], embassy.offices

    @organisation.main_office.update!(worldwide_office_type: t::Other)
    assert [], embassy.offices
  end

  test "remote_services_office and remote_services_country" do
    legoland = create(:world_location, name: "Legoland")

    toytown = create(:world_location, :with_worldwide_organisations, name: "Narnia")
    toytown_org = toytown.worldwide_organisations.first
    toytown_org.main_office = nil
    contact = create(:contact, title: "British Embassy Legoland",
                     street_address: "1 Brick Lane", country: legoland)
    toytown_org.offices << create(:worldwide_office,
                                title: "British Consular Services Legoland",
                                contact: contact,
                                worldwide_organisation: toytown_org,
                                worldwide_office_type: WorldwideOfficeType::Embassy)

    location = Embassy.new(toytown)

    assert_equal "Legoland", location.remote_services_country.name
    assert_equal "British Embassy Legoland", location.offices.first.title
  end

end
