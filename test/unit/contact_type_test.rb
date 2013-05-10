require "test_helper"

class ContactTypeTest < ActiveSupport::TestCase
  test "should be findable by name" do
    contact_type = ContactType.find_by_id(1)
    assert_equal contact_type, ContactType.find_by_name(contact_type.name)
  end
end
