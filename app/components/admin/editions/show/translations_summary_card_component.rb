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

  def rows
    edition.non_english_translations.map { |translation|
      [
        key: Locale.new(translation.locale).native_and_english_language_name,
        value: translation.title,
        actions: row_actions(edition, translation),
      ]
    }
    .flatten
  end

  def row_actions(edition, translation)
    return [] unless edition.editable?

    [
      {
        label: "Edit",
        href: edit_admin_edition_translation_path(edition, translation.locale),
      },
      {
        label: "Delete",
        href: confirm_destroy_admin_edition_translation_path(edition, translation.locale),
        destructive: true,
      },
    ]
    .flatten
  end
end
