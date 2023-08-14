# frozen_string_literal: true

class Admin::WorldwideOffices::Index::OfficeSummaryCardComponent < ViewComponent::Base
  include Admin::ContactsHelper
  include ApplicationHelper

  attr_reader :worldwide_office, :worldwide_organisation, :contact

  def initialize(worldwide_office:, worldwide_organisation:, contact:)
    @worldwide_office = worldwide_office
    @worldwide_organisation = worldwide_organisation
    @contact = contact
  end

private

  def rows
    [
      worldwide_office_type_row,
      contact_type_row,
      comments_row,
      homepage_row,
      services_row,
      email_address_row,
      address_row,
      contact_form_url_row,
      phone_number_rows,
      main_office_row,
      markdown_row,
      access_and_opening_times_row,
    ].flatten.compact
  end

  def worldwide_office_type_row
    {
      key: "Office type",
      value: worldwide_office.worldwide_office_type.name,
    }
  end

  def contact_type_row
    {
      key: "Contact type",
      value: worldwide_office.contact.contact_type.name,
    }
  end

  def comments_row
    return if contact.comments.blank?

    {
      key: "Comments",
      value: format_with_html_line_breaks(h(contact.comments)),
    }
  end

  def homepage_row
    return if non_english_translation?

    {
      key: "On homepage",
      value: worldwide_organisation.office_shown_on_home_page?(worldwide_office) ? "Yes" : "No",
    }
  end

  def services_row
    return if worldwide_office.services.blank? || non_english_translation?

    {
      key: "Services",
      value: render("govuk_publishing_components/components/list", { items: worldwide_office.services.map(&:name), margin_bottom: 0 }),
    }
  end

  def email_address_row
    return if contact.email.blank?

    {
      key: "Email",
      value: contact.email,
    }
  end

  def address_row
    return if render_hcard_address(contact).blank?

    {
      key: "Address",
      value: render_hcard_address(contact),
    }
  end

  def contact_form_url_row
    return if contact.contact_form_url.blank?

    {
      key: "Contact form URL",
      value: contact.contact_form_url,
      actions: [
        {
          label: "View",
          href: contact.contact_form_url,
        },
      ],
    }
  end

  def phone_number_rows
    return if worldwide_office.contact_numbers.blank?

    worldwide_office.contact_numbers.map do |contact_number|
      {
        key: contact_number.label,
        value: contact_number.number,
      }
    end
  end

  def main_office_row
    return if non_english_translation?

    {
      key: "Main office",
      value: worldwide_office == worldwide_organisation.main_office ? "Yes" : "No",
    }
  end

  def markdown_row
    {
      key: "Markdown code",
      value: "[Contact:#{contact.id}]",
    }
  end

  def access_and_opening_times_row
    return if worldwide_office.access_and_opening_times.blank? || non_english_translation?

    {
      key: "Access and opening times",
      value: worldwide_office.access_and_opening_times,
    }
  end

  def summary_card_actions
    [
      edit_action,
      add_translation_action,
      confirm_delete_action,
    ].compact
  end

  def edit_action
    if non_english_translation?
      {
        label: "Edit",
        href: edit_admin_worldwide_organisation_worldwide_office_translation_path(worldwide_organisation, worldwide_office, contact.translation_locale),
      }
    else
      {
        label: "Edit",
        href: edit_admin_worldwide_organisation_worldwide_office_path(worldwide_organisation, worldwide_office),
      }
    end
  end

  def add_translation_action
    return if contact.missing_translations.blank? || non_english_translation?

    {
      label: "Add translation",
      href: admin_worldwide_organisation_worldwide_office_translations_path(worldwide_organisation, worldwide_office, contact.translation_locale),
    }
  end

  def confirm_delete_action
    if non_english_translation?
      {
        label: "Delete",
        href: confirm_destroy_admin_worldwide_organisation_worldwide_office_translation_path(worldwide_organisation, worldwide_office, contact.translation_locale),
        destructive: true,
      }
    else
      {
        label: "Delete",
        href: confirm_destroy_admin_worldwide_organisation_worldwide_office_path(worldwide_organisation, worldwide_office),
        destructive: true,
      }
    end
  end

  def non_english_translation?
    contact.translation_locale.code != :en
  end
end
