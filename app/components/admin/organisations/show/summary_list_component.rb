# frozen_string_literal: true

class Admin::Organisations::Show::SummaryListComponent < ViewComponent::Base
  include ApplicationHelper
  include GovspeakHelper

  attr_reader :organisation, :editable

  def initialize(organisation:, editable: false)
    @organisation = organisation
    @editable = editable
  end

private

  def rows
    [
      name_row,
      acronym_row,
      logo_formatted_name_row,
      logo_crest_row,
      brand_colour_row,
      default_news_image_row,
      url_row,
      type_row,
      alternative_format_contact_email_row,
      status_row,
      govuk_closed_status_row,
      closed_on_row,
      superseding_organisations_row,
      organisation_chart_url_row,
      recruitment_url_row,
      political_row,
      parent_organisations_row,
      topical_events_row,
      featured_links_position_row,
      featured_links_row,
      management_team_row,
      foi_exempt_row,
      analytics_identifier_row,
    ]
    .flatten
    .compact
  end

  def name_row
    {
      field: "Name",
      value: organisation.name,
    }
  end

  def acronym_row
    return if organisation.acronym.blank?

    {
      field: "Acronym",
      value: organisation.acronym,
    }
  end

  def logo_formatted_name_row
    {
      field: "Logo formatted name",
      value: organisation.logo_formatted_name,
    }
  end

  def logo_crest_row
    return if organisation.organisation_logo_type.blank?

    {
      field: "Logo crest",
      value: organisation.organisation_logo_type.title,
    }
  end

  def brand_colour_row
    return if organisation.organisation_brand_colour.blank?

    {
      field: "Brand colour",
      value: organisation.organisation_brand_colour.title,
    }
  end

  def default_news_image_row
    return if organisation.default_news_image.blank?

    {
      field: "Default news image",
      value: image_tag(organisation.default_news_image.file.url(:s300)),
    }
  end

  def url_row
    return if organisation.url.blank?

    {
      field: "Organisation’s URL",
      value: organisation.url,
      edit: {
        href: organisation.url,
        link_text: "View",
      },
    }
  end

  def type_row
    {
      field: "Type",
      value: organisation.organisation_type.name,
    }
  end

  def alternative_format_contact_email_row
    return if organisation.alternative_format_contact_email.blank?

    {
      field: "Accessible formats request email",
      value: organisation.alternative_format_contact_email,
    }
  end

  def status_row
    {
      field: "Status on GOV.UK",
      value: organisation.govuk_status.titleize,
    }
  end

  def govuk_closed_status_row
    return if organisation.govuk_closed_status.blank?

    {
      field: "Reason for closure",
      value: organisation.govuk_closed_status,
    }
  end

  def closed_on_row
    return unless organisation.closed? && organisation.closed_at.present?

    {
      field: "Organisation closed on",
      value: absolute_date(organisation.closed_at),
    }
  end

  def superseding_organisations_row
    return unless organisation.closed? && superseding_organisations.any?

    associations_rows(superseding_organisations, "Superseding organisation")
  end

  def organisation_chart_url_row
    return if organisation.organisation_chart_url.blank?

    {
      field: "Organisation chart URL",
      value: organisation.organisation_chart_url,
      edit: {
        href: organisation.organisation_chart_url,
        link_text: "View",
      },
    }
  end

  def recruitment_url_row
    return if organisation.custom_jobs_url.blank?

    {
      field: "Recruitment URL",
      value: organisation.custom_jobs_url,
      edit: {
        href: organisation.custom_jobs_url,
        link_text: "View",
      },
    }
  end

  def political_row
    return unless organisation.political

    {
      field: "Publishes content associated with the current government",
      value: "Yes",
    }
  end

  def parent_organisations_row
    return if parent_organisations.blank?

    associations_rows(parent_organisations, "Sponsoring organisation")
  end

  def topical_events_row
    return if topical_events.blank?

    associations_rows(topical_events, "Topical event")
  end

  def featured_links_position_row
    {
      field: "Featured link position",
      value: organisation.homepage_type == "news" ? "News priority" : "Service priority",
    }
  end

  def featured_links_row
    return if featured_links.blank?

    mutliple_links = featured_links.many?

    featured_links.each_with_index.map do |featured_link, index|
      {
        field: "Featured link #{index + 1 if mutliple_links}".strip,
        value: featured_link.title,
        edit: {
          href: featured_link.url,
          link_text: "View",
        },
      }
    end
  end

  def management_team_row
    return if organisation.important_board_members.blank?

    {
      field: "Management team images on homepage",
      value: organisation.important_board_members,
    }
  end

  def foi_exempt_row
    return unless organisation.foi_exempt

    {
      field: "Exempt from Freedom of Information requests",
      value: "Yes",
    }
  end

  def analytics_identifier_row
    return if organisation.analytics_identifier.blank?

    {
      field: "Analytics identifier",
      value: organisation.analytics_identifier,
    }
  end

  def edit
    return {} unless editable

    {
      href: edit_admin_organisation_path(organisation),
      link_text: "Edit",
    }
  end

  def superseding_organisations
    @superseding_organisations ||= organisation.superseding_organisations
  end

  def parent_organisations
    @parent_organisations ||= organisation.parent_organisations
  end

  def topical_events
    @topical_events ||= organisation.topical_events
  end

  def featured_links
    @featured_links ||= organisation.featured_links
  end

  def associations_rows(associated_models, label)
    mutliple_associations = associated_models.many?

    associated_models.each_with_index.map do |model, index|
      {
        field: "#{label} #{index + 1 if mutliple_associations}".strip,
        value: model.name,
        edit: view_link(model),
      }
    end
  end

  def view_link(model)
    {
      href: model.public_url,
      link_text: "View",
    }
  end
end
