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
end
