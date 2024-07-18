# frozen_string_literal: true

class Admin::WorldwideOrganisationPages::Index::SummaryCardComponent < ViewComponent::Base
  attr_reader :page, :worldwide_organisation

  def initialize(page:, worldwide_organisation:)
    @page = page
    @worldwide_organisation = worldwide_organisation
  end

private

  def title
    non_english_translation? ? "#{page.default_locale_title} - #{page.translation_locale.native_and_english_language_name}" : page.title
  end

  def rows
    [
      summary_row,
      body_row,
    ].flatten.compact
  end

  def summary_row
    return if page.summary.nil?

    {
      key: "Summary",
      value: simple_format(truncate(page.summary, length: 500), class: "govuk-!-margin-top-0"),
    }
  end

  def body_row
    return if page.body.nil?

    {
      key: "Body",
      value: simple_format(truncate(page.body, length: 500), class: "govuk-!-margin-top-0"),
    }
  end

  def summary_card_actions
    [
      edit_action,
      add_translation_action,
      confirm_destroy_action,
    ].compact
  end

  def edit_action
    href = if non_english_translation?
             edit_admin_worldwide_organisation_page_translation_path(worldwide_organisation, page, page.translation_locale)
           else
             edit_admin_worldwide_organisation_page_path(page.edition, page)
           end

    {
      label: "Edit",
      href:,
    }
  end

  def add_translation_action
    return if page.missing_translations.blank? || non_english_translation?

    {
      label: "Add translation",
      href: admin_worldwide_organisation_page_translations_path(worldwide_organisation, page, page.translation_locale),
    }
  end

  def confirm_destroy_action
    href = if non_english_translation?
             confirm_destroy_admin_worldwide_organisation_page_translation_path(worldwide_organisation, page, page.translation_locale)
           else
             confirm_destroy_admin_worldwide_organisation_page_path(worldwide_organisation, page)
           end

    {
      label: "Delete",
      href:,
      destructive: true,
    }
  end

  def non_english_translation?
    page.translation_locale.code != :en
  end
end
