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
      type_row,
      acronym_row,
      url_row,
      status_row,
      closed_on_row,
      superseding_organisations_row,
      description_row,
      alternative_format_contact_email_row,
      organisation_chart_url_row,
      custom_jobs_url_row,
      parent_organisations_row,
      topical_events_row,
      social_media_accounts_rows,
      crest_row,
      brand_colour_row,
      analytics_identifier_row,
      featured_links_row,
      default_news_image_row,
    ]
    .flatten
    .compact
  end

  def type_row
    {
      field: "Type",
      value: organisation.organisation_type.name,
    }
  end

  def acronym_row
    {
      field: "Acronym",
      value: organisation.acronym,
    }
  end

  def url_row
    {
      field: "URL",
      value: link_to(organisation.url, organisation.url, class: "govuk-link"),
    }
  end

  def status_row
    {
      field: "Status on GOV.UK",
      value: organisation.govuk_status.titleize,
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
    return unless organisation.closed? && organisation.superseding_organisations.any?

    {
      field: "Superseded by",
      value: organisation.superseding_organisations.map { |org| link_to(org.name, admin_organisation_path(org), class: "govuk-link") }.join(", ").html_safe,
    }
  end

  def description_row
    {
      field: "Description #{tag.br}To edit this, select the 'Corporate Information pages' tab. Click on 'About us' and edit the 'Summary' field in a new edition".html_safe,
      value: govspeak_to_html(organisation.summary),
    }
  end

  def alternative_format_contact_email_row
    {
      field: "Email address for ordering attached files in an alternative format",
      value: organisation.alternative_format_contact_email,
    }
  end

  def organisation_chart_url_row
    {
      field: "Organisation chart URL",
      value: (link_to(organisation.organisation_chart_url, organisation.organisation_chart_url, class: "govuk-link") if organisation.organisation_chart_url.present?),
    }
  end

  def custom_jobs_url_row
    {
      field: "Custom jobs URL",
      value: (link_to(organisation.custom_jobs_url, organisation.custom_jobs_url, class: "govuk-link") if organisation.custom_jobs_url.present?),
    }
  end

  def parent_organisations_row
    {
      field: "Sponsoring organisations",
      value: if organisation.parent_organisations.any?
               organisation.parent_organisations.map { |org| link_to(org.name, [:admin, org], class: "govuk-link") }.to_sentence.html_safe
             else
               "None"
             end,
    }
  end

  def topical_events_row
    {
      field: "Topical events",
      value: if organisation.topical_events.any?
               organisation.topical_events.map { |topical_event| link_to(topical_event.name, [:admin, topical_event], class: "govuk-link") }.to_sentence.html_safe
             else
               "None"
             end,
    }
  end

  def social_media_accounts_rows
    return [] if organisation.social_media_accounts.blank?

    organisation.social_media_accounts.map do |account|
      {
        field: account.social_media_service.name,
        value: link_to(account.url, account.url, class: "govuk-link"),
      }
    end
  end

  def crest_row
    {
      field: "Crest",
      value: organisation.organisation_logo_type.title,
    }
  end

  def brand_colour_row
    {
      field: "Brand colour",
      value: if organisation.organisation_brand_colour
               organisation.organisation_brand_colour.title
             else
               "None"
             end,
    }
  end

  def analytics_identifier_row
    {
      field: "Analytics identifier",
      value: organisation.analytics_identifier,
    }
  end

  def featured_links_row
    {
      field: "Featured links",
      value: if organisation.featured_links.any?
               render("govuk_publishing_components/components/list", {
                 visible_counters: true,
                 items: organisation.featured_links.map do |link|
                   link_to(link.title, link.url, class: "govuk-link")
                 end,
               })
             else
               "None"
             end,
    }
  end

  def default_news_image_row
    return unless organisation.default_news_image

    {
      field: "Default news image",
      value: image_tag(organisation.default_news_image.file.url(:s300)),
    }
  end
end
