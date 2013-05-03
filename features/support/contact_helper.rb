module ContactHelper
  def fill_in_contact_details(contact_details = {})
    contact_details = {
      title: 'Our shiny new office',
      street_address: "address1\naddress2",
      postal_code:  "12345-123",
      email: "foo@bar.com",
      country: "United Kingdom",
      phone_number_label:  "Main phone number",
      phone_number: "+22 (0) 111 111-111",
      feature_on_home_page: 'yes'
    }.merge(contact_details)
    fill_in "Title", with: contact_details[:title]
    fill_in "Street address", with: contact_details[:street_address]
    fill_in "Postal code", with: contact_details[:postal_code]
    fill_in "Email", with: contact_details[:email]
    fill_in "Label", with: contact_details[:phone_number_label]
    fill_in "Number", with: contact_details[:phone_number]
    select contact_details[:country], from: "Country"
    # allow passing in nil to say - don't try to choose the feature on
    # home page? setting; maybe because it's the first office for a world
    # org, or because it's an FOI contact for a normal org.
    choose contact_details[:feature_on_home_page] unless contact_details[:feature_on_home_page].nil?
  end
end

World(ContactHelper)