require 'test_helper'

class EmbassiesControllerTest < ActionController::TestCase
  view_test "embassies index" do
    argentina = create(:world_location, :with_worldwide_organisations, name: "Argentina")
    worldwide_organisation = argentina.worldwide_organisations.first
    contact = create(:contact, street_address: "123 The Street", country: argentina)
    worldwide_organisation.main_office = create(:worldwide_office,
                                                contact: contact,
                                                worldwide_organisation: worldwide_organisation,
                                                worldwide_office_type: WorldwideOfficeType::Embassy)

    aruba = create(:world_location, :with_worldwide_organisations, name: "Aruba")
    aruban_ww_org = aruba.worldwide_organisations.first
    aruban_ww_org.main_office = create(:worldwide_office,
                                      worldwide_organisation: aruban_ww_org,
                                      worldwide_office_type: WorldwideOfficeType::Embassy)

    sealand = create(:world_location, :with_worldwide_organisations, name: "Sealand")
    org_without_embassy = sealand.worldwide_organisations.first
    org_without_embassy.main_office = create(:worldwide_office,
                                            worldwide_organisation: org_without_embassy,
                                            worldwide_office_type: WorldwideOfficeType::Other)

    get :index

    # TODO: Once frontend work is complete make better assertions on the shape of the DOM
    # testing all three scenarios (embassies, remote embassies, no embassies).
    assert_select "span[class='location_name']", "Argentina"
    assert_select "span[class='location_name']", "Aruba"
    assert_select "span[class='location_name']", "Sealand"
  end


end
