# frozen_string_literal: true

class Admin::Editions::Show::PreviewComponent < ViewComponent::Base
  include Admin::UrlOptionsHelper

  def initialize(edition:)
    @edition = edition
  end

  def render?
    !edition.publicly_visible?
  end

private

  attr_reader :edition

  def versioning_completed
    @versioning_completed ||= edition.versioning_completed?
  end

  def preview_link(link_text, href, tracking_label)
    link_to(link_text,
            href,
            class: "govuk-link",
            target: "_blank",
            data: {
              module: "gem-track-click",
              "track-category": "button-clicked",
              "track-action": track_action,
              "track-label": tracking_label,
            }, rel: "noopener")
  end

  def primary_locale_link_text
    if available_in_multiple_languages
      "Preview on website - English (opens in new tab)"
    else
      "Preview on website (opens in new tab)"
    end
  end

  def available_in_multiple_languages
    @available_in_multiple_languages ||= edition.translatable? && edition.available_in_multiple_languages?
  end

  def track_action
    @track_action ||= "#{edition.model_name.singular.dasherize}-button"
  end
end
