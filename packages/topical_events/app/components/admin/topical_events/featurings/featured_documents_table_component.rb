# frozen_string_literal: true

class Admin::TopicalEvents::Featurings::FeaturedDocumentsTableComponent < ViewComponent::Base
  include Admin::EditionRoutesHelper
  include Admin::TopicalEventFeaturingsHelper

  attr_reader :caption, :featurings

  def initialize(caption:, featurings:)
    @caption = caption
    @featurings = featurings
  end

private

  def rows(featurings)
    featurings.map do |featuring|
      [
        title_row(featuring),
        type_row(featuring),
        published_row(featuring),
        actions_row(featuring),
      ]
    end
  end

  def title_row(featuring)
    {
      text: tag.p(featuring.title, class: "govuk-!-font-weight-bold govuk-!-margin-0"),
    }
  end

  def type_row(featuring)
    {
      text: type(featuring),
    }
  end

  def type(featuring)
    if featuring.offsite?
      "#{featuring.offsite_link.humanized_link_type} (offsite link)"
    else
      "#{featuring.edition.type.titleize} (document)"
    end
  end

  def published_row(featuring)
    {
      text: featuring_published_on(featuring),
    }
  end

  def actions_row(featuring)
    {
      text: sanitize(edit_link(featuring) + unfeature_link(featuring)),
    }
  end

  def edit_link(featuring)
    if featuring.offsite?
      link_to(sanitize("Edit #{tag.span(featuring.offsite_link, class: 'govuk-visually-hidden')}"), edit_admin_topical_event_offsite_link_path(featuring.topical_event, featuring.offsite_link), class: "govuk-link")
    else
      link_to(sanitize("View #{tag.span(featuring.title, class: 'govuk-visually-hidden')}"), admin_edition_path(featuring.edition), class: "govuk-link")
    end
  end

  def unfeature_link(featuring)
    link_to(sanitize("Unfeature #{tag.span(featuring.title, class: 'govuk-visually-hidden')}"), confirm_destroy_admin_topical_event_topical_event_featuring_path(featuring.topical_event, featuring), class: "gem-link--destructive govuk-!-margin-left-2")
  end
end
