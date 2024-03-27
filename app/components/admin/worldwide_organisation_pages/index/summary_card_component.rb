# frozen_string_literal: true

class Admin::WorldwideOrganisationPages::Index::SummaryCardComponent < ViewComponent::Base
  attr_reader :page

  def initialize(page:)
    @page = page
  end

private

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
      confirm_destroy_action,
    ].compact
  end

  def edit_action
    {
      label: "Edit",
      href: edit_admin_editionable_worldwide_organisation_page_path(page.edition, page),
    }
  end

  def confirm_destroy_action
    {
      label: "Delete",
      href: confirm_destroy_admin_editionable_worldwide_organisation_page_path(page.edition, page),
      destructive: true,
    }
  end
end
