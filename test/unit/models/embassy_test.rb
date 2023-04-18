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
    qatar = create(:world_location, name: "Qatar")

    afghanistan = create(:world_location, :with_worldwide_organisations, name: "Afghanistan")
    british_embassy_kabul = afghanistan.worldwide_organisations.first
    british_embassy_kabul.main_office = nil
    contact = create(
      :contact,
      title: "British Embassy Kabul",
      street_address: "Al Shabab Street",
      country: qatar,
    )
    british_embassy_kabul.offices << create(
      :worldwide_office,
      title: "British Embassy Kabul has temporarily suspended in-country operations.",
      contact:,
      worldwide_organisation: british_embassy_kabul,
      worldwide_office_type: WorldwideOfficeType::Embassy,
    )

    embassy = Embassy.new(afghanistan)

    assert_equal "Qatar", embassy.remote_services_country.name
    assert_equal "British Embassy Kabul", embassy.offices.first.title
  end

  test ".embassy_office? is true for Embassy office types" do
    Embassy::EmbassyOfficeTypes.each do |office_type|
      office = WorldwideOffice.new(worldwide_office_type: office_type)
      assert Embassy.embassy_office?(office)
    end
  end

  test ".embassy_office? is false for non-Embassy office types" do
    (WorldwideOfficeType.all - Embassy::EmbassyOfficeTypes).each do |office_type|
      office = WorldwideOffice.new(worldwide_office_type: office_type)
      refute Embassy.embassy_office?(office)
    end
  end
end
