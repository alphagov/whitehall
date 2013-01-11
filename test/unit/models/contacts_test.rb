class ContactsTest < ActiveSupport::TestCase
  # This test uses organisations as a candidate, but any object with this module
  # can be used here. Ideally a seperate stub ActiveRecord object would be used.
  test 'should be creatable with contact data' do
    params = {
      contacts_attributes: [
        {description: "Office address",
         email: "someone@gov.uk", address: "Aviation House, London",
         postcode: "WC2A 1BE", latitude: -0.112311, longitude: 51.215125},
        {description: "Helpline", contact_numbers_attributes: [
          {label: "Telephone", number: "020712345678"},
          {label: "Fax", number: "020712345679"}
        ]}
      ]
    }
    organisation = create(:organisation, params)

    assert_equal 2, organisation.contacts.count
    assert_equal "someone@gov.uk", organisation.contacts[0].email
    assert_equal "Aviation House, London", organisation.contacts[0].address
    assert_equal "WC2A 1BE", organisation.contacts[0].postcode
    assert_equal -0.112311, organisation.contacts[0].latitude
    assert_equal 51.215125, organisation.contacts[0].longitude
    assert_equal "Helpline", organisation.contacts[1].description
    assert_equal 2, organisation.contacts[1].contact_numbers.count
    assert_equal "Telephone", organisation.contacts[1].contact_numbers[0].label
    assert_equal "020712345678", organisation.contacts[1].contact_numbers[0].number
    assert_equal "Fax", organisation.contacts[1].contact_numbers[1].label
    assert_equal "020712345679", organisation.contacts[1].contact_numbers[1].number
  end

  test "should be creatable when both contacts and contact numbers are blank" do
    organisation = build(:organisation, contacts_attributes: [
      {description: "", contact_numbers_attributes: [{label: "", number: ""}]}
    ])
    assert organisation.valid?
  end

  test 'destroy deletes related contacts' do
    organisation = create(:organisation)
    contact = create(:contact, contactable: organisation)
    organisation.destroy
    assert_nil Contact.find_by_id(contact.id)
  end
end
