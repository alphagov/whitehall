# frozen_string_literal: true

class Admin::Editions::Show::PreviewComponent < ViewComponent::Base
  include Admin::UrlOptionsHelper

  def initialize(edition:)
    @edition = edition
  end

  def render?
    edition.pre_publication?
  end

private

  attr_reader :edition

  def preview_link(link_text, href)
    link_to(link_text,
            href,
            class: "govuk-link",
            target: "_blank", rel: "noopener")
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
end
