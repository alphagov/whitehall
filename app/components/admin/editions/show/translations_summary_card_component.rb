# frozen_string_literal: true

class Admin::Editions::Show::TranslationsSummaryCardComponent < ViewComponent::Base
  def initialize(edition:)
    @edition = edition
  end

  def render?
    edition.translatable?
  end

private

  attr_reader :edition

  def summary_card_actions
    return {} unless edition.editable? && edition.missing_translations.any?

    [
      {
        label: "Add translation",
        href: new_admin_edition_translation_path(edition),
      },
    ]
  end
end
