# frozen_string_literal: true

require "test_helper"

class Admin::WorldwideOffices::Index::OfficeSummaryCardComponentTest < ViewComponent::TestCase
  include Rails.application.routes.url_helpers

  setup do
    @worldwide_organisation = build_stubbed(:worldwide_organisation)
  end

  test "renders the correct default values when the office is a main office" do
    contact = build_stubbed(:contact)
    worldwide_office = build_stubbed(:worldwide_office, worldwide_organisation: @worldwide_organisation, contact:)

    @worldwide_organisation.stubs(:main_office).returns(worldwide_office)

    render_inline(
      Admin::WorldwideOffices::Index::OfficeSummaryCardComponent.new(
        worldwide_office:,
        worldwide_organisation: @worldwide_organisation,
        contact:,
      ),
    )

    assert_selector ".govuk-summary-card__title", text: worldwide_office.title
    assert_selector ".govuk-summary-card__actions .govuk-summary-card__action:nth-child(1) a[href='#{edit_admin_worldwide_organisation_worldwide_office_path(@worldwide_organisation, worldwide_office)}']"
    assert_selector ".govuk-summary-card__actions .govuk-summary-card__action:nth-child(2) a[href='#{confirm_destroy_admin_worldwide_organisation_worldwide_office_path(@worldwide_organisation, worldwide_office)}']"
    assert_selector ".govuk-summary-list__row", count: 5
    assert_selector ".govuk-summary-list__row:nth-child(1) .govuk-summary-list__key", text: "Office type"
    assert_selector ".govuk-summary-list__row:nth-child(1) .govuk-summary-list__value", text: worldwide_office.worldwide_office_type.name
    assert_selector ".govuk-summary-list__row:nth-child(2) .govuk-summary-list__key", text: "Contact type"
    assert_selector ".govuk-summary-list__row:nth-child(2) .govuk-summary-list__value", text: contact.contact_type.name
    assert_selector ".govuk-summary-list__row:nth-child(3) .govuk-summary-list__key", text: "On homepage"
    assert_selector ".govuk-summary-list__row:nth-child(3) .govuk-summary-list__value", text: "Yes"
    assert_selector ".govuk-summary-list__row:nth-child(4) .govuk-summary-list__key", text: "Main office"
    assert_selector ".govuk-summary-list__row:nth-child(4) .govuk-summary-list__value", text: "Yes"
    assert_selector ".govuk-summary-list__row:nth-child(5) .govuk-summary-list__key", text: "Markdown code"
    assert_selector ".govuk-summary-list__row:nth-child(5) .govuk-summary-list__value", text: "[Contact:#{contact.id}]"
  end

  test "renders the add translation action when there are missing translations for a contact" do
    contact = build_stubbed(:contact)
    worldwide_office = build_stubbed(:worldwide_office, worldwide_organisation: @worldwide_organisation, contact:)

    contact.stubs(:missing_translations).returns([:fr])

    render_inline(
      Admin::WorldwideOffices::Index::OfficeSummaryCardComponent.new(
        worldwide_office:,
        worldwide_organisation: @worldwide_organisation,
        contact:,
      ),
    )

    assert_selector ".govuk-summary-card__actions .govuk-summary-card__action:nth-child(2) a[href='#']", text: "Add translation"
  end

  test "renders the correct values when the office is not a main office" do
    contact = build_stubbed(:contact)
    worldwide_office = build_stubbed(:worldwide_office, worldwide_organisation: @worldwide_organisation, contact:)

    render_inline(
      Admin::WorldwideOffices::Index::OfficeSummaryCardComponent.new(
        worldwide_office:,
        worldwide_organisation: @worldwide_organisation,
        contact:,
      ),
    )

    assert_selector ".govuk-summary-list__row:nth-child(3) .govuk-summary-list__key", text: "On homepage"
    assert_selector ".govuk-summary-list__row:nth-child(3) .govuk-summary-list__value", text: "No"
    assert_selector ".govuk-summary-list__row:nth-child(4) .govuk-summary-list__key", text: "Main office"
    assert_selector ".govuk-summary-list__row:nth-child(4) .govuk-summary-list__value", text: "No"
  end

  test "renders the comments row when the office has comments" do
    contact = build_stubbed(:contact, comments: "Lots of comments.")
    worldwide_office = build_stubbed(:worldwide_office, worldwide_organisation: @worldwide_organisation, contact:)

    render_inline(
      Admin::WorldwideOffices::Index::OfficeSummaryCardComponent.new(
        worldwide_office:,
        worldwide_organisation: @worldwide_organisation,
        contact:,
      ),
    )

    assert_selector ".govuk-summary-list__row", count: 6
    assert_selector ".govuk-summary-list__row:nth-child(3) .govuk-summary-list__key", text: "Comments"
    assert_selector ".govuk-summary-list__row:nth-child(3) .govuk-summary-list__value", text: worldwide_office.comments
  end

  test "renders the services row when the office has a service" do
    contact = build_stubbed(:contact)
    worldwide_service = build_stubbed(:worldwide_service)
    worldwide_office = build_stubbed(:worldwide_office, worldwide_organisation: @worldwide_organisation, contact:, services: [worldwide_service])

    render_inline(
      Admin::WorldwideOffices::Index::OfficeSummaryCardComponent.new(
        worldwide_office:,
        worldwide_organisation: @worldwide_organisation,
        contact:,
      ),
    )

    assert_selector ".govuk-summary-list__row", count: 6
    assert_selector ".govuk-summary-list__row:nth-child(4) .govuk-summary-list__key", text: "Services"
    assert_selector ".govuk-summary-list__row:nth-child(4) .govuk-summary-list__value", text: worldwide_service.name
  end

  test "renders the email row when the contact has an email address" do
    contact = build_stubbed(:contact, email: "test@email.com")
    worldwide_office = build_stubbed(:worldwide_office, worldwide_organisation: @worldwide_organisation, contact:)

    render_inline(
      Admin::WorldwideOffices::Index::OfficeSummaryCardComponent.new(
        worldwide_office:,
        worldwide_organisation: @worldwide_organisation,
        contact:,
      ),
    )

    assert_selector ".govuk-summary-list__row", count: 6
    assert_selector ".govuk-summary-list__row:nth-child(4) .govuk-summary-list__key", text: "Email"
    assert_selector ".govuk-summary-list__row:nth-child(4) .govuk-summary-list__value", text: contact.email
  end

  test "renders the email row when the contact has an address" do
    contact = build_stubbed(:contact, street_address: "random address")
    worldwide_office = build_stubbed(:worldwide_office, worldwide_organisation: @worldwide_organisation, contact:)

    render_inline(
      Admin::WorldwideOffices::Index::OfficeSummaryCardComponent.new(
        worldwide_office:,
        worldwide_organisation: @worldwide_organisation,
        contact:,
      ),
    )

    assert_selector ".govuk-summary-list__row", count: 6
    assert_selector ".govuk-summary-list__row:nth-child(4) .govuk-summary-list__key", text: "Address"
    assert_selector ".govuk-summary-list__row:nth-child(4) .govuk-summary-list__value", text: contact.street_address
  end

  test "renders the email row when the contact has a contact form url" do
    contact = build_stubbed(:contact, contact_form_url: "https://wwww.contact-me.org")
    worldwide_office = build_stubbed(:worldwide_office, worldwide_organisation: @worldwide_organisation, contact:)

    render_inline(
      Admin::WorldwideOffices::Index::OfficeSummaryCardComponent.new(
        worldwide_office:,
        worldwide_organisation: @worldwide_organisation,
        contact:,
      ),
    )

    assert_selector ".govuk-summary-list__row", count: 6
    assert_selector ".govuk-summary-list__row:nth-child(4) .govuk-summary-list__key", text: "Contact form URL"
    assert_selector ".govuk-summary-list__row:nth-child(4) .govuk-summary-list__value", text: contact.contact_form_url
  end

  test "renders the contact form url row when the contact has a contact form url" do
    contact = build_stubbed(:contact, contact_form_url: "https://wwww.contact-me.org")
    worldwide_office = build_stubbed(:worldwide_office, worldwide_organisation: @worldwide_organisation, contact:)

    render_inline(
      Admin::WorldwideOffices::Index::OfficeSummaryCardComponent.new(
        worldwide_office:,
        worldwide_organisation: @worldwide_organisation,
        contact:,
      ),
    )

    assert_selector ".govuk-summary-list__row", count: 6
    assert_selector ".govuk-summary-list__row:nth-child(4) .govuk-summary-list__key", text: "Contact form URL"
    assert_selector ".govuk-summary-list__row:nth-child(4) .govuk-summary-list__value", text: contact.contact_form_url
  end

  test "renders phone number rows when the contact has a multiple phone numbers" do
    contact_number1 = build_stubbed(:contact_number, label: "Fax", number: "123")
    contact_number2 = build_stubbed(:contact_number, label: "Phone", number: "456")
    contact = build_stubbed(:contact, contact_numbers: [contact_number1, contact_number2])
    worldwide_office = build_stubbed(:worldwide_office, worldwide_organisation: @worldwide_organisation, contact:)

    render_inline(
      Admin::WorldwideOffices::Index::OfficeSummaryCardComponent.new(
        worldwide_office:,
        worldwide_organisation: @worldwide_organisation,
        contact:,
      ),
    )

    assert_selector ".govuk-summary-list__row", count: 7
    assert_selector ".govuk-summary-list__row:nth-child(4) .govuk-summary-list__key", text: contact_number1.label
    assert_selector ".govuk-summary-list__row:nth-child(4) .govuk-summary-list__value", text: contact_number1.number
    assert_selector ".govuk-summary-list__row:nth-child(5) .govuk-summary-list__key", text: contact_number2.label
    assert_selector ".govuk-summary-list__row:nth-child(5) .govuk-summary-list__value", text: contact_number2.number
  end

  test "renders access and opening times when the office has access and opening time information" do
    contact = build_stubbed(:contact)
    worldwide_office = build_stubbed(:worldwide_office, worldwide_organisation: @worldwide_organisation, contact:, access_and_opening_times: "Always open")

    render_inline(
      Admin::WorldwideOffices::Index::OfficeSummaryCardComponent.new(
        worldwide_office:,
        worldwide_organisation: @worldwide_organisation,
        contact:,
      ),
    )

    assert_selector ".govuk-summary-list__row", count: 6
    assert_selector ".govuk-summary-list__row:nth-child(6) .govuk-summary-list__key", text: "Access and opening times"
    assert_selector ".govuk-summary-list__row:nth-child(6) .govuk-summary-list__value", text: worldwide_office.access_and_opening_times
  end

  test "does not render the add translation action when the contact is a non-english translation and there are missing translations for a contact" do
    contact = create(:contact, translated_into: [:es])
    translated_contact = contact.non_english_localised_models([:contact_numbers]).last
    worldwide_office = build_stubbed(:worldwide_office, worldwide_organisation: @worldwide_organisation, contact:)

    contact.stubs(:missing_translations).returns([:fr])

    render_inline(
      Admin::WorldwideOffices::Index::OfficeSummaryCardComponent.new(
        worldwide_office:,
        worldwide_organisation: @worldwide_organisation,
        contact: translated_contact,
      ),
    )

    assert_selector ".govuk-summary-card__actions .govuk-summary-card__action:nth-child(2) a[href='#']", text: "Add translation", count: 0
  end

  test "renders the correct values when contact is a translation" do
    contact_number = create(:contact_number)
    contact = create(
      :contact_with_country,
      translated_into: [:fr],
      title: "title",
      comments: "comments",
      email: "email.com",
      contact_form_url: "https://wwww.contact-me.org",
      contact_numbers: [contact_number],
    )
    translated_contact = contact.non_english_localised_models([:contact_numbers]).last
    worldwide_office = build_stubbed(:worldwide_office, worldwide_organisation: @worldwide_organisation, contact:)

    render_inline(
      Admin::WorldwideOffices::Index::OfficeSummaryCardComponent.new(
        worldwide_office:,
        worldwide_organisation: @worldwide_organisation,
        contact: translated_contact,
      ),
    )

    assert_selector ".govuk-summary-card__title", text: translated_contact.title
    assert_selector ".govuk-summary-card__actions .govuk-summary-card__action:nth-child(1) a[href='#{edit_admin_worldwide_organisation_worldwide_office_translation_path(@worldwide_organisation, worldwide_office, translated_contact.translation_locale)}']"
    assert_selector ".govuk-summary-card__actions .govuk-summary-card__action:nth-child(2) a[href='#{confirm_destroy_admin_worldwide_organisation_worldwide_office_translation_path(@worldwide_organisation, worldwide_office, translated_contact.translation_locale)}']"
    assert_selector ".govuk-summary-list__row", count: 8
    assert_selector ".govuk-summary-list__row:nth-child(1) .govuk-summary-list__key", text: "Office type"
    assert_selector ".govuk-summary-list__row:nth-child(1) .govuk-summary-list__value", text: worldwide_office.worldwide_office_type.name
    assert_selector ".govuk-summary-list__row:nth-child(2) .govuk-summary-list__key", text: "Contact type"
    assert_selector ".govuk-summary-list__row:nth-child(2) .govuk-summary-list__value", text: contact.contact_type.name
    assert_selector ".govuk-summary-list__row:nth-child(3) .govuk-summary-list__key", text: "Comments"
    assert_selector ".govuk-summary-list__row:nth-child(3) .govuk-summary-list__value", text: translated_contact.comments
    assert_selector ".govuk-summary-list__row:nth-child(4) .govuk-summary-list__key", text: "Email"
    assert_selector ".govuk-summary-list__row:nth-child(4) .govuk-summary-list__value", text: translated_contact.email
    assert_selector ".govuk-summary-list__row:nth-child(5) .govuk-summary-list__key", text: "Address"
    assert_selector ".govuk-summary-list__row:nth-child(5) .govuk-summary-list__value", text: translated_contact.street_address
    assert_selector ".govuk-summary-list__row:nth-child(6) .govuk-summary-list__key", text: "Contact form URL"
    assert_selector ".govuk-summary-list__row:nth-child(6) .govuk-summary-list__value", text: translated_contact.contact_form_url
    assert_selector ".govuk-summary-list__row:nth-child(7) .govuk-summary-list__key", text: contact_number.label
    assert_selector ".govuk-summary-list__row:nth-child(7) .govuk-summary-list__value", text: contact_number.number
    assert_selector ".govuk-summary-list__row:nth-child(8) .govuk-summary-list__key", text: "Markdown code"
    assert_selector ".govuk-summary-list__row:nth-child(8) .govuk-summary-list__value", text: "[Contact:#{translated_contact.id}]"
  end
end
