require "test_helper"

class Admin::ContactsHelperTest < ActionView::TestCase
  include ContactsHelper
  include Admin::OrganisationHelper

  test "method contact_rows return correct default rows" do
    organisation = build_stubbed(:organisation)
    contact = build_stubbed(:contact, contactable: organisation)
    expected_output = [
      { key: "Contact type", value: contact.contact_type.name },
      { key: "On homepage", value: contact_shown_on_home_page_text(contact.contactable, contact) },
      { key: "Markdown code", value: "[Contact:#{contact.id}]" },
    ]
    assert_equal expected_output, contact_rows(contact)
  end

  test "method contact_rows return correct rows with email present" do
    organisation = build_stubbed(:organisation)
    contact = build_stubbed(:contact, contactable: organisation, email: "test@gmail.com")

    expected_output = [
      { key: "Email", value: contact.email },
      { key: "Contact type", value: contact.contact_type.name },
      { key: "On homepage", value: contact_shown_on_home_page_text(contact.contactable, contact) },
      { key: "Markdown code", value: "[Contact:#{contact.id}]" },
    ]
    assert_equal expected_output, contact_rows(contact)
  end
  test "method contact_rows return correct rows with address present" do
    organisation = build_stubbed(:organisation)
    contact = build_stubbed(:contact, contactable: organisation, street_address: "01 ,test address")

    expected_output = [
      { key: "Contact type", value: contact.contact_type.name },
      { key: "Address", value: render_hcard_address(contact) },
      { key: "On homepage", value: contact_shown_on_home_page_text(contact.contactable, contact) },
      { key: "Markdown code", value: "[Contact:#{contact.id}]" },
    ]
    assert_equal expected_output, contact_rows(contact)
  end

  test "method contact_rows return correct rows with contact_numbers present" do
    organisation = build_stubbed(:organisation)
    contact = build_stubbed(:contact, contactable: organisation)
    contact_number = contact.contact_numbers.create!(label: "Main phone", number: "1234")

    expected_output = [
      { key: contact_number.label, value: contact_number.number },
      { key: "Contact type", value: contact.contact_type.name },
      { key: "On homepage", value: contact_shown_on_home_page_text(contact.contactable, contact) },
      { key: "Markdown code", value: "[Contact:#{contact.id}]" },
    ]
    assert_equal expected_output, contact_rows(contact)
  end

  test "method contact_rows return correct rows with contact_url present" do
    organisation = build_stubbed(:organisation)
    contact = build_stubbed(:contact, contactable: organisation, contact_form_url: "http://test_contact_form_url")

    expected_output = [
      { key: "Contact form", value: contact.contact_form_url.truncate(25), actions: [{ label: "View", href: contact.contact_form_url }] },
      { key: "Contact type", value: contact.contact_type.name },
      { key: "On homepage", value: contact_shown_on_home_page_text(contact.contactable, contact) },
      { key: "Markdown code", value: "[Contact:#{contact.id}]" },
    ]
    assert_equal expected_output, contact_rows(contact)
  end

  test "method contact_rows return correct rows with comments present" do
    organisation = build_stubbed(:organisation)
    contact = build_stubbed(:contact, contactable: organisation, comments: "test comments for contacts page")

    expected_output = [
      { key: "Contact type", value: contact.contact_type.name },
      { key: "On homepage", value: contact_shown_on_home_page_text(contact.contactable, contact) },
      { key: "Markdown code", value: "[Contact:#{contact.id}]" },
      { key: "Comments", value: contact.comments },
    ]
    assert_equal expected_output, contact_rows(contact)
  end

  test "method contact_tabs generate correct tab for general contacts" do
    organisation = build_stubbed(:organisation)
    general_contact = build_stubbed(:contact, contactable: organisation, contact_type: ContactType::General)
    contacts = [general_contact]
    expected_id = "general_and_media_contacts"

    assert_equal 1, contact_tabs(contacts, organisation).count
    assert_equal expected_id, contact_tabs(contacts, organisation).first[:id]
  end

  test "method contact_tabs generate correct tab for foi contacts" do
    organisation = build_stubbed(:organisation)
    foi_contact = build_stubbed(:contact, contactable: organisation, contact_type: ContactType::FOI)
    contacts = [foi_contact]
    expected_id = "freedom_of_information_contacts"
    assert_equal 1, contact_tabs(contacts, organisation).count
    assert_equal expected_id, contact_tabs(contacts, organisation).first[:id]
  end

  test "method contact_tabs generate correct tabs for general and foi contacts" do
    organisation = build_stubbed(:organisation)
    general_contact = build_stubbed(:contact, contactable: organisation, contact_type: ContactType::General)
    foi_contact = build_stubbed(:contact, contactable: organisation, contact_type: ContactType::FOI)
    contacts = [general_contact, foi_contact]
    expected_id1 = "general_and_media_contacts"
    expected_id2 = "freedom_of_information_contacts"

    assert_equal 2, contact_tabs(contacts, organisation).count
    assert_equal expected_id1, contact_tabs(contacts, organisation).first[:id]
    assert_equal expected_id2, contact_tabs(contacts, organisation).second[:id]
  end

  test "method contact_tabs generate no tabs for no contacts" do
    organisation = build_stubbed(:organisation)
    contacts = []

    assert_equal 0, contact_tabs(contacts, organisation).count
  end
end
