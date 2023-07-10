# frozen_string_literal: true

class Admin::SocialMediaAccounts::Index::SummaryCardComponent < ViewComponent::Base
  attr_reader :socialable, :social_media_account

  def initialize(socialable:, social_media_account:)
    @socialable = socialable
    @social_media_account = social_media_account
  end

private

  def rows
    rows = socialable_translated_locales.map do |locale|
      translation = social_media_account.translations.find_by(locale: locale.code)
      {
        key: key(locale),
        value: value(translation),
        actions: actions(locale, translation),
      }
    end

    reject_blank_rows(rows)
  end

  def reject_blank_rows(rows)
    rows.reject { |row| row[:value].blank? }
  end

  def socialable_translated_locales
    [Locale.new(:en)] + social_media_account.socialable.non_english_translated_locales
  end

  def key(locale)
    socialable_translations_present? ? "#{locale.english_language_name} account" : "Account"
  end

  def value(translation = nil)
    if translation.present? && translation.title.present?
      translation.title
    elsif translation.present?
      translation.url
    elsif social_media_account.title.present?
      social_media_account.title
    else
      social_media_account.url
    end
  end

  def actions(locale, translation = nil)
    return unless socialable_translations_present?

    actions = []
    actions << view_action(translation)
    actions << edit_action(locale)
    actions.compact
  end

  def view_action(translation)
    {
      label: "View",
      href: translation.present? ? translation.url : social_media_account.url,
    }
  end

  def edit_action(locale)
    {
      label: "Edit",
      href: edit_polymorphic_path([:admin, socialable, social_media_account], locale:),
    }
  end

  def summary_card_actions(translation = nil)
    actions = []
    actions << view_summary_card_action(translation)
    actions << edit_summary_card_action
    actions << confirm_destroy_summary_card_action
    actions.compact
  end

  def view_summary_card_action(translation = nil)
    return if socialable_translations_present?

    {
      label: "View",
      href: translation.present? ? translation.url : social_media_account.url,
    }
  end

  def edit_summary_card_action
    return if socialable_translations_present?

    {
      label: "Edit",
      href: edit_polymorphic_path([:admin, @socialable, social_media_account]),
    }
  end

  def confirm_destroy_summary_card_action
    {
      label: "Delete",
      href: polymorphic_path([:confirm_destroy, :admin, socialable, social_media_account]),
      destructive: true,
    }
  end

  def socialable_translations_present?
    @socialable_translations_present ||= socialable.non_english_translated_locales.present?
  end
end
