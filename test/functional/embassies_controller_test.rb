require 'test_helper'

class EmbassiesControllerTest < ActionController::TestCase
  view_test "embassies index" do
    afghanistan = create(:world_location, :with_worldwide_organisations, name: "Afghanistan")
    afghan_org = afghanistan.worldwide_organisations.first
    afghan_org.update_attribute(:name, "The British Embassy Kabul")
    afghan_contact = create(:contact, street_address: "...", country: afghanistan)
    afghan_org.main_office = create(:worldwide_office,
                                    contact: afghan_contact,
                                    worldwide_organisation: afghan_org,
                                    worldwide_office_type: WorldwideOfficeType::Embassy)

    afghan_org.offices << create(:worldwide_office, worldwide_organisation: afghan_org, worldwide_office_type: WorldwideOfficeType::Other)

    aruba = create(:world_location, :with_worldwide_organisations, name: "Aruba")
    netherlands = create(:world_location, name: "Netherlands")
    aruban_org = aruba.worldwide_organisations.first
    aruban_contact = create(:contact, street_address: "...", country: netherlands)
    aruban_org.update_attribute(:name, "British Consulate General Amsterdam")
    aruban_org.main_office = create(:worldwide_office,
                                    contact: aruban_contact,
                                    worldwide_organisation: aruban_org,
                                    worldwide_office_type: WorldwideOfficeType::Embassy)

    sealand = create(:world_location, name: "Sealand")

    get :index

    assert_select "ol[class='locations'] h2", "Afghanistan"
    assert_select "ol[class='locations'] h2", "Aruba"
    assert_select "ol[class='locations'] h2", "Sealand"
    assert_select "ol[class='locations'] ul a", /The British Embassy Kabul/
    assert_select "ol[class='locations'] li p", /Aruba doesn't have consular services, you need to go to the British Consulate General Amsterdam/
    assert_select "ol[class='locations'] li p", /Sealand doesn't have consular services, you can get consular assistance from/
  end


end
