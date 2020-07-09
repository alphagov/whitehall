require "test_helper"

class ContactsExtractorTest < ActiveSupport::TestCase
  test "can collect all the embedded contacts into a list of Contacts in order" do
    contact1 = build(:contact)
    contact2 = build(:contact)
    Contact.stubs(:find_by).with(id: "1").returns(contact1)
    Contact.stubs(:find_by).with(id: "2").returns(contact2)

    input = "We have an office at [Contact:2] but deliveries go to [Contact:1]"

    embedded_contacts = Govspeak::ContactsExtractor.new(input).contacts
    assert_equal [contact2, contact1], embedded_contacts
  end

  test "will remove duplicate contacts" do
    contact1 = build(:contact)
    Contact.stubs(:find_by).with(id: "1").returns(contact1)

    input = "Our office at [Contact:1] is brilliant, you should come for a cup of tea. Remeber the address is [Contact:1]"

    embedded_contacts = Govspeak::ContactsExtractor.new(input).contacts
    assert_equal [contact1], embedded_contacts
  end

  test "will silently remove contact references that do not resolve to a Contact" do
    Contact.stubs(:find_by).with(id: "1").returns(nil)

    input = "Our office used to be at [Contact:1] but we moved"

    embedded_contacts = Govspeak::ContactsExtractor.new(input).contacts
    assert_equal [], embedded_contacts
  end
end
