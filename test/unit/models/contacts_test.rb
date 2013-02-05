class ContactsTest < ActiveSupport::TestCase
  # This test uses organisations as a candidate, but any object with this module
  # can be used here. Ideally a seperate stub ActiveRecord object would be used.

  test 'destroy deletes related contacts' do
    organisation = create(:organisation)
    contact = create(:contact, contactable: organisation)
    organisation.destroy
    assert_nil Contact.find_by_id(contact.id)
  end
end
