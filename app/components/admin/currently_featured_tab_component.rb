# frozen_string_literal: true

class Admin::CurrentlyFeaturedTabComponent < ViewComponent::Base
  include Admin::EditionRoutesHelper
  include Admin::OrganisationHelper

  attr_reader :features, :maximum_featured_documents

  def initialize(features:, maximum_featured_documents:)
    @features = features || []
    @maximum_featured_documents = maximum_featured_documents
  end

private

  def live_features
    @live_features ||= features.slice(0, maximum_featured_documents)
  end

  def remaining_features
    @remaining_features ||= features - live_features
  end

  def table(caption, features)
    render "govuk_publishing_components/components/table", {
      caption:,
      caption_classes: "govuk-heading-s",
      head: [
        {
          text: "Title",
        },
        {
          text: "Type",
        },
        {
          text: "Published",
        },
        {
          text: tag.span("Actions", class: "govuk-visually-hidden"),
          format: "numeric",
        },
      ],
      rows: rows(features),
    }
  end

  def rows(features)
    features.map do |feature|
      [
        title_row(feature),
        type_row(feature),
        published_row(feature),
        actions_row(feature),
      ]
    end
  end

  def title_row(feature)
    {
      text: tag.p(title(feature), class: "govuk-!-font-weight-bold govuk-!-margin-0"),
    }
  end

  def title(feature)
    if feature.document&.live_edition.present?
      feature
    elsif feature.topical_event.present?
      feature.topical_event
    elsif feature.offsite_link.present?
      feature.offsite_link
    else
      feature
    end
  end

  def type_row(feature)
    {
      text: type(feature),
    }
  end

  def type(feature)
    if feature.document&.live_edition.present?
      "#{feature.document.live_edition.type.titleize} (document)"
    elsif feature.topical_event.present?
      "Topical Event"
    elsif feature.offsite_link.present?
      "#{feature.offsite_link.humanized_link_type} (offsite link)"
    else
      ""
    end
  end

  def published_row(feature)
    {
      text: published_at(feature),
    }
  end

  def published_at(feature)
    if feature.document&.live_edition.present?
      localize(feature.document.live_edition.major_change_published_at.to_date)
    elsif feature.topical_event.present?
      topical_event_dates_string(feature.topical_event)
    elsif feature.offsite_link.present?
      (localize(feature.offsite_link.date.to_date) if feature.offsite_link.date) || ""
    else
      ""
    end
  end

  def actions_row(feature)
    {
      text: sanitize(edit_link(feature) + unfeature_link(feature)),
    }
  end

  def edit_link(feature)
    if feature.document&.live_edition.present?
      link_to(sanitize("Edit #{tag.span(feature, class: 'govuk-visually-hidden')}"), admin_edition_path(feature.document.live_edition), class: "govuk-link")
    elsif feature.topical_event.present?
      link_to(sanitize("Edit #{tag.span(feature.topical_event, class: 'govuk-visually-hidden')}"), edit_admin_topical_event_path(feature.topical_event), class: "govuk-link")
    elsif feature.offsite_link.present?
      link_to(sanitize("Edit #{tag.span(feature.offsite_link, class: 'govuk-visually-hidden')}"), polymorphic_path([:edit, :admin, feature.offsite_link.parent, feature.offsite_link]), class: "govuk-link")
    else
      ""
    end
  end

  def unfeature_link(feature)
    if feature.document&.live_edition.present? || feature.topical_event.present? || feature.offsite_link.present?
      link_to(sanitize("Unfeature #{tag.span(title(feature), class: 'govuk-visually-hidden')}"), "#", class: "gem-link--destructive govuk-!-margin-left-2")
    else
      ""
    end
  end
end
