require "test_helper"

class Admin::ContactsHelperTest < ActionView::TestCase
  include ContactsHelper
  include Admin::OrganisationHelper

  test "contact_rows return correct basic rows " do
    organisation = build_stubbed(:organisation)
    contact = build_stubbed(:contact, contactable: organisation)
    expected_output = [
      { key: "Contact type", value: contact.contact_type.name },
      { key: "On homepage", value: contact_shown_on_home_page_text(contact.contactable, contact) },
      { key: "Markdown code", value: "[Contact:#{contact.id}]" }
    ]
    assert_equal expected_output, contact_rows(contact)
  end

  test "contact_rows return correct rows with email present " do
    organisation = build_stubbed(:organisation)
    contact = build_stubbed(:contact, contactable: organisation,email: "test@gmail.com")

    expected_output = [
      { key: "Email", value: contact.email },
      { key: "Contact type", value: contact.contact_type.name },
      { key: "On homepage", value: contact_shown_on_home_page_text(contact.contactable, contact) },
      { key: "Markdown code", value: "[Contact:#{contact.id}]"}
    ]
    assert_equal expected_output, contact_rows(contact)
  end
  test "contact_rows return correct rows with address present " do
    organisation = build_stubbed(:organisation)
    contact = build_stubbed(:contact, contactable: organisation,street_address: "01 ,test address")

    expected_output = [
      { key: "Contact type", value: contact.contact_type.name },
      {key: "Address", value: render_hcard_address(contact)},
      { key: "On homepage", value: contact_shown_on_home_page_text(contact.contactable, contact) },
      { key: "Markdown code", value: "[Contact:#{contact.id}]"},
    ]
    assert_equal expected_output, contact_rows(contact)
  end
end
