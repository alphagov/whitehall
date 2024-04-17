# frozen_string_literal: true

require "test_helper"

class Admin::WorldwideOrganisationPages::Index::SummaryCardComponentTest < ViewComponent::TestCase
  include Rails.application.routes.url_helpers

  test "renders a worldwide organisation page summary card" do
    page = create(:worldwide_organisation_page, summary: "a" * 501, body: "b" * 501)

    render_inline(Admin::WorldwideOrganisationPages::Index::SummaryCardComponent.new(page:, worldwide_organisation: page.edition))

    assert_selector ".govuk-summary-card__title", text: "Publication scheme"
    assert_selector ".govuk-summary-card__actions .govuk-summary-card__action:nth-child(1) a[href='#{edit_admin_editionable_worldwide_organisation_page_path(page.edition, page)}']"
    assert_selector ".govuk-summary-card__actions .govuk-summary-card__action:nth-child(2) a[href='#{confirm_destroy_admin_editionable_worldwide_organisation_page_path(page.edition, page)}']"

    assert_selector ".govuk-summary-list__row", count: 2
    assert_selector ".govuk-summary-list__row:nth-child(1) .govuk-summary-list__key", text: "Summary"
    assert_selector ".govuk-summary-list__row:nth-child(1) .govuk-summary-list__value", text: "#{'a' * 497}..."
    assert_selector ".govuk-summary-list__row:nth-child(2) .govuk-summary-list__key", text: "Body"
    assert_selector ".govuk-summary-list__row:nth-child(2) .govuk-summary-list__value", text: "#{'b' * 497}..."
  end

  test "renders the add translation action when there are missing translations for a page" do
    worldwide_organisation = create(:editionable_worldwide_organisation, translated_into: [:fr])
    page = create(:worldwide_organisation_page, edition: worldwide_organisation)

    render_inline(Admin::WorldwideOrganisationPages::Index::SummaryCardComponent.new(page:, worldwide_organisation:))

    assert_selector ".govuk-summary-card__actions .govuk-summary-card__action:nth-child(2) a[href='#{admin_editionable_worldwide_organisation_page_translations_path(worldwide_organisation, page, page.translation_locale)}']", text: "Add translation"
  end

  test "renders the correct values when contact is a translation" do
    page = create(:worldwide_organisation_page,
                  translated_into: [:fr])
    french_translation = page.non_english_localised_models.first

    render_inline(Admin::WorldwideOrganisationPages::Index::SummaryCardComponent.new(page: french_translation, worldwide_organisation: page.edition))

    assert_selector ".govuk-summary-card__title", text: "Publication scheme - Français (French)"
    assert_selector ".govuk-summary-card__actions .govuk-summary-card__action:nth-child(1) a[href='#{edit_admin_editionable_worldwide_organisation_page_translation_path(page.edition, page, french_translation.translation_locale)}']"
    assert_selector ".govuk-summary-card__actions .govuk-summary-card__action:nth-child(2) a[href='#{confirm_destroy_admin_editionable_worldwide_organisation_page_translation_path(page.edition, page, french_translation.translation_locale)}']"

    assert_selector ".govuk-summary-list__row", count: 2

    assert_selector ".govuk-summary-list__row:nth-child(1) .govuk-summary-list__key", text: "Summary"
    assert_selector ".govuk-summary-list__row:nth-child(1) .govuk-summary-list__value", text: "fr-Some summary"
    assert_selector ".govuk-summary-list__row:nth-child(2) .govuk-summary-list__key", text: "Body"
    assert_selector ".govuk-summary-list__row:nth-child(2) .govuk-summary-list__value", text: "fr-Some body"
  end
end
