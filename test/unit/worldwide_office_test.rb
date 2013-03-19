require 'test_helper'

class WorldwideOfficeTest < ActiveSupport::TestCase
  %w{contact worldwide_organisation worldwide_office_type}.each do |param|
    test "should not be valid without a #{param}" do
      refute build(:worldwide_office, param.to_sym => nil).valid?
    end
  end

  test "delegates address-related methods to it's contact" do
    contact = create( :contact_with_country,
                      latitude: "67890",
                      longitude: "12345",
                      email: "email@email.com",
                      contact_form_url: "http://contact.com/form",
                      title: "Consulate General's Office",
                      comments: "Totally bananas",
                      recipient: "Eric",
                      street_address: "29 Acacier Road",
                      locality: "Dandytown",
                      region: "Dandyville",
                      postal_code: "D12 4CY", contact_numbers: [create(:contact_number)])
    office = create(:worldwide_office, contact: contact)

    # attributes
    assert_equal contact.latitude, office.latitude
    assert_equal contact.longitude, office.longitude
    assert_equal contact.email, office.email
    assert_equal contact.contact_form_url, office.contact_form_url
    assert_equal contact.title, office.title
    assert_equal contact.comments, office.comments
    assert_equal contact.recipient, office.recipient
    assert_equal contact.street_address, office.street_address
    assert_equal contact.locality, office.locality
    assert_equal contact.region, office.region
    assert_equal contact.postal_code, office.postal_code
    # associations
    assert_equal contact.country, office.country
    assert_equal contact.contact_numbers, office.contact_numbers
    # methods
    assert_equal contact.country_code, office.country_code
    assert_equal contact.country_name, office.country_name
    assert_equal contact.has_postal_address?, office.has_postal_address?
  end
end
