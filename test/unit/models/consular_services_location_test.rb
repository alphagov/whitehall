require 'test_helper'

class ConsularServicesLocationTest < ActiveSupport::TestCase

  setup do
    @narnia = create(:world_location, :with_worldwide_organisations, name: "Narnia")
    @narnia_org = @narnia.worldwide_organisations.first
    contact = create(:contact, street_address: "The woods", country: @narnia)
    @narnia_org.main_office = create(:worldwide_office,
                                    title: "British Embassy Narnia",
                                    contact: contact,
                                    worldwide_organisation: @narnia_org,
                                    worldwide_office_type: WorldwideOfficeType::Embassy)
  end

  test "initialization and method delegation" do
    location = ConsularServicesLocation.new(@narnia)
    assert_equal "Narnia", location.name
    assert_equal [@narnia_org], location.worldwide_organisations
  end

  test "offices" do
    @narnia_org.offices << create(:worldwide_office,
                                 title: "UK Trade Narnia",
                                 worldwide_organisation: @narnia_org,
                                 worldwide_office_type: WorldwideOfficeType::Other)

    location = ConsularServicesLocation.new(@narnia)

    assert_equal [@narnia_org.main_office], location.offices
  end

  test "consular_services?" do
    legoland = create(:world_location, :with_worldwide_organisations, name: "Legoland")

    assert ConsularServicesLocation.new(@narnia).consular_services?
    refute ConsularServicesLocation.new(legoland).consular_services?
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

    location = ConsularServicesLocation.new(toytown)

    assert_equal "Legoland", location.remote_services_country
    assert_equal "British Embassy Legoland", location.remote_services_office
  end

end
