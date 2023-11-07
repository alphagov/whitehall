# frozen_string_literal: true

require "test_helper"

class Admin::Editions::Show::TranslationsSummaryCardComponentTest < ViewComponent::TestCase
  include Rails.application.routes.url_helpers

  test "doesn't render unless edition is translatable" do
    edition = build_stubbed(:edition)
    render_inline(Admin::Editions::Show::TranslationsSummaryCardComponent.new(edition:))

    assert_empty page.text
  end

  test "renders a summary card component with a title and no content if no translations are present" do
    edition = build_stubbed(:draft_publication)
    render_inline(Admin::Editions::Show::TranslationsSummaryCardComponent.new(edition:))

    assert_selector ".govuk-summary-card__title", text: "Translations"
    assert_selector ".govuk-summary-card__content", count: 0
  end

  test "renders a link to add translations when edition is editable and there are missing translations" do
    edition = build_stubbed(:draft_publication)
    render_inline(Admin::Editions::Show::TranslationsSummaryCardComponent.new(edition:))

    assert_selector ".govuk-summary-card__action a[href='#{new_admin_edition_translation_path(edition)}']", text: "Add translation"
  end

  test "does not render a link to add translations when edition is not editable (post publication state)" do
    edition = build_stubbed(:published_publication)
    render_inline(Admin::Editions::Show::TranslationsSummaryCardComponent.new(edition:))

    assert_selector ".govuk-summary-card__action a[href='#{new_admin_edition_translation_path(edition)}']", text: "Add translation", count: 0
  end

  test "does not render a link to add translations when edition has no missing translations" do
    edition = build_stubbed(:draft_publication)
    edition.stubs(:missing_translations).returns([])
    render_inline(Admin::Editions::Show::TranslationsSummaryCardComponent.new(edition:))

    assert_selector ".govuk-summary-card__action a[href='#{new_admin_edition_translation_path(edition)}']", text: "Add translation", count: 0
  end
end
