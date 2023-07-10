# frozen_string_literal: true

require "test_helper"

class Admin::SocialMediaAccounts::Index::SummaryCardComponentTest < ViewComponent::TestCase
  include Rails.application.routes.url_helpers

  setup do
    @socialable = build_stubbed(:organisation)
    @social_media_account = build_stubbed(:social_media_account, socialable: @socialable, title: "Tweeter")
  end

  test "renders the summary card with the correct values" do
    render_inline(Admin::SocialMediaAccounts::Index::SummaryCardComponent.new(
                    socialable: @socialable,
                    social_media_account: @social_media_account,
                  ))

    social_media_service_name = @social_media_account.social_media_service.name

    assert_selector ".govuk-summary-card__title", text: social_media_service_name
    assert_selector ".govuk-summary-card__action a[href='#{@social_media_account.url}']", text: "View #{social_media_service_name}"
    assert_selector ".govuk-summary-card__action a[href='#{edit_polymorphic_path([:admin, @socialable, @social_media_account])}']", text: "Edit #{social_media_service_name}"
    assert_selector ".govuk-summary-card__action a[href='#{confirm_destroy_admin_organisation_social_media_account_path(@socialable, @social_media_account)}']", text: "Delete #{social_media_service_name}"
    assert_selector ".govuk-summary-list__key", text: "Account"
    assert_selector ".govuk-summary-list__value", text: @social_media_account.title
  end

  test "renders url as the summary list key if a social media account doesn't have a title" do
    social_media_account = build_stubbed(:social_media_account, socialable: @socialable)

    render_inline(Admin::SocialMediaAccounts::Index::SummaryCardComponent.new(
                    socialable: @socialable,
                    social_media_account:,
                  ))

    assert_selector ".govuk-summary-list__key", text: "Account"
    assert_selector ".govuk-summary-list__value", text: @social_media_account.url
  end

  test "renders the summary card with the correct values when the socialable has translations" do
    socialable = create(:organisation, translated_into: %i[es fr])
    english_social_media_account = create(:social_media_account, translated_into: [:fr], socialable:)
    french_social_media_account_translation = english_social_media_account.translations.find_by(locale: "fr")
    french_social_media_account_translation.update!(title: "Tweeter", url: "http://example.fr")

    render_inline(Admin::SocialMediaAccounts::Index::SummaryCardComponent.new(
                    socialable:,
                    social_media_account: english_social_media_account,
                  ))

    social_media_service_name = english_social_media_account.social_media_service.name

    assert_selector ".govuk-summary-card__title", text: social_media_service_name
    assert_selector ".govuk-summary-card__action a[href='#{confirm_destroy_admin_organisation_social_media_account_path(socialable, english_social_media_account)}']", text: "Delete #{social_media_service_name}"
    assert_selector ".govuk-summary-card__action a[href='#{edit_polymorphic_path([:admin, socialable, english_social_media_account])}']", text: "Edit #{social_media_service_name}", count: 0
    assert_selector ".govuk-summary-list__row:nth-child(1) .govuk-summary-list__key", text: "English"
    assert_selector ".govuk-summary-list__row:nth-child(1) .govuk-summary-list__value", text: english_social_media_account.url
    assert_selector ".govuk-summary-list__row:nth-child(1) .govuk-summary-list__actions a[href='#{english_social_media_account.url}']", text: "View English"
    assert_selector ".govuk-summary-list__row:nth-child(1) .govuk-summary-list__actions a[href='#{edit_polymorphic_path([:admin, socialable, english_social_media_account], locale: :en)}']", text: "Edit English account"
    assert_selector ".govuk-summary-list__row:nth-child(2) .govuk-summary-list__key", text: "Spanish"
    assert_selector ".govuk-summary-list__row:nth-child(2) .govuk-summary-list__value", text: english_social_media_account.url
    assert_selector ".govuk-summary-list__row:nth-child(2) .govuk-summary-list__actions a[href='#{english_social_media_account.url}']", text: "View Spanish"
    assert_selector ".govuk-summary-list__row:nth-child(2) .govuk-summary-list__actions a[href='#{edit_polymorphic_path([:admin, socialable, english_social_media_account], locale: :es)}']", text: "Edit Spanish account"
    assert_selector ".govuk-summary-list__row:nth-child(3) .govuk-summary-list__key", text: "French"
    assert_selector ".govuk-summary-list__row:nth-child(3) .govuk-summary-list__value", text: french_social_media_account_translation.title
    assert_selector ".govuk-summary-list__row:nth-child(3) .govuk-summary-list__actions a[href='#{french_social_media_account_translation.url}']", text: "View French"
    assert_selector ".govuk-summary-list__row:nth-child(3) .govuk-summary-list__actions a[href='#{edit_polymorphic_path([:admin, socialable, english_social_media_account], locale: :fr)}']", text: "Edit French account"
  end

  test "renders the correct links when the socialable is a world news organisation" do
    socialable = build_stubbed(:worldwide_organisation)
    social_media_account = build_stubbed(:social_media_account, socialable:)

    render_inline(Admin::SocialMediaAccounts::Index::SummaryCardComponent.new(
                    socialable:,
                    social_media_account:,
                  ))

    social_media_service_name = social_media_account.social_media_service.name

    assert_selector ".govuk-summary-card__action a[href='#{edit_polymorphic_path([:admin, socialable, social_media_account])}']", text: "Edit #{social_media_service_name}"
    assert_selector ".govuk-summary-card__action a[href='#{confirm_destroy_admin_worldwide_organisation_social_media_account_path(socialable, social_media_account)}']", text: "Delete #{social_media_service_name}"
  end
end
