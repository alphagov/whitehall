# frozen_string_literal: true

require "test_helper"

class Admin::WorldwideOrganisationPages::Index::SummaryCardComponentTest < ViewComponent::TestCase
  include Rails.application.routes.url_helpers

  test "renders a worldwide organisation page summary card" do
    page = create(:worldwide_organisation_page, summary: "a" * 501, body: "b" * 501)

    render_inline(Admin::WorldwideOrganisationPages::Index::SummaryCardComponent.new(page:))

    assert_selector ".govuk-summary-card__title", text: "Publication scheme"
    assert_selector ".govuk-summary-card__actions .govuk-summary-card__action:nth-child(1) a[href='#{edit_admin_editionable_worldwide_organisation_page_path(page.edition, page)}']"

    assert_selector ".govuk-summary-list__row", count: 2
    assert_selector ".govuk-summary-list__row:nth-child(1) .govuk-summary-list__key", text: "Summary"
    assert_selector ".govuk-summary-list__row:nth-child(1) .govuk-summary-list__value", text: "#{'a' * 497}..."
    assert_selector ".govuk-summary-list__row:nth-child(2) .govuk-summary-list__key", text: "Body"
    assert_selector ".govuk-summary-list__row:nth-child(2) .govuk-summary-list__value", text: "#{'b' * 497}..."
  end
end
