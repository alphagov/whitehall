# frozen_string_literal: true

class Admin::Editions::Show::PreviewComponent < ViewComponent::Base
  include Admin::UrlOptionsHelper

  def initialize(edition:, invalid_tab_forms: [])
    @edition = edition
    @invalid_tab_forms = invalid_tab_forms
  end

  def render?
    edition.pre_publication?
  end

private

  attr_reader :edition, :invalid_tab_forms

  def versioning_completed
    @versioning_completed ||= edition.versioning_completed?
  end

  def preview_link(link_text, href)
    link_to(link_text,
            href,
            class: "govuk-link",
            target: "_blank", rel: "noopener")
  end

  def primary_locale_link_text
    if available_in_multiple_languages
      "Preview on website - #{Locale.new(edition.primary_locale).english_language_name} (opens in new tab)"
    else
      "Preview on website (opens in new tab)"
    end
  end

  def available_in_multiple_languages
    @available_in_multiple_languages ||= edition.translatable? && edition.available_in_multiple_languages?
  end
end
